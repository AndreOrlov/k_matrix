defmodule UiWeb.MatrixView do
  use UiWeb, :view

  def to_json(data) do
    Jason.encode!(data)
  end

  def render("image.html", opts) do
    opts
    render_template("image.html", opts)
  end
end
