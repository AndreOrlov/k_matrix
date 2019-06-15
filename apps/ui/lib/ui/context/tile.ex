defmodule Context.Tile do
  # dimensions tile. Tile - отдельная микросхема MAX7219 с матрицей диодов 8 х 8
  @cols 8
  @rows 8

  # matrix in tiles
  @matrix_weight 2
  @matrix_height 2
  @qty_tiles @matrix_weight * @matrix_height

  # WARNING: команды для микросхемы MAX7219
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
  @x_default 0

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
  @y_default 0

  # shutdown tile (data not lose)
  @tile_shutdown [0x0C, 0x00]
  # resume tile (restore data)
  @tile_resume [0x0C, 0x01]
  # test on leds (switch on leds)
  @tile_test_on [0x0F, 0x01]
  # test off leds (switch off leds)
  @tile_test_off [0x0F, 0x01]
  # активировать 8 строк
  @tile_active_rows [0x0B, 0x07]
  # no decode mode select
  @tile_no_decode_mode [0x09, 0x00]

  # Инициализирует матрицу диодов, формирование SPI команд
  # coords [[x1, y1], ... ,[xn, yn]]
  def run(coords) do
    {:ok, ref} = Circuits.SPI.open("spidev0.0")

    {:ok, _} = Circuits.SPI.transfer(ref, max7219_command(@tile_shutdown))
    {:ok, _} = Circuits.SPI.transfer(ref, max7219_command(@tile_test_on))
    Process.sleep(3000)
    {:ok, _} = Circuits.SPI.transfer(ref, max7219_command(@tile_test_off))
    {:ok, _} = Circuits.SPI.transfer(ref, max7219_command(@tile_active_rows))
    {:ok, _} = Circuits.SPI.transfer(ref, max7219_command(@tile_no_decode_mode))
    {:ok, _} = Circuits.SPI.transfer(ref, max7219_command(@tile_resume))

    max7219_coord(coords)

    :ok = Circuits.SPI.close(ref)
  end

  # Переводит в базовые команды каждый tile матрицы
  def max7219_command(command) when length(command) == 2 do
    for y_tile <- 0..(@matrix_height - 1), x_tile <- 0..(@matrix_weight - 1) do
      command
    end
    |> transform_to_spi()
  end

  def max7219_transform_coord(coords) do
    coords
    |> Enum.map(&coord/1)
    |> max7219_group_coord()
  end

  def max7219_group_coord([], acc), do: acc

  # coords[[[2, 64], [0, 0], [0, 0], [0, 0]], [[2, 32], [0, 0], [0, 0], [0, 0]]], ...]
  def max7219_group_coord([coord | coords], acc \\ %{}) do
    acc_updated = max7219_acc_row(coord, acc)
    max7219_group_coord(coords, acc_updated)
  end

  def max7219_acc_row(row, acc, -1), do: acc
  # TODO: refactor to recursion
  def max7219_acc_row(row, acc, qty_tiles \\ @qty_tiles - 1) do
    use Bitwise
    IO.inspect(row)
    [x, y] = Enum.at(row, qty_tiles)

    {_, acc_tile} =
      Map.get_and_update(acc, qty_tiles, fn old_value ->
        value = old_value || %{}

        {_, res} =
          Map.get_and_update(value, x, fn old_value ->
            new_value =
              case old_value do
                nil -> y
                _ -> old_value ||| y
              end

            {old_value, new_value}
          end)

        {old_value, res}
      end)

    IO.inspect(acc_tile, label: :ACC_TILE)
    max7219_acc_row(row, acc_tile, qty_tiles - 1)
  end

  # TODO: rad
  # coords [[x1, y1], ...,[xn, yn]], координаты в каждом tile (8 х 8). length(coords) == кол-во tiles (8 x 8) в матрице
  def max7219_coord(coords) do
    Enum.map(coords, fn [x | [y | _]] ->
      coord(x, y)
    end)
    |> Enum.map(&transform_to_spi/1)
  end

  # coord x, y - координаты во всей матрице tiles
  def coord([x | [y | _]] = point_coord) when length(point_coord) == 2, do: coord(x, y)

  def coord(x, y) when is_integer(x) and is_integer(y) do
    IO.inspect({:div, x_div, :rem, x_rem} = div_rem(x, @cols), label: "X")
    IO.inspect({:div, y_div, :rem, y_rem} = div_rem(y, @rows), label: "Y")

    for y_coord <- 0..(@matrix_height - 1), x_coord <- 0..(@matrix_weight - 1) do
      case {y_coord, x_coord} do
        {^y_div, ^x_div} -> [Enum.at(@y, y_rem), Enum.at(@x, x_rem)]
        _ -> [@y_default, @x_default]
      end
    end
  end

  defp div_rem(dividend, divisor),
    do: {:div, div(dividend, divisor), :rem, rem(dividend, divisor)}

  defp transform_to_spi(coords) do
    coords
    |> List.flatten()
    |> Enum.into(<<>>, &<<&1>>)
  end
end
