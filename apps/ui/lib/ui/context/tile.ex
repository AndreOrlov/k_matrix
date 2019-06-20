defmodule Context.Tile do
  alias Context.Tile.Max7219, as: Driver

  # dimensions tile. Tile - отдельная микросхема MAX7219 с матрицей диодов 8 х 8
  @cols Application.get_env(:matrix, :dimensions)[:tile_cols]
  @rows Application.get_env(:matrix, :dimensions)[:tile_rows]

  # matrix in tiles
  @matrix_weight Application.get_env(:matrix, :dimensions)[:weight]
  @matrix_height Application.get_env(:matrix, :dimensions)[:height]

  # TODO: DYI
  @x_default 0
  @y_default 0
  # TODO: DYI
  # WARNING: команды для микросхемы MAX7219
  # ref datasheet: https://datasheets.maximintegrated.com/en/ds/MAX7219-MAX7221.pdf
  # TODO: выделить в отдельный модуль сспецифичный код для микросхемы MAX7219
  @x [
    0b10000000,
    0b01000000,
    0b00100000,
    0b00010000,
    0b00001000,
    0b00000100,
    0b00000010,
    0b00000001
  ]
  @y [
    0b00000001,
    0b00000010,
    0b00000011,
    0b00000100,
    0b00000101,
    0b00000110,
    0b00000111,
    0b00001000
  ]

  # Инициализирует матрицу диодов, формирование SPI команд
  # coords [[x1, y1], ... ,[xn, yn]]
  def run(coords) do
    {:ok, ref} = Driver.open
    :ok = Driver.shutdown(ref)
    :ok = Driver.lights_off(ref)
    :ok = Driver.test_on(ref)

    Process.sleep(3000)

    :ok = Driver.test_off(ref)
    :ok = Driver.activate_rows(ref)
    :ok = Driver.disable_code(ref)
    :ok = Driver.resume(ref)

    :ok = Driver.lights_on_by_coords(ref, coord_tiles(coords))

    :ok = Driver.close(ref)
  end

  # TODO: перевести сначала в обычные координаты. В коорд. макс7219 переведет Context.Tile.Max7219
  # coord x, y - координаты во всей матрице tiles
  def coord([x | [y | _]] = point_coord) when length(point_coord) == 2, do: coord(x, y)

  def coord(x, y) when is_integer(x) and is_integer(y) do
    {:div, x_div, :rem, x_rem} = div_rem(x, @cols)
    {:div, y_div, :rem, y_rem} = div_rem(y, @rows)

    for y_coord <- 0..(@matrix_height - 1), x_coord <- 0..(@matrix_weight - 1) do
      case {y_coord, x_coord} do
        {^y_div, ^x_div} -> [Enum.at(@y, y_rem), Enum.at(@x, x_rem)]
        _ -> [@y_default, @x_default]
      end
    end
  end

  # coords [[x1, y1], ...,[xn, yn]], координаты в каждом tile (8 х 8). length(coords) == кол-во tiles (8 x 8) в матрице
  def coord_tiles(coords) do
    coords
    |> Enum.map(fn [x | [y | _]] -> coord(x, y) end)
  end

  defp div_rem(dividend, divisor),
    do: {:div, div(dividend, divisor), :rem, rem(dividend, divisor)}
end
