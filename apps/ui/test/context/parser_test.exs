defmodule Context.ParserTest do
  use ExUnit.Case

  # @tag :skip
  test "alone color" do
    stream = """
    A01,1,1
    B01,1,2
    """

    res = Context.Parser.parsing(stream)

    assert length(res) == 2
  end

  @tag :skip
  test "double color" do
    stream = """
    A01,1,1
    A01,1,2
    """

    res = Context.Parser.parsing(stream)

    assert length(res) == 1
  end

  # wrong format stream

  @tag :skip
  test "different cols in rows" do
    stream = """
    A01,1,1
    B01,1,2,3
    """
    res = Context.Parser.parsing(stream)

    assert {:error, _} = res
  end

  @tag :skip
  test "wrong coordinates" do
    stream = """
    A01,4error,1
    B01,1,2
    """
    res = Context.Parser.parsing(stream)

    assert {:error, _} = res
  end
end
