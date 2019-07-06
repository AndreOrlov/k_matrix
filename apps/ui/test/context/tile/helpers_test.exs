defmodule Context.Tile.HelpersTest do
  use ExUnit.Case

  alias Context.Tile.Helpers

  describe "Context.Tile.Helpers.Map" do
    test 'one level of maps without conflict' do
      result = Helpers.Map.deep_merge(%{a: 1}, %{b: 2})
      assert result == %{a: 1, b: 2}
    end

    test 'two levels of maps without conflict' do
      result = Helpers.Map.deep_merge(%{a: %{b: 1}}, %{a: %{c: 3}})
      assert result == %{a: %{b: 1, c: 3}}
    end

    test 'three levels of maps without conflict' do
      result = Helpers.Map.deep_merge(%{a: %{b: %{c: 1}}}, %{a: %{b: %{d: 2}}})
      assert result == %{a: %{b: %{c: 1, d: 2}}}
    end

    test 'non-map value in left' do
      result = Helpers.Map.deep_merge(%{a: 1}, %{a: %{b: 2}})
      assert result == %{a: %{b: 2}}
    end

    test 'non-map value in right' do
      result = Helpers.Map.deep_merge(%{a: %{b: 1}}, %{a: 2})
      assert result == %{a: 2}
    end

    test 'non-map value in both' do
      result = Helpers.Map.deep_merge(%{a: 1}, %{a: 2})
      assert result == %{a: 2}
    end
  end
end
