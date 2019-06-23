defmodule Context.Tile.Helpers do
  # транспонирует матрицу
  def transpose(rows) do
    rows
    |> List.zip()
    |> Enum.map(&Tuple.to_list/1)
  end

  # Stubs Circuits.SPI api

  def open(_port) do
    {:ok, make_ref()}
  end

  def close(_ref) do
    :ok
  end

  def transfer(_ref, binary_bytes) do
    {:ok, binary_bytes}
  end
end
