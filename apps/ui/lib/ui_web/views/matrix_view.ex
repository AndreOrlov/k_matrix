defmodule UiWeb.MatrixView do
  use UiWeb, :view

  # dimensions tile. Tile - отдельная микросхема MAX7219 с матрицей диодов 8 х 8
  @cols Application.get_env(:matrix, :dimensions)[:tile_cols]
  @rows Application.get_env(:matrix, :dimensions)[:tile_rows]

  # matrix in tiles
  @matrix_width Application.get_env(:matrix, :dimensions)[:weight]
  @matrix_height Application.get_env(:matrix, :dimensions)[:height]

  def to_json(data) do
    Jason.encode!(data)
  end

  def render("image.html", opts) do
    matrix_cols = @matrix_width * @cols
    matrix_rows = @matrix_height * @rows

    render_template("image.html", cols: matrix_cols, rows: matrix_rows)
  end
end
