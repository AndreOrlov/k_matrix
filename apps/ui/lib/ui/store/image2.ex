defmodule Store.Image2 do
  @moduledoc false

  use GenServer

  def start_link(_state) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl GenServer
  def init(state) do
    {:ok, state}
  end

  # Client API

  # Загрузить координаты всей картинки
  def put_image_coords(coords, matrix_dimensions) do
    GenServer.call(__MODULE__, {:put_image_coords, coords, matrix_dimensions})
  end

  def qty_matrices() do
    GenServer.call(__MODULE__, {:qty_matrices})
  end

  # Server

  @impl GenServer
  def handle_call(
        {:put_image_coords, coords, {qty_cols, qty_rows} = matrix_dimensions},
        _from,
        state
      ) do
    {:reply, {:ok, {}}, state}
  end

  @impl GenServer
  def handle_call({:qty_matrices}, _from, state) do
    # {:reply, {:ok, state[:qty_matrices]}, state}
    {
      :reply,
      {
        :ok,
        %{
          qty_cols: 3,
          qty_rows: 2
        }
      },
      state
    }
  end
end
