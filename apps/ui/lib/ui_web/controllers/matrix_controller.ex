defmodule UiWeb.MatrixController do
  use UiWeb, :controller

  alias Store.Image

  def upload_file(conn, _params) do
    render(conn, "upload_file.html", token: get_csrf_token())
  end

  def matrices(conn, %{"fileToUpload" => %Plug.Upload{path: path}, "dim_matrices" => dims}) do
    with {:ok, [matrix_rows, matrix_cols]} <- get_dims(dims),
         {:ok, coords} <-
           path
           |> path_to_stream()
           |> Context.Parser.parsing(),
         :ok <- validate_matrix(coords),
         :ok <- Image.put_image_coords(coords, {matrix_rows, matrix_cols}),
         {:ok, %{qty_cols: qty_cols, qty_rows: qty_rows}} <- Image.qty_matrices() do
      render(conn, "matrices.html",
        cols: qty_cols,
        rows: qty_rows
      )
    else
      {:error, :empty} ->
        conn
        |> put_flash(:error, "Error file is empty")
        |> redirect(to: "/matrix")

      {:error, _} ->
        conn
        |> put_flash(:error, "Error file parsing")
        |> redirect(to: "/matrix")
    end
  end

  def matrices(conn, _params) do
    with {:ok, %{qty_cols: qty_cols, qty_rows: qty_rows}} <- Image.qty_matrices() do
      render(conn, "matrices.html",
        cols: qty_cols,
        rows: qty_rows
      )
    else
      _ ->
        conn
        |> put_flash(:error, "File not choice or data corrupt. Please, reupload file")
        |> redirect(to: "/matrix")
    end
  end

  def colors(conn, %{"r" => y_matrix, "c" => x_matrix, "color" => color}) do
    with {:ok, [y, x]} <- Image.coords_to_integer(y_matrix, x_matrix),
         {:ok, matrix} <- Image.points_matrix(y, x),
         coords = matrix[color],
         light_on(coords) do
      render(
        conn,
        "colors.html",
        token: get_csrf_token(),
        y_matrix: y,
        x_matrix: x,
        matrix: matrix,
        cur_color: color,
        coords: coords
      )
    else
      _ ->
        conn
        |> put_flash(:error, "Error matrix coords")
        |> redirect(to: "/matrix")
    end
  end

  def colors(conn, %{"r" => y_matrix, "c" => x_matrix}),
    do: colors(conn, %{"r" => y_matrix, "c" => x_matrix, "color" => nil})

  def colors(conn, _params) do
    conn
    |> put_flash(:error, "Error choice file")
    |> redirect(to: "/matrix")
  end

  # private

  defp path_to_stream(path) do
    path
    |> Path.expand(__DIR__)
    |> File.stream!()
  end

  defp validate_matrix(coords) do
    # check length matrix
    case length(coords) do
      n when n > 0 -> :ok
      n when n == 0 -> {:error, :empty}
    end
  end

  # coords [[x1, y1], ... ,[xn, yn]]
  defp light_on(coords) do
    Context.Matrix.send_coords(coords)
  end

  defp get_dims(str) do
    String.split(str, ":")
    |> Image.coords_to_integer()
  end
end
