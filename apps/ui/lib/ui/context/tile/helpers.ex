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

  defmodule List do
    def flatten(list, depth \\ -2), do: flatten(list, depth + 1, []) |> Enum.reverse()
    def flatten(list, 0, acc), do: [list | acc]
    def flatten([h | t], depth, acc) when h == [], do: flatten(t, depth, acc)

    def flatten([h | t], depth, acc) when is_list(h),
      do: flatten(t, depth, flatten(h, depth - 1, acc))

    def flatten([h | t], depth, acc), do: flatten(t, depth, [h | acc])
    def flatten([], _, acc), do: acc
  end

  defmodule Map do
    def deep_merge(left, right) do
      Elixir.Map.merge(left, right, &deep_resolve/3)
    end

    # Key exists in both maps, and both values are maps as well.
    # These can be merged recursively.
    defp deep_resolve(_key, left = %{}, right = %{}) do
      deep_merge(left, right)
    end

    # Key exists in both maps, but at least one of the values is
    # NOT a map. We fall back to standard merge behavior, preferring
    # the value on the right.
    defp deep_resolve(_key, _left, right) do
      right
    end
  end
end
