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

  # Загрузить координаты всей картинки.
  # ВАЖНО: в загружаемых координатах начало - 1, 1, сохраняем с началом координат 0, 0
  def put_image_coords(coords, matrix_dimensions) do
    GenServer.call(__MODULE__, {:put_image_coords, coords, matrix_dimensions})
  end

  # Получить размерность матрицы. %{qty_cols: qty_cols, qty_rows: qty_rows}
  def matrix_dimensions() do
    GenServer.call(__MODULE__, {:matrix_dimensions})
  end

  # {qty_rows, qty_cols}. Кол-во матриц, в кот. укладывают мозаику
  def qty_matrices() do
    GenServer.call(__MODULE__, {:qty_matrices})
  end

  def points_matrix(y_matrix, x_matrix) do
    GenServer.call(__MODULE__, {:points_matrix, y_matrix, x_matrix})
  end

  def coords_to_integer(y, x), do: coords_to_integer([y, x])

  def coords_to_integer(array) do
    try do
      {:ok, Enum.map(array, &String.to_integer/1)}
    rescue
      ArgumentError -> {:error, "Coordinate is not integer value"}
    end
  end

  # Server

  @impl GenServer
  def handle_call(
        {:put_image_coords, coords, {qty_cols, qty_rows}},
        _from,
        _state
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
  def handle_call({:matrix_dimensions}, _from, state) do
    case state[:matrix_dimensions] do
      nil -> {:reply, {:error, :not_matrix_dimensions}, state}
      res -> {:reply, {:ok, res}, state}
    end
  end

  @impl GenServer
  def handle_call({:qty_matrices}, _from, state) do
    case state[:map_coords] do
      nil ->
        {:reply, {:error, :not_coords}, state}

      _ ->
        res =
          calc_qty_matrices(
            Map.keys(state[:map_coords]),
            state[:matrix_dimensions]
          )

        {:reply, {:ok, res}, state}
    end
  end

  @impl GenServer
  def handle_call({:points_matrix, y_matrix, x_matrix}, _from, state) do
    %{qty_rows: rows, qty_cols: cols} = state[:matrix_dimensions]

    res =
      for y <- (y_matrix * rows)..((y_matrix + 1) * rows - 1),
          x <- (x_matrix * cols)..((x_matrix + 1) * cols - 1) do
        [state[:map_coords][[y, x]] || "none", rem(y, rows), rem(x, cols)]
      end
      |> Enum.reduce(%{}, &group_by_color(&1, &2))

    {:reply, {:ok, res}, state}
  end

  # private

  defp points_to_map(csv_decoded_rows) do
    res =
      csv_decoded_rows
      |> Enum.map(fn {:ok, point} -> point end)
      |> Enum.reduce(%{}, fn [color, x, y], map ->
        {:ok, [x_int, y_int]} = coords_to_integer([x, y])
        # начало кооординат переводим в 0, 0
        Map.put(map, [y_int - 1, x_int - 1], color)
      end)

    {:ok, res}
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

    %{
      qty_rows: round(Float.ceil(y_max / rows)),
      qty_cols: round(Float.ceil(x_max / cols))
    }
  end

  defp group_by_color([color, y, x], matrix) do
    {_, matrix_updated} =
      Map.get_and_update(matrix, color, fn current_value ->
        {
          current_value,
          case current_value do
            nil -> [[y, x]]
            _ -> [[y, x] | current_value]
          end
        }
      end)

    matrix_updated
  end
end
