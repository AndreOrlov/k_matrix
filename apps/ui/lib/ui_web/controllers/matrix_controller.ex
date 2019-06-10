defmodule UiWeb.MatrixController do
  use UiWeb, :controller

  def upload_file(conn, params) do
    # TODO: rad
    Task.Supervisor.async_nolink(Ui.TaskSupervisor, fn -> IO.puts("TEST Task") end)

    IO.inspect(conn, label: "CONN")
    IO.inspect(params, label: "PAPAMS")

    render(conn, "upload_file.html", token: get_csrf_token())
  end

  def colors(conn, %{"coords" => coords_json, "matrix" => matrix_json} = params) do
    IO.inspect(params, label: "PAPAMS_COLORS_2")

    with {:ok, coords} <- Jason.decode(coords_json),
         {:ok, matrix} <- Jason.decode(matrix_json) do
      render(conn, "colors.html",
        token: get_csrf_token(),
        matrix: matrix,
        choiced: key_from_value(coords, matrix)
      )
    else
      _ -> render(conn, "upload_file.html", token: get_csrf_token())
    end
  end

  def colors(conn, params) do
    # TODO: rad
    matrix = %{"A01" => [[1, 1], [1, 2]], "B01" => [[1, 3]]}
    IO.inspect(conn, label: "CONN_COLORS")
    IO.inspect(params, label: "PAPAMS_COLORS")

    render(conn, "colors.html", token: get_csrf_token(), matrix: matrix, choiced: nil)
  end

  defp key_from_value(value, matrix) do
    case Enum.find(matrix, fn {_key, val} -> val == value end) do
      {key, _} -> key
      _ -> nil
    end
  end
end
