defmodule Context.Tile.Max7219Test do
  @moduledoc """
    Тесты для 4х tiles MAX7219. Tile - 8 x 8 точек (диодов)
    Расположение tiles in matrix
    T0 T1
    T2 T3
  """

  use ExUnit.Case

  # @tag :skip
  test "light on one led (top left corner)" do
    coords = [[[0, 0]], [], [], []]
    res = [<<1, 128, 0, 0, 0, 0, 0, 0>>]

    assert res == Context.Tile.Max7219.__coord__(coords)
  end

  # @tag :skip
  test "light on one led (bottom right corner)" do
    coords = [[], [], [], [[7, 7]]]
    res = [
      <<0, 0, 0, 0, 0, 0, 8, 1>>
    ]

    assert res == Context.Tile.Max7219.__coord__(coords)
  end

  # TODO: сделать заглушку для Circuits.SPI.transfer(ref, _)
  @tag :skip
  test "tile light off" do
    res = [
      <<1, 0, 1, 0, 1, 0, 1, 0>>,
      <<2, 0, 2, 0, 2, 0, 2, 0>>,
      <<3, 0, 3, 0, 3, 0, 3, 0>>,
      <<4, 0, 4, 0, 4, 0, 4, 0>>,
      <<5, 0, 5, 0, 5, 0, 5, 0>>,
      <<6, 0, 6, 0, 6, 0, 6, 0>>,
      <<7, 0, 7, 0, 7, 0, 7, 0>>,
      <<8, 0, 8, 0, 8, 0, 8, 0>>
    ]

    assert res == Context.Tile.Max7219.lights_off()
  end

  # @tag :skip
  test "correct group by row in tile" do
    coords = [
      [[0, 0], [1, 0], [1, 2]], # T0
      [], # ничего нет в этом tile T1
      [[0, 0]], # T2
      [[7, 7]] # T3
    ]

    res = [
      <<1, 128, 0, 0, 1, 128, 8, 1>>,
      <<2, 160, 0, 0, 0, 0, 0, 0>>
    ]

    assert res == Context.Tile.Max7219.__coord__(coords)
  end

  # @tag :skip
  test "group cols by row in tile" do
    # Координаты в командах MAX7219
    coords = [
      [[1, 128], [1, 64], [2, 16]], # [y, x] tile T0
      [[1, 2]], # [y, x] tile T1
      [], # [y, x] tile T2
      [[4, 3]] # [y, x] tile T3
    ]

    res = [
      [[1, 192], [2, 16]], # [y, x] tile T0
      [[1, 2]], # [y, x] tile T1
      [], # [y, x] tile T2 empty
      [[4, 3]] # [y, x] tile T3
    ]

    assert res == Context.Tile.Max7219.group_coord_by_row(coords)
  end

  # @tag :skip
  test "#__matrix_coords__ build matrix coordinats for tile MAX7219" do
    max7219_matrix_coords = [
      [[1, 2], [3, 1]],
      [[1, 2]],
      [],
      [[4, 3]]
    ]

    res = [
      [[1, 2], [3, 1]],
      [[1, 2], [0, 0]],
      [[0, 0], [0, 0]],
      [[4, 3], [0, 0]]
    ]

    assert res == Context.Tile.Max7219.__matrix_coords__(max7219_matrix_coords)
  end
end
