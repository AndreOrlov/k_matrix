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

  # {qty_rows, qty_cols}. Кол-во матриц, в кот. укладывают мозаику
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
    {res, new_state} =
      with {:ok, map_coords} <- points_to_map(coords) do
        {
          :ok,
          %{
            map_coords: map_coords,
            matrix_dimensions: %{
              qty_cols: qty_cols,
              qty_rows: qty_rows
            }
          }
        }
      else
        _ -> {{:error, :not_loaded}, %{}}
      end

    {:reply, res, new_state}
  end

  @impl GenServer
  def handle_call({:qty_matrices}, _from, state) do
    res =
      calc_qty_matrices(
        Map.keys(state[:map_coords]),
        state[:matrix_dimensions]
      )

    {:reply, {:ok, res}, state}
  end

  # private

  defp points_to_map(csv_decoded_rows) do
    res =
      csv_decoded_rows
      |> Enum.map(fn {:ok, point} -> point end)
      |> Enum.reduce(%{}, fn [color, x, y], map ->
        {:ok, [x_int, y_int]} = coords_to_integer([x, y])
        Map.put(map, [y_int, x_int], color)
      end)

    {:ok, res}
  end

  defp coords_to_integer(array) do
    try do
      {:ok, Enum.map(array, &String.to_integer/1)}
    rescue
      ArgumentError -> {:error, "Coordinate is not integer value"}
    end
  end

  defp find_max(coords, func) do
    coords
    |> Enum.map(&func.(&1))
    |> Enum.max()
  end

  defp calc_qty_matrices(yx_coords, %{qty_rows: rows, qty_cols: cols}) do
    calc_y_max =
      Task.async(fn ->
        find_max(yx_coords, fn [y, _x] -> y end)
      end)

    x_max = find_max(yx_coords, fn [_y, x] -> x end)
    y_max = Task.await(calc_y_max)

    IO.inspect({y_max, x_max}, label: :MAX_YX)

    %{
      qty_rows: round(Float.ceil(y_max / rows)),
      qty_cols: round(Float.ceil(x_max / cols))
    }
  end
end
