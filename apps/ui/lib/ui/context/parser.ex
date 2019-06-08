defmodule Context.Parser do
  def parsing(stream) do
    res_parsing_csv =
      stream
      |> CSV.decode()
      |> Enum.take(2)

    case build_matrix(res_parsing_csv) do
      {:ok, _res, matrix} -> matrix
      {:error, msg} -> {:error, msg}
    end
  end

  defp build_matrix(array, matrix \\ %{})

  defp build_matrix([head | tail], matrix) do
    with {:ok, row} <- head,
         {:ok, matrix_updated} <- parsing_row(row, matrix),
         {:ok, parsed_tail, matrix_updated2} <- build_matrix(tail, matrix_updated) do
      {:ok, parsed_tail, matrix_updated2}
    else
      {:error, msg} ->
        {:error, msg}
    end
  end

  defp build_matrix([], matrix), do: {:ok, [], matrix}

  defp parsing_row([key | coords], matrix) do
    with {:ok, integers} <- coords_to_integer(coords),
         {ok, matrix_updated} <- matrix_update(key, integers, matrix) do
      {:ok, matrix_updated}
    else
      {:error, msg} ->
        {:error, msg}
    end
  end

  defp coords_to_integer(array) do
    try do
      {:ok, Enum.map(array, &String.to_integer/1)}
    rescue
      ArgumentError -> {:error, "Coordinate is not integer value"}
    end
  end

  defp matrix_update(key, coords, matrix) do
    {_, matrix_updated} =
      Map.get_and_update(matrix, key, fn current_value ->
        res_coords = if current_value, do: [coords | current_value], else: [coords]
        {current_value, res_coords}
      end)

    {:ok, matrix_updated}
  end
end
