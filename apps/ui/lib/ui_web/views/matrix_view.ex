defmodule UiWeb.MatrixView do
  use UiWeb, :view

  def to_json(data) do
    Jason.encode!(data)
  end

  def from_json(json) do
    Jason.decode!(json)
  end
end
