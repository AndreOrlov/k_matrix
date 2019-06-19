defmodule Context.Tile do
  use Bitwise

  # dimensions tile. Tile - отдельная микросхема MAX7219 с матрицей диодов 8 х 8
  @cols 8
  @rows 8

  # matrix in tiles
  @matrix_weight 2
  @matrix_height 2
  @qty_tiles @matrix_weight * @matrix_height

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
  @tile_test_off [0x0F, 0x00]
  # активировать 8 строк
  @tile_active_rows [0x0B, 0x07]
  # no decode mode select
  @tile_no_decode_mode [0x09, 0x00]

  # Инициализирует матрицу диодов, формирование SPI команд
  # coords [[x1, y1], ... ,[xn, yn]]
  def run(coords) do
    {:ok, ref} = Circuits.SPI.open("spidev0.0")

    {:ok, _} = Circuits.SPI.transfer(ref, max7219_command(@tile_shutdown))

    Enum.each(max7219_lights_off(), &({:ok, _} = Circuits.SPI.transfer(ref, &1)))

    {:ok, _} = Circuits.SPI.transfer(ref, max7219_command(@tile_test_on))
    Process.sleep(3000)
    {:ok, _} = Circuits.SPI.transfer(ref, max7219_command(@tile_test_off))
    {:ok, _} = Circuits.SPI.transfer(ref, max7219_command(@tile_active_rows))
    {:ok, _} = Circuits.SPI.transfer(ref, max7219_command(@tile_no_decode_mode))
    {:ok, _} = Circuits.SPI.transfer(ref, max7219_command(@tile_resume))

    Enum.each(max7219_coord(coords), &({:ok, _} = Circuits.SPI.transfer(ref, &1)))

    :ok = Circuits.SPI.close(ref)
  end

  # Переводит в базовые команды каждый tile матрицы
  def max7219_command(command) when length(command) == 2 do
    for _y_tile <- 0..(@matrix_height - 1), _x_tile <- 0..(@matrix_weight - 1) do
      command
    end
    |> transform_to_spi()
  end

  # Выключает все диоды в каждом tile матрицы
  def max7219_lights_off() do
    for num_row <- 0..(@rows - 1) do
      for _y_tile <- 0..(@matrix_height - 1), _x_tile <- 0..(@matrix_weight - 1) do
        [Enum.at(@y, num_row), @x_default]
      end
      |> transform_to_spi()
    end
  end

  # TODO: rad
  # coords [[x1, y1], ...,[xn, yn]], координаты в каждом tile (8 х 8). length(coords) == кол-во tiles (8 x 8) в матрице
  def max7219_coord(coords) do
    Enum.map(coords, fn [x | [y | _]] ->
      transform_to_spi(coord(x, y))
    end)
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

  # Группирует колонки (x) по строкам (y) в каждом тайле, удаляет NoP ([0, 0])
  def group_coord_by_row(coords_with_tile, sorted_tile \\ 0)
  def group_coord_by_row(_coords_with_tile, @qty_tiles), do: []

  def group_coord_by_row(coords_with_tile, sorted_tile) do
    coords_tile_groupped =
      coords_with_tile
      |> Enum.map(&Enum.at(&1, sorted_tile))
      # TODO:rad
      |> IO.inspect(label: :COL)
      |> Enum.sort(fn cur, next ->
        y_cur = Enum.at(cur, -1)
        y_next = Enum.at(next, -1)

        y_cur > y_next
      end)
      |> IO.inspect(label: :COL_SORT)
      |> Enum.reduce([], &group_x_by_y/2)
      # TODO:rad
      |> IO.inspect(label: :REDUCE)
      # Отбрасываем [0, 0]
      |> Enum.filter(&([0, 0] != &1))

    [coords_tile_groupped | group_coord_by_row(coords_with_tile, sorted_tile + 1)]
  end

  defp group_x_by_y(coord, []), do: [coord]

  defp group_x_by_y(coord, acc) do
    IO.inspect(acc, label: :ACC_0)
    [x_coord | [y_coord | _]] = coord
    [x_acc | [y_acc | _]] = Enum.at(acc, -1)
    # TODO:rad
    IO.inspect(coord, label: :COORd)
    # TODO:rad
    IO.inspect(acc, label: :ACC)

    cond do
      y_coord == y_acc ->
        List.replace_at(acc, -1, [x_acc ||| x_coord, y_acc])

      true ->
        Enum.concat(acc, [[x_coord, y_coord]])
    end
  end

  defp div_rem(dividend, divisor),
    do: {:div, div(dividend, divisor), :rem, rem(dividend, divisor)}

  defp transform_to_spi(coords) do
    coords
    |> List.flatten()
    |> Enum.into(<<>>, &<<&1>>)
    # TODO: rad
    |> IO.inspect(label: :SPI_COORDS)
  end
end
