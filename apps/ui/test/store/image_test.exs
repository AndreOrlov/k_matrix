defmodule Store.ImageTest do
  use ExUnit.Case

  # @tag :skip
  test "#put_image_coords" do
    # {qty_cols, qty_rows}
    matrix_dimensions = {2, 1}

    # [y, x] coords, 0 based index
    coords = %{
      "A01" => [[0, 0], [0, 1], [1, 2]],
      "B01" => [[1, 0], [2, 2]]
    }

    res = [
      ["A01", "A01", "none", "none"],
      ["B01", "none", "A01", "none"],
      ["none", "none", "B01", "none"]
    ]

    # TODO: промежуточный итог, надо дописывать еще
    assert {:ok, res} == Store.Image.put_image_coords(coords, matrix_dimensions)
  end

  # @tag :skip
  test "build empty canvas" do
    # {qty_cols, qty_rows}
    matrix_dimensions = {2, 1}

    coords = %{
      "A01" => [[0, 0], [1, 0]],
      "B01" => [[0, 1], [3, 3]]
    }

    # [y, x] coords, 0 based index
    res = [
      ["none", "none", "none", "none"],
      ["none", "none", "none", "none"],
      ["none", "none", "none", "none"],
      ["none", "none", "none", "none"]
    ]

    assert res == Store.Image.build_canvas(coords, matrix_dimensions, "none")
  end

  # @tag :skip
  test "draw image on canvas" do
    canvas = [
      ["none", "none", "none", "none"],
      ["none", "none", "none", "none"],
      ["none", "none", "none", "none"]
    ]

    # [y, x] coords, 0 based index
    coords = %{
      "A01" => [[0, 0], [0, 1]],
      "B01" => [[1, 0], [2, 2]]
    }

    res = [
      ["A01", "A01", "none", "none"],
      ["B01", "none", "none", "none"],
      ["none", "none", "B01", "none"]
    ]

    assert res == Store.Image.draw_image(canvas, coords)
  end

  # @tag :skip
  test "split by matrix" do
    # {qty_cols, qty_rows}
    matrix_dimensions = {2, 3}

    # image on canvas
    picture = [
      ["A00", "A01", "none", "none"],
      ["B00", "none", "B02", "none"],
      ["none", "none", "C02", "none"],
      ["none", "D01", "none", "none"],
      ["none", "none", "E02", "none"],
      ["none", "none", "none", "F03"]
    ]

    # одна точка в матрице - %{y_matrix => %{y_matrix => %{y_in_matrix => %{x_in_matrix => color}}}}
    matriсes = %{
      0 => %{
        0 => %{
          0 => %{0 => "A00", 1 => "A01"},
          1 => %{0 => "B00", 1 => "none"},
          2 => %{0 => "none", 1 => "none"}
        },
        1 => %{
          0 => %{0 => "none", 1 => "none"},
          1 => %{0 => "B02", 1 => "none"},
          2 => %{0 => "C02", 1 => "none"}
        }
      },
      1 => %{
        0 => %{
          0 => %{0 => "none", 1 => "D01"},
          1 => %{0 => "none", 1 => "none"},
          2 => %{0 => "none", 1 => "none"}
        },
        1 => %{
          0 => %{0 => "none", 1 => "none"},
          1 => %{0 => "E02", 1 => "none"},
          2 => %{0 => "none", 1 => "F03"}
        }
      }
    }

    assert matriсes == Store.Image.__split_by_matrix__(picture, matrix_dimensions)
  end
end
