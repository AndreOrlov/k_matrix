defmodule Context.ParserTest do
  use ExUnit.Case

  # @tag :skip
  test "alone color" do
    string = """
    A01,1,1
    B01,1,2
    """

    res =
      string_to_stream(string)
      |> Context.Parser.parsing()

    assert map_size(res) == 2
    assert integers?(Map.values(res))
  end

  # @tag :skip
  test "double color" do
    string = """
    A01,1,1
    A01,1,2
    """

    res =
      string_to_stream(string)
      |> Context.Parser.parsing()

    assert map_size(res) == 1
    assert integers?(Map.values(res))
  end

  # wrong format string

  # @tag :skip
  test "different cols in rows" do
    string = """
    A01,1,1
    B01,1,2,3
    """

    res =
      string_to_stream(string)
      |> Context.Parser.parsing()

    assert {:error, _} = res
  end

  # @tag :skip
  test "wrong coordinates" do
    string = """
    A01,4error,1
    B01,1,2
    """

    res =
      string_to_stream(string)
      |> Context.Parser.parsing()

    assert {:error, _} = res
  end

  defp string_to_stream(string) do
    {:ok, stream} =
      string
      |> StringIO.open()

    IO.binstream(stream, :line)
  end

  defp integers?(array) when is_list(array) do
    array
    |> List.flatten()
    |> Enum.all?(&is_integer/1)
  end
end
