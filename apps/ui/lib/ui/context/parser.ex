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

  def build_matrix(array, matrix \\ %{})

  def build_matrix([head | tail], matrix) do
    with {:ok, row} <- head,
         {:ok, matrix_updated} <- parsing_row(row, matrix),
         {:ok, parsed_tail, matrix_updated2} <- build_matrix(tail, matrix_updated) do
      {:ok, parsed_tail, matrix_updated2}
    else
      {:error, msg} ->
        {:error, msg}
    end
  end

  def build_matrix([], matrix), do: {:ok, [], matrix}

  def parsing_row(row, matrix) do
    # {:ok, row} # TODO доделать сбор color: [coords arrays]
    [key | coords] = row

    {_, matrix_updated} =
      Map.get_and_update(matrix, key, fn current_value ->
        res_coords = if current_value, do: [coords | current_value], else: [coords]
        IO.inspect(res_coords, label: "RES_COORDS")
        {current_value, res_coords}
      end)

    IO.inspect(key, label: "KEY")
    IO.inspect(coords, label: "COORDS")
    IO.inspect(row, label: "ROW")
    IO.inspect(matrix_updated, label: "PARS")
    {:ok, matrix_updated}
  end
end
