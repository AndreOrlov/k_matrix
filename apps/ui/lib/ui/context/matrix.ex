defmodule Context.Matrix do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl GenServer
  def init(:ok) do
    Context.Tile.init()

    {:ok, :ok}
  end

  # Client API

  def send_coords(coords) do
    GenServer.cast(__MODULE__, {:send_coords, coords})
  end

  # Server

  @impl GenServer
  def handle_cast({:send_coords, coords}, state) do
    :ok = Context.Tile.send_coords(coords)

    {:noreply, state}
  end
end
