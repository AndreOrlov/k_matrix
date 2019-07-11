defmodule Store.Image2Test do
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

    # @tag :skip
    test "right qty fp matrix dimensoions 1, 1", %{coords: coords} do
      Store.Image2.put_image_coords(coords, {1, 1})

      res = {:ok, %{qty_cols: 3, qty_rows: 3}}

      assert res == Store.Image2.qty_matrices()
    end

    # @tag :skip
    test "right qty fp matrix dimensoions 2, 2", %{coords: coords} do
      Store.Image2.put_image_coords(coords, {2, 2})

      res = {:ok, %{qty_cols: 2, qty_rows: 2}}

      assert res == Store.Image2.qty_matrices()
    end

    @tag :skip
    test "points in matrix right bottom corner" do
    end
  end

  # TODO: тестить qty_matrices cases max координата 0, или равна точкам в матрице. При началах координат 0,0
  # TODO: test for Image2#points_matrix для одной матрицы
end
