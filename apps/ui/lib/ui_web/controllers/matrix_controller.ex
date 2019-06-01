defmodule UiWeb.MatrixController do
  use UiWeb, :controller

  def upload_file(conn, _params) do
    render(conn, "upload_file.html")
  end
end
