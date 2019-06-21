defmodule Context.Tile.Max7219Test do
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
      [8, 0],
      # T2
      [0, 8],
      # bottom right corner. T3
      [15, 15]
    ]

    res = [
      [[0, 0], [], [], []],
      [[], [0, 0], [], []],
      [[], [], [0, 0], []],
      [[], [], [], [7, 7]]
    ]

    assert res == Context.Tile.coord(coords)
  end

  # @tag :skip
  test "wrong negative coords to coords by tiles" do
    coords = [
      [-1, -1]
    ]

    assert_raise FunctionClauseError, fn -> Context.Tile.coord(coords) end
  end

  # @tag :skip
  test "wrong range coords to coords by tiles" do
    coords = [
      [16, 16]
    ]

    assert_raise FunctionClauseError, fn -> Context.Tile.coord(coords) end
  end
end
