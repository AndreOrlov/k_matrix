defmodule Context.TileTest do
  use ExUnit.Case

  @tag :skip
  test "light on one led (top left corner)" do
    assert :ok = Context.Tile.light_on(1, 1)
  end

  @tag :skip
  test "light off one led (top left corner)" do
    assert :ok = Context.Tile.light_off(1, 1)
  end

  @tag :skip
  test "light on one led (bottom right corner)" do
    assert :ok = Context.Tile.light_on(15, 15)
  end

  @tag :skip
  test "light off one led (bottom right corner)" do
    assert :ok = Context.Tile.light_off(15, 15)
  end

  # @tag :skip
  test "correct transform coord to format max7219" do
    coords = [[1, 1], [1, 2], [2, 1], [9, 9], [15, 15]]

    res = [
      <<3, 64, 0, 0, 0, 0, 2, 64>>,
      <<2, 96, 0, 0, 0, 0, 8, 1>>
    ]

    assert res == Context.Tile.max7219_coord(coords)
  end

  # @tag :skip
  test "lights_off commands to MAX7219" do
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
      [[1, 3], [2 , 1]],
      [[1, 2]],
      [],
      [[4, 3]]
    ]

    assert res == Context.Tile.group_coord_by_row(coords)
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

    assert res == Context.Tile.matrix_coords(max7219_matrix_coords)
  end
end
