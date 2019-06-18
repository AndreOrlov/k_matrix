defmodule Context.Tile do
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
  # включить всю строку (8 диодов) в tile
  @x_all_in_row 0b11111111

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
    for y_tile <- 0..(@matrix_height - 1), x_tile <- 0..(@matrix_weight - 1) do
      command
    end
    |> transform_to_spi()
  end

  # Выключает все диоды в каждом tile матрицы
  def max7219_lights_off() do
    for num_row <- 0..(@rows - 1) do
      for y_tile <- 0..(@matrix_height - 1), _x_tile <- 0..(@matrix_weight - 1) do
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
