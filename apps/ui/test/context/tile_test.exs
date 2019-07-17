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
      [0, 0],
      # T1
      [0, 8],
      # T2
      [8, 0],
      # bottom right corner. T3
      [15, 15]
    ]

    res = [
      [[0, 0]],
      [[0, 0]],
      [[0, 0]],
      [[7, 7]]
    ]

    assert res == Context.Tile.coord_by_tiles(coords)
  end

  # @tag :skip
  test "correct coords to some coords in ome tiles" do
    coords = [
      # left top corner. T0
      [0, 0],
      # T0
      [1, 0]
    ]

    res = [
      [[0, 0], [1, 0]],
      [],
      [],
      []
    ]

    assert res == Context.Tile.coord_by_tiles(coords)
  end

  # @tag :skip
  test "wrong negative coords to coords by tiles" do
    coords = [
      [-1, -1]
    ]

    assert_raise FunctionClauseError, fn -> Context.Tile.coord_by_tiles(coords) end
  end

  # @tag :skip
  test "wrong range coords to coords by tiles" do
    coords = [
      [17, 17]
    ]

    assert_raise FunctionClauseError, fn -> Context.Tile.coord_by_tiles(coords) end
  end
end
