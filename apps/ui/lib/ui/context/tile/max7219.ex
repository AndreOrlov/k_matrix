defmodule Context.Tile.Max7219 do
  use Bitwise

  @spi if Mix.env() != :prod, do: Context.Tile.Helpers, else: Circuits.SPI

  # dimensions tile. Tile - отдельная микросхема MAX7219 с матрицей диодов 8 х 8
  @rows Application.get_env(:matrix, :dimensions)[:tile_rows]

  # matrix in tiles
  @matrix_widht Application.get_env(:matrix, :dimensions)[:width]
  @matrix_height Application.get_env(:matrix, :dimensions)[:height]

  # WARNING: команды для микросхемы MAX7219
  # ref datasheet: https://datasheets.maximintegrated.com/en/ds/MAX7219-MAX7221.pdf
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

  def open do
    {:ok, ref} = @spi.open("spidev0.0")

    {:ok, ref}
  end

  def shutdown(ref) do
    {:ok, _} = @spi.transfer(ref, __command__(@tile_shutdown))

    :ok
  end

  def lights_off(ref) do
    Enum.map(__lights_off__(), &({:ok, _} = @spi.transfer(ref, &1)))

    :ok
  end

  def test_on(ref) do
    {:ok, _} = @spi.transfer(ref, __command__(@tile_test_on))

    :ok
  end

  def test_off(ref) do
    {:ok, _} = @spi.transfer(ref, __command__(@tile_test_off))

    :ok
  end

  def activate_rows(ref) do
    {:ok, _} = @spi.transfer(ref, __command__(@tile_active_rows))

    :ok
  end

  def disable_code(ref) do
    {:ok, _} = @spi.transfer(ref, __command__(@tile_no_decode_mode))

    :ok
  end

  def resume(ref) do
    {:ok, _} = @spi.transfer(ref, __command__(@tile_resume))

    :ok
  end

  def lights_on_by_coords(ref, coords) do
    Enum.each(__transfer_coords__(coords), &({:ok, _} = @spi.transfer(ref, &1)))

    :ok
  end

  def close(ref) do
    :ok = @spi.close(ref)
  end

  def __transfer_coords__(coords) do
    coords
    |> Enum.map(&translate_coord_to_max7219/1)
    |> group_coord_by_row
    |> __matrix_coords__
    |> Context.Tile.Helpers.transpose()
    |> Enum.map(&transform_to_spi/1)
  end

  # Группирует колонки (x) по строкам (y) в каждом тайле
  # Example
  # coords_with_tile = [
  #   [[1, 128], [1, 64], [2, 16]], # [y, x] tile T0
  #   [], # [y, x] tile T1
  #   [], # [y, x] tile T2
  #   [] # [y, x] tile T3
  # ]
  def group_coord_by_row(coords_with_tile) do
    coords_with_tile
    |> Enum.map(&Enum.sort/1)
    # Группируем по y в tile
    |> Enum.map(fn coords_tile ->
      Enum.reduce(coords_tile, [], &group_x_by_y/2)
    end)
  end

  # ДСП

  # Переводит в базовые команды каждый tile матрицы
  def __command__(command) when length(command) == 2 do
    for _y_tile <- 0..(@matrix_height - 1), _x_tile <- 0..(@matrix_widht - 1) do
      command
    end
    |> transform_to_spi()
  end

  # Выключает все диоды в каждом tile матрицы
  def __lights_off__ do
    for num_row <- 0..(@rows - 1) do
      for _ <- 0..(@matrix_height - 1), _ <- 0..(@matrix_widht - 1) do
        [Enum.at(@y, num_row), @x_default]
      end
      |> transform_to_spi()
    end
  end

  # Example max7219_matrix_coords [x, y] - [
  #   [[1, 2], [3, 1]], # leds on to tile T0
  #   [[1, 2]], # leds on to tile T1
  #   [], # (nothing on) on tile T2
  #   [[4, 3]] # leds on to tile T3
  # ]
  def __matrix_coords__(max7219_matrix_coords) do
    max_length =
      max7219_matrix_coords
      |> Enum.max_by(fn item -> length(item) end)
      |> length

    # Добавляем в конец каждого tile координат дефолтные координаты, для получения матрицы (одинаковая размерность команд по всем tile)
    Enum.map(max7219_matrix_coords, fn tile_coords ->
      len_diff = max_length - length(tile_coords)
      default_coords = List.duplicate([@x_default, @y_default], len_diff)

      tile_coords ++ default_coords
    end)
  end

  # private

  defp transform_to_spi(coords) do
    coords
    |> List.flatten()
    |> Enum.into(<<>>, &<<&1>>)
  end

  # ВАЖНО: coord [y, x] координаты на отдельном tile
  defp group_x_by_y(coord, []), do: [coord]

  defp group_x_by_y(coord, acc) do
    [y_coord, x_coord] = coord
    [y_acc, x_acc] = Enum.at(acc, -1)

    cond do
      y_coord == y_acc ->
        List.replace_at(acc, -1, [y_acc, x_acc ||| x_coord])

      true ->
        Enum.concat(acc, [[y_coord, x_coord]])
    end
  end

  defp translate_coord_to_max7219([]), do: []

  defp translate_coord_to_max7219(coords_tile) do
    coords_tile
    |> Enum.map(fn [y, x] -> [Enum.at(@y, y), Enum.at(@x, x)] end)
  end
end
