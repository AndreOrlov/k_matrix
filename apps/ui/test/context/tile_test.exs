defmodule Context.TileTest do
  @moduledoc """
    Тесты для 4х tiles. Tile - 8 x 8 точек (диодов)
    Расположение tiles in matrix
    T0 T1
    T2 T3
  """

  use ExUnit.Case

  # @tag :skip
  test "global correct coords to coords by tiles" do
    coords = [
      # left top corner. T0
      [1, 1],
      # T1
      [9, 1],
      # T2
      [1, 9],
      # bottom right corner. T3
      [16, 16]
    ]

    res = [
      [[0, 0]],
      [[0, 0]],
      [[0, 0]],
      [[7, 7]]
    ]

    assert res == Context.Tile.__coord_by_tiles__(coords)
  end

  # @tag :skip
  test "correct coords to some coords in ome tiles" do
    coords = [
      # left top corner. T0
      [1, 1],
      # T0
      [2, 1]
    ]

    res = [
      [[0, 0], [0, 1]],
      [],
      [],
      []
    ]

    assert res == Context.Tile.__coord_by_tiles__(coords)
  end

  # @tag :skip
  test "wrong negative coords to coords by tiles" do
    coords = [
      [-1, -1]
    ]

    assert_raise FunctionClauseError, fn -> Context.Tile.__coord_by_tiles__(coords) end
  end

  # @tag :skip
  test "wrong range coords to coords by tiles" do
    coords = [
      [17, 17]
    ]

    assert_raise FunctionClauseError, fn -> Context.Tile.__coord_by_tiles__(coords) end
  end
end
