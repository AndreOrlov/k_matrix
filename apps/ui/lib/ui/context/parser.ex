defmodule Context.Parser do
  def parsing_old(stream) do
    res_parsing_csv =
      stream
      |> CSV.decode()
      |> Enum.to_list()

    # TODO: использовать для одной матрицы
    case build_matrix(res_parsing_csv) do
      {:ok, _res, matrix} -> {:ok, matrix}
      {:error, msg} -> {:error, msg}
    end
  end

  def parsing(stream) do
    # 31_400 строк csv файла (3 колонки) декодит около 450ms
    {time, res_parsing_csv} =
    :timer.tc(fn ->
    # res_parsing_csv =
      stream
      |> CSV.decode()
      |> Enum.to_list()
    end)
    IO.inspect(time, label: :TIME_DECODE)

    with {:ok, :validated} <- validate(res_parsing_csv) do
      {:ok, res_parsing_csv}
    else
      _ -> {:error, "Some rows have errors in file"}
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
         {:ok, matrix_updated} <- matrix_update(key, integers, matrix) do
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

  defp validate(csv_decoded_rows) do
    res =
      csv_decoded_rows
      |> Enum.any?(fn
        {:error, _} ->
          true

        {:ok, [color, x, y]} ->
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
