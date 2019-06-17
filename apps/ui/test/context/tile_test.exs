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

  @tag :skip
  test "correct transform coord to format max7219" do
    coords = [[1, 1], [9, 9], [15, 15]]

    res = [
      <<2, 64, 0, 0, 0, 0, 0, 0>>,
      <<0, 0, 0, 0, 0, 0, 2, 64>>,
      <<0, 0, 0, 0, 0, 0, 8, 1>>
    ]

    assert res == Context.Tile.max7219_coord(coords)
  end

  # @tag :skip
  test "acc coords to MAX7219" do
    coords = [[1, 1], [2, 1], [9, 9], [10, 9], [14, 15], [15, 15]]

    assert :ok == Context.Tile.max7219_transform_coord(coords)
  end
end
