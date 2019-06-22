defmodule Context.Tile.Max7219Test do
  @moduledoc """
    Тесты для 4х tiles MAX7219. Tile - 8 x 8 точек (диодов)
    Расположение tiles in matrix
    T0 T1
    T2 T3
  """

  use ExUnit.Case

  @tag :skip
  test "light on one led (top left corner)" do
    res = [
      <<8, 1, 0, 0, 0, 0, 0, 0>>
    ]

    assert res = Context.Tile.Max7219.max7219_coord([[0, 0]])
  end

  @tag :skip
  test "light on one led (bottom right corner)" do
    res = [
      <<0, 0, 0, 0, 0, 0, 8, 1>>
    ]

    assert res = Context.Tile.max7219_coord([[15, 15]])
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

  @tag :skip
  test "correct transform coord to format max7219" do
    coords = [[1, 1], [1, 2], [2, 1], [9, 9], [15, 15]]

    res = [
      <<3, 64, 0, 0, 0, 0, 2, 64>>,
      <<2, 96, 0, 0, 0, 0, 8, 1>>
    ]

    assert res == Context.Tile.max7219_coord(coords)
  end

  @tag :skip
  test "all lights_off commands format MAX7219" do
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

    assert res == Context.Tile.max7219_lights_off()
  end

  # @tag :skip
  test "group cols by row in tile" do
    coords = [
      [[1, 2], [0, 0], [0, 0], [0, 0]],
      [[2, 1], [0, 0], [0, 0], [0, 0]],
      [[1, 1], [0, 0], [0, 0], [0, 0]],
      [[0, 0], [1, 2], [0, 0], [0, 0]],
      [[0, 0], [0, 0], [0, 0], [4, 3]]
    ]

    res = [
      # [1, 1] и [2, 1] схлопывается  в [3, 1]. Ро одинаковым х в том же файле, см. команды в datasheet MAX7219
      [[1, 3], [2, 1]],
      [[1, 2]],
      [],
      [[4, 3]]
    ]

    assert res == Context.Tile.Max7219.group_coord_by_row(coords)
  end

  # @tag :skip
  test "build matrix coordinats for tile MAX7219" do
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
