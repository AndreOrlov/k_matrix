defmodule Context.Tile.Max7219 do
  use Bitwise

  # TODO: DYI
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

  def open do
    {:ok, ref} = Circuits.SPI.open("spidev0.0")

    {:ok, ref}
  end

  def shutdown(ref) do
    {:ok, _} = Circuits.SPI.transfer(ref, __command__(@tile_shutdown))

    :ok
  end

  def lights_off(ref) do
    Enum.each(__lights_off__, &({:ok, _} = Circuits.SPI.transfer(ref, &1)))

    :ok
  end

  def test_on(ref) do
    {:ok, _} = Circuits.SPI.transfer(ref, __command__(@tile_test_on))

    :ok
  end

  def test_off(ref) do
    {:ok, _} = Circuits.SPI.transfer(ref, __command__(@tile_test_off))

    :ok
  end

  def activate_rows(ref) do
    {:ok, _} = Circuits.SPI.transfer(ref, __command__(@tile_active_rows))

    :ok
  end

  def disable_code(ref) do
    {:ok, _} = Circuits.SPI.transfer(ref, __command__(@tile_no_decode_mode))

    :ok
  end

  def resume(ref) do
    {:ok, _} = Circuits.SPI.transfer(ref, __command__(@tile_resume))

    :ok
  end

  def lights_on_by_coords(ref, coords) do
    Enum.each(__coord__(coords), &({:ok, _} = Circuits.SPI.transfer(ref, &1)))

    :ok
  end

  def close(ref) do
    :ok = Circuits.SPI.close(ref)
  end

  # Группирует колонки (x) по строкам (y) в каждом тайле, удаляет NoP ([0, 0])
  # Example
  # coords_with_tile = [
  #   [[1, 2], [0, 0], [0, 0], [0, 0]],
  #   [[2, 1], [0, 0], [0, 0], [0, 0]],
  #   [[1, 1], [0, 0], [0, 0], [0, 0]],
  #   [[0, 0], [1, 2], [0, 0], [0, 0]],
  #   [[0, 0], [0, 0], [0, 0], [4, 3]]
  # ]
  def group_coord_by_row(coords_with_tile, sorted_tile \\ 0)
  def group_coord_by_row(_coords_with_tile, @qty_tiles), do: []

  def group_coord_by_row(coords_with_tile, sorted_tile) do
    coords_tile_groupped =
      coords_with_tile
      |> Enum.map(&Enum.at(&1, sorted_tile))
      |> Enum.sort(fn cur, next ->
        y_cur = Enum.at(cur, -1)
        y_next = Enum.at(next, -1)

        y_cur > y_next
      end)
      |> Enum.reduce([], &group_x_by_y/2)
      # Отбрасываем [0, 0]
      |> Enum.filter(&([0, 0] != &1))

    [coords_tile_groupped | group_coord_by_row(coords_with_tile, sorted_tile + 1)]
  end

  # ДСП

  # Переводит в базовые команды каждый tile матрицы
  def __command__(command) when length(command) == 2 do
    for _y_tile <- 0..(@matrix_height - 1), _x_tile <- 0..(@matrix_weight - 1) do
      command
    end
    |> transform_to_spi()
  end

  # Выключает все диоды в каждом tile матрицы
  def __lights_off__ do
    for num_row <- 0..(@rows - 1) do
      for _ <- 0..(@matrix_height - 1), _ <- 0..(@matrix_weight - 1) do
        [Enum.at(@y, num_row), @x_default]
      end
      |> transform_to_spi()
    end
  end

  def __coord__(coords) do
    coords
    |> group_coord_by_row
    |> __matrix_coords__
    |> transpose()
    |> Enum.map(&transform_to_spi/1)
  end

  # Example max7219_matrix_coords [x, y] - [
  #   [[1, 2], [3, 1]], # leds on to 0 tile
  #   [[1, 2]], # leds on to 1 tile
  #   [], # leds on to 2 tile (nothing on)
  #   [[4, 3]] # leds on to 2 tile
  # ]
  def __matrix_coords__([head | tail] = max7219_matrix_coords) do
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

  defp transpose(rows) do
    rows
    |> List.zip()
    |> Enum.map(&Tuple.to_list/1)
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
end
