defmodule Context.Parser do
  def parsing(stream) do
    res_parsing_csv =
      stream
      |> CSV.decode
      |> Enum.take(2)

    # case res_parsing_csv do
    #   {:ok, res} -> res
    #   {:error, msg} -> {:error, msg}
    # end
    case build_matrix(res_parsing_csv) do
      {:ok, res} -> res
      {:error, msg} -> {:error, msg}
    end
  end

  def build_matrix([head|tail], matrix \\ %{}) do
    res_parsing_row =
      case head do
        {:ok, row} -> parsing_row(row, matrix)
        {:error, msg} -> {:error, msg}
      end

    case res_parsing_row do
      {:ok, parsed_row} ->
        {:ok, parsed_tail} = build_matrix(tail, matrix)
        {:ok, [parsed_row|parsed_tail]}
      {:error, msg} -> {:error, msg}
    end
  end

  def build_matrix([], matrix), do: {:ok, []}

  def parsing_row(array, matrix) do
    # {:ok, array} # TODO доделать сбор color: [coords arrays]
    [key|coords] = array
    Map.get_and_update(matrix, key, fn current_value -> [coords, current_value] end)
  end
end