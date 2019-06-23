defmodule Context.Tile.Driver do
  alias Context.Tile.Max7219

  defdelegate open, to: Max7219
  defdelegate shutdown(ref), to: Max7219
  defdelegate lights_off(ref), to: Max7219
  defdelegate test_on(ref), to: Max7219
  defdelegate test_off(ref), to: Max7219
  defdelegate activate_rows(ref), to: Max7219
  defdelegate disable_code(ref), to: Max7219
  defdelegate resume(ref), to: Max7219
  defdelegate lights_on_by_coords(ref, coords), to: Max7219
  defdelegate close(ref), to: Max7219
end
