defmodule UiWeb.MatrixController do
  use UiWeb, :controller

  alias Store.Image2, as: Image

  def upload_file(conn, _params) do
    render(conn, "upload_file.html", token: get_csrf_token())
  end

  def matrices(conn, %{"fileToUpload" => %Plug.Upload{path: path}}) do
    with {:ok, coords} <-
           path
           |> path_to_stream()
           |> Context.Parser.parsing(),
         :ok <- validate_matrix(coords),
         :ok <- Image.put_image_coords(coords, {2, 2}),
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

  def colors(conn, %{"coords" => coords_json, "matrix" => matrix_json}) do
    with {:ok, coords} <- Jason.decode(coords_json),
         {:ok, matrix} <- Jason.decode(matrix_json),
         light_on(coords) do
      render(conn, "colors.html",
        token: get_csrf_token(),
        matrix: matrix,
        choiced: key_from_value(coords, matrix),
        coords: coords
      )
    else
      {:error, _} ->
        conn
        |> put_flash(:error, "Error json coords decode")
        |> redirect(to: "/matrix")
    end
  end

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
end
