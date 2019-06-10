defmodule UiWeb.MatrixController do
  use UiWeb, :controller

  def upload_file(conn, _params) do
    # TODO: rad
    Task.Supervisor.async_nolink(Ui.TaskSupervisor, fn -> IO.puts("TEST Task") end)

    render(conn, "upload_file.html")
  end
end
