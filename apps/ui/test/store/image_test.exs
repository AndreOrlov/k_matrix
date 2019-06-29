defmodule Store.ImageTest do
  use ExUnit.Case

  @tag :skip
  test "build matrix image" do
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
