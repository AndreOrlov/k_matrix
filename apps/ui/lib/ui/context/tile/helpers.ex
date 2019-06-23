defmodule Context.Tile.Helpers do
  # транспонирует матрицу
  def transpose(rows) do
    rows
    |> List.zip()
    |> Enum.map(&Tuple.to_list/1)
  end
end
