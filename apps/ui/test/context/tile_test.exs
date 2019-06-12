defmodule Context.TileTest do
  use ExUnit.Case

  # @tag :skip
  test "light on one led (top left corner)" do
    assert :ok = Context.Tile.light_on(1, 1)
  end

  # @tag :skip
  test "light off one led (top left corner)" do
    assert :ok = Context.Tile.light_off(1, 1)
  end

  # @tag :skip
  test "light on one led (bottom right corner)" do
    assert :ok = Context.Tile.light_on(15, 15)
  end

  # @tag :skip
  test "light off one led (bottom right corner)" do
    assert :ok = Context.Tile.light_off(15, 15)
  end
end
