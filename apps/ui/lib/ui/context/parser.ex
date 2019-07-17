defmodule Context.Parser do
  def parsing(stream) do
    # 31_400 строк csv файла (3 колонки) декодит около 450ms
    res_parsing_csv =
      stream
      |> CSV.decode()
      |> Enum.to_list()

    with {:ok, :validated} <- validate(res_parsing_csv) do
      {:ok, res_parsing_csv}
    else
      _ -> {:error, "Some rows have errors in file"}
    end
  end

  defp coords_to_integer(array) do
    try do
      {:ok, Enum.map(array, &String.to_integer/1)}
    rescue
      ArgumentError -> {:error, "Coordinate is not integer value"}
    end
  end

  defp validate(csv_decoded_rows) do
    res =
      csv_decoded_rows
      |> Enum.any?(fn
        {:error, _} ->
          true

        {:ok, [_color, x, y]} ->
          case coords_to_integer([x, y]) do
            {:ok, _} -> false
            {:error, _} -> true
          end

        {:ok, _} ->
          true
      end)

    case res do
      true -> {:error, :not_validated}
      _ -> {:ok, :validated}
    end
  end
end
