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

  def render("image.html", %{coords: coords}) do
    # TODO: вынести в виде структуры аттрибута модуля этого
    matrix_cols = @matrix_width * @cols
    matrix_rows = @matrix_height * @rows
    quad_size = 10
    borders_width = 2

    table_width = matrix_cols * quad_size + borders_width
    table_height = matrix_rows * quad_size + borders_width

    render_template(
      "image.html",
      table_width: table_width,
      table_height: table_height,
      cols: matrix_cols,
      rows: matrix_rows,
      coords: coords
    )
  end

  def has_coords(coords, %{x: x, y: y}) do
    Enum.find_value(coords, &(&1 == [x, y]))
  end
end
