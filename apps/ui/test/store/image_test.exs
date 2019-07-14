defmodule Store.ImageTest do
  use ExUnit.Case

  describe "#points_matrix" do
    setup do
      coords = [
        {:ok, ["A00", "1", "1"]},
        {:ok, ["A01", "1", "2"]},
        {:ok, ["A02", "1", "3"]},
        {:ok, ["B00", "2", "1"]},
        {:ok, ["B01", "2", "2"]},
        {:ok, ["B02", "2", "3"]},
        {:ok, ["C00", "3", "1"]},
        {:ok, ["C01", "3", "2"]},
        {:ok, ["C02", "3", "3"]}
      ]

      %{coords: coords}
    end

    # @test :skip
    test "has not duplicate" do
      coords = [
        {:ok, ["A00", "1", "1"]},
        {:ok, ["A01", "1", "1"]}
      ]

      # одинаковые координаты сольются
      res = {:ok, %{qty_cols: 1, qty_rows: 1}}

      :ok = Store.Image.put_image_coords(coords, {1, 1}) |> IO.inspect()

      assert res == Store.Image.qty_matrices()
    end

    # @tag :skip
    test "right qty fp matrix dimensoions 1, 1 (less max y, x)", %{coords: coords} do
      Store.Image.put_image_coords(coords, {1, 1})

      res = {:ok, %{qty_cols: 3, qty_rows: 3}}

      assert res == Store.Image.qty_matrices()
    end

    # @tag :skip
    test "right qty fp matrix dimensoions 3, 3 (eq max y, x)", %{coords: coords} do
      Store.Image.put_image_coords(coords, {3, 3})

      res = {:ok, %{qty_cols: 1, qty_rows: 1}}

      assert res == Store.Image.qty_matrices()
    end

    # @tag :skip
    test "right qty fp matrix dimensoions 4, 4 (more max y, x)", %{coords: coords} do
      Store.Image.put_image_coords(coords, {4, 4})

      res = {:ok, %{qty_cols: 1, qty_rows: 1}}

      assert res == Store.Image.qty_matrices()
    end

    # @tag :skip
    test "matrix_dimensions did not changed", %{coords: coords} do
      Store.Image.put_image_coords(coords, {2, 1})

      res = {:ok, %{qty_cols: 2, qty_rows: 1}}

      assert res == Store.Image.matrix_dimensions()
    end

    @tag :skip
    test "points in matrix right bottom corner" do
    end
  end

  # TODO: тестить qty_matrices cases max координата 0, или равна точкам в матрице. При началах координат 0,0
  # TODO: test for Image#points_matrix для одной матрицы
end
