defmodule Store.ImageTest do
  use ExUnit.Case

  @tag :skip
  test "check multiplicity tiles" do
  end

  # @tag: skip
  test "build empty canvas" do
    # {qty_cols, qty_rows}
    tile_dimensions = {2, 1}

    coords = %{
      "A01" => [[1, 1], [2, 1]],
      "B01" => [[1, 2], [3, 3]]
    }

    res = [
      ["none", "none", "none", "none"],
      ["none", "none", "none", "none"],
      ["none", "none", "none", "none"]
    ]

    assert res == Store.Image.build_canvas(coords, tile_dimensions, "none")
  end

  # @tad :skip
  test "split by matrix" do
    # {qty_cols, qty_rows}
    tile_dimensions = {2, 1}

    canvas = [
      ["none", "none", "none", "none"],
      ["none", "none", "none", "none"],
      ["none", "none", "none", "none"]
    ]

    coords = [
      {"A01", [[1, 1], [2, 1]]},
      {"B01", [[1, 2], [3, 3]]}
    ]

    res = [
      ["A01", "A01", "none", "none"],
      ["none", "B01", "none", "none"],
      ["none", "none", "B01", "none"]
    ]

    assert res == Store.Image.__split_by_matrix__(canvas, coords, tile_dimensions)
  end

  # @tag :skip
  test "leading rows image" do
    limit = 5

    rows = [
      ["A01", "B01", "A01"],
      ["A02", "B02", "A02"]
    ]

    res = [
      ["A01", "B01", "A01", "none", "none"],
      ["A02", "B02", "A02", "none", "none"]
    ]

    assert res == Store.Image.__leading_rows__(rows, limit)
  end

  # @tag :skip
  test "leading row image" do
    limit = 5
    row = ["A01", "B01", "A01"]
    res = ["A01", "B01", "A01", "none", "none"]

    assert res == Store.Image.__leading_row__(row, limit)
  end

  @tag :skip
  test "matrix tiles build correct" do
  end
end
