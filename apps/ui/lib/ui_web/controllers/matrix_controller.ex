defmodule UiWeb.MatrixController do
  use UiWeb, :controller

  def upload_file(conn, params) do
    # TODO: rad
    Task.Supervisor.async_nolink(Ui.TaskSupervisor, fn -> IO.puts("TEST Task") end)

    IO.inspect(conn, label: "CONN")
    IO.inspect(params, label: "PAPAMS")

    render(conn, "upload_file.html", token: get_csrf_token())
  end

  def colors(conn, params) do
    # TODO: rad
    IO.inspect(conn, label: "CONN_COLORS")
    IO.inspect(params, label: "PAPAMS_COLORS")
    matrix = %{"A01" => [[1, 1], [1, 2]], "B01" => [[1, 3]]}

    render(conn, "colors.html", token: get_csrf_token(), matrix: matrix)
  end
end
