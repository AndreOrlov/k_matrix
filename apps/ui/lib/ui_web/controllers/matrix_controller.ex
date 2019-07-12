defmodule UiWeb.MatrixController do
  use UiWeb, :controller

  import Store.Image2, only: [coords_to_integer: 1]

  alias Store.Image2, as: Image

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
         {:ok, %{qty_cols: qty_cols, qty_rows: qty_rows} = probe} <- Image.qty_matrices(),
         IO.inspect(probe, label: :QTY_MATRICES) do
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

  def matrices(conn, %{"fileToUpload" => file}) do
    conn
    |> put_flash(:error, "Choice file")
    |> redirect(to: "/matrix")
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
         {:ok, matrix} <- Image.points_matrix(y, x) do
      render(
        conn,
        "colors.html",
        token: get_csrf_token(),
        y_matrix: y,
        x_matrix: x,
        matrix: matrix,
        cur_color: color,
        coords: matrix[color]
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

  defp key_from_value(value, matrix) do
    case Enum.find(matrix, fn {_key, val} -> val == value end) do
      {key, _} -> key
      _ -> nil
    end
  end

  defp key_first_element(matrix) do
    matrix
    |> Map.keys()
    |> List.first()
  end

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
    |> coords_to_integer()
  end
end
