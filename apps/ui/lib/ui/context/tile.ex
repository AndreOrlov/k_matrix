defmodule Context.Tile do
  # dimensions tile
  @cols 8
  @rows 8

  # matrix in tiles
  @matrix_weight 2
  @matrix_height 2

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
  def run(matrix, callback) do
    {:ok, ref} = Circuits.SPI.open("spidev0.0")

    {:ok, _} = Circuits.SPI.transfer(ref, command_spi(@tile_shutdown))
    {:ok, _} = Circuits.SPI.transfer(ref, command_spi(@tile_test_on))
    Process.sleep(3000)
    {:ok, _} = Circuits.SPI.transfer(ref, command_spi(@tile_test_off))
    {:ok, _} = Circuits.SPI.transfer(ref, command_spi(@tile_active_rows))
    {:ok, _} = Circuits.SPI.transfer(ref, command_spi(@tile_no_decode_mode))
    {:ok, _} = Circuits.SPI.transfer(ref, command_spi(@tile_resume))

    # TODO: call callback function

    :ok = Circuits.SPI.close(ref)
  end

  def command_spi(command) when length(command) == 2 do
    for y_tile <- 0..(@matrix_height - 1), x_tile <- 0..(@matrix_weight - 1) do
      command
    end
    |> List.flatten()
    |> Enum.into(<<>>, &<<&1>>)
  end

  # def matrix_convert(coords) do
  #   coords
  #   |> Enum.map(fn [x | y] -> coord(x, y) end)
  # end

  # def coords_group(coords_spi) do
  # end

  def coord(x, y) when is_integer(x) and is_integer(y) do
    IO.inspect({:div, x_div, :rem, x_rem} = div_rem(x, @cols), label: "X")
    IO.inspect({:div, y_div, :rem, y_rem} = div_rem(y, @rows), label: "Y")

    for y_coord <- 0..(@matrix_height - 1), x_coord <- 0..(@matrix_weight - 1) do
      case {y_coord, x_coord} do
        {^y_div, ^x_div} -> [Enum.at(@y, y_rem), Enum.at(@x, x_rem)]
        _ -> [@y_default, @x_default]
      end
    end
    |> List.flatten()
    |> Enum.into(<<>>, &<<&1>>)
  end

  defp div_rem(dividend, divisor),
    do: {:div, div(dividend, divisor), :rem, rem(dividend, divisor)}
end
