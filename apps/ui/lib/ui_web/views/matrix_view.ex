defmodule UiWeb.MatrixView do
  use UiWeb, :view

  alias Store.Image2, as: Image

  # dimensions tile. Tile - отдельная микросхема MAX7219 с матрицей диодов 8 х 8
  @cols Application.get_env(:matrix, :dimensions)[:tile_cols]
  @rows Application.get_env(:matrix, :dimensions)[:tile_rows]

  def to_json(data) do
    Jason.encode!(data)
  end

  def render("image.html", %{coords: coords}) do
    {:ok, %{qty_cols: matrix_width, qty_rows: matrix_height}} = Image.matrix_dimensions()

    qty_cols = matrix_width
    qty_rows = matrix_height
    quad_size = 10
    borders_width = 2

    {table_width, table_height} = table_dimensions(qty_cols, qty_rows, quad_size)

    render_template(
      "image.html",
      table_width: table_width,
      table_height: table_height,
      cols: qty_cols,
      rows: qty_rows,
      coords: coords
    )
  end

  # Возвращает ширину и высоту  таблицы в пикселах
  def table_dimensions(qty_cols, qty_rows, quad_size) do
    borders_width = 2

    table_width = qty_cols * quad_size + borders_width
    table_height = qty_rows * quad_size + borders_width

    {table_width, table_height}
  end

  def has_coords(coords, %{y: y, x: x}) do
    Enum.find_value(coords, &(&1 == [y, x]))
  end

  def uri_encode(path, list_params) do
    path <> "?" <> URI.encode_query(list_params)
  end
end
