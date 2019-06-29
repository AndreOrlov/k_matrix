defmodule Store.Image do
  @moduledoc false

  use GenServer

  def start_link(state \\ {}) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  @impl GenServer
  def init(state) do
    {:ok, state}
  end

  # Client API

  # Загрузить координаты всей картинки
  def put_image_coords(coords) do
    GenServer.cast(__MODULE__, {:put_image_coords, coords})
  end

  # ДСП

  def __leading_row__(row, limit, value \\ "none") when length(row) < limit do
    qty = limit - length(row)
    row ++ List.duplicate(value, qty)
  end

  # Server

  @impl GenServer
  def handle_cast({:put_image_coords, coords}, state) do
    {:noreply, state}
  end
end
