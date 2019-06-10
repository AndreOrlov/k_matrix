defmodule UiWeb.MatrixController do
  use UiWeb, :controller

  def upload_file(conn, params) do
    # TODO: rad
    # Task.Supervisor.async_nolink(Ui.TaskSupervisor, fn -> IO.puts("TEST Task") end)

    render(conn, "upload_file.html", token: get_csrf_token())
  end

  def colors(conn, %{"coords" => coords_json, "matrix" => matrix_json} = params) do
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

  def colors(conn, %{"fileToUpload" => %Plug.Upload{path: path}} = params) do
    with {:ok, matrix} <-
           path
           |> path_to_stream()
           |> Context.Parser.parsing() do
      render(conn, "colors.html", token: get_csrf_token(), matrix: matrix, choiced: nil)
    else
      {:error, _} -> render(conn, "upload_file.html", token: get_csrf_token())
    end
  end

  defp key_from_value(value, matrix) do
    case Enum.find(matrix, fn {_key, val} -> val == value end) do
      {key, _} -> key
      _ -> nil
    end
  end

  defp path_to_stream(path) do
    path
    |> Path.expand(__DIR__)
    |> File.stream!()
  end
end
