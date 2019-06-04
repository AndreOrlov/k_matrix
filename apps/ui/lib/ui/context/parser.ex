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

  def build_matrix([head|tail]) do
    res_parsing_row =
      case head do
        {:ok, row} -> parsing_row(row)
        {:error, msg} -> {:error, msg}
      end

    case res_parsing_row do
      {:ok, parsed_row} -> {:ok, parsed_tail} = build_matrix(tail); {:ok, [parsed_row|parsed_tail]}
      {:error, msg} -> {:error, msg}
    end
  end

  def build_matrix([]), do: {:ok, []}

  def parsing_row(array) do
    {:ok, array} # TODO доделать сбор color: [coords arrays]
  end
end