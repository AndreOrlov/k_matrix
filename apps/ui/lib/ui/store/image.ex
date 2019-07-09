defmodule Store.Image do
  @moduledoc false

  alias Context.Tile
  alias Context.Tile.Helpers

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

  # TODO: rad
  # def map_to_list(map_coords, acc) do
  #   map_coords
  #   |> Enum.map(fn
  #     {k, %{} = map} ->
  #       map_to_list(map, [k | acc])

  #     {k, val} ->
  #       [val | [k | acc]]
  #   end)
  # end

  # def map_to_list(max_coords) do
  #   max_coords
  #   |> map_to_list([])
  #   |> Helpers.List.flatten(3)
  # end

  # ДСП

  def __build_canvas__(coords, matrix_dimensions, default_value \\ "none")

  def __build_canvas__(coords, {qty_cols, qty_rows}, default_value) do
    {x_max, y_max} = max_value_axis(coords)

    # 0 based ingex coords
    width = measure(x_max + 1, qty_cols)
    height = measure(y_max + 1, qty_rows)

    default_value
    |> List.duplicate(width)
    |> List.duplicate(height)
  end

  def __draw_image__(canvas, coords) do
    {:ok, pid} = Agent.start_link(fn -> canvas end)

    coords
    |> Map.keys()
    |> Enum.each(fn color ->
      coords[color]
      |> Enum.each(fn [y, x] ->
        cur_canvas = Agent.get(pid, & &1)
        updated_canvas = update_canvas(cur_canvas, [y, x], color)
        Agent.update(pid, fn _ -> updated_canvas end)
      end)
    end)

    picture = Agent.get(pid, & &1)
    :ok = Agent.stop(pid)

    picture
  end

  def __split_by_matrix__(picture, dimensions_matrix) do
    width = length(Enum.at(picture, 0))
    height = length(picture)

    for y <- 0..(height - 1), x <- 0..(width - 1) do
      color =
        Enum.at(
          Enum.at(picture, y),
          x
        )

      coords_to_matrix(y, x, color, dimensions_matrix)
    end
    |> Enum.reduce(%{}, fn map, acc ->
      Helpers.Map.deep_merge(acc, map)
    end)
  end

  # private

  defp coords_to_matrix(y, x, color, {qty_cols, qty_rows}) do
    {:div, y_matrix, :rem, y_in_matrix} = Tile.div_rem(y, qty_rows)
    {:div, x_matrix, :rem, x_in_matrix} = Tile.div_rem(x, qty_cols)

    coords_color = [y_matrix, x_matrix, y_in_matrix, x_in_matrix, color]
    convert_to_map(coords_color)
  end

  defp convert_to_map([color | []]), do: color

  defp convert_to_map([axis | coords_color], map \\ %{}) do
    Map.put(map, axis, convert_to_map(coords_color))
  end

  defp update_canvas(canvas, [x] = axis, value) when length(axis) == 1 do
    List.update_at(canvas, x, fn _ -> value end)
  end

  defp update_canvas(canvas, [y | tail], value) do
    List.update_at(canvas, y, fn _ ->
      update_canvas(Enum.at(canvas, y), tail, value)
    end)
  end

  defp max_value_axis(coords) do
    coords
    |> Map.values()
    |> List.flatten()
    |> Enum.chunk_every(2)
    |> max_coords()
  end

  defp measure(dividend, divisor) do
    case Tile.div_rem(dividend, divisor) do
      {:div, 0, :rem, _rem} -> divisor
      {:div, div, :rem, 0} -> divisor * div
      {:div, div, :rem, _rem} -> divisor * (div + 1)
    end
  end

  defp max_coords(coords) do
    x_max = Enum.max(Enum.map(coords, &Enum.at(&1, 0)))
    y_max = Enum.max(Enum.map(coords, &Enum.at(&1, 1)))

    {x_max, y_max}
  end

  # Server

  @impl GenServer
  def handle_call(
        {:put_image_coords, coords, {qty_cols, qty_rows} = matrix_dimensions},
        _from,
        state
      ) do
    picture =
      __build_canvas__(coords, matrix_dimensions)
      |> __draw_image__(coords)
      |> __split_by_matrix__(matrix_dimensions)

    new_state =
      state
      |> Map.put(:picture, picture)
      |> Map.put(:matrix_dimensions, %{qty_cols: qty_cols, qty_rows: qty_rows})
      |> Map.put(
        :qty_matrices,
        %{
          qty_cols: map_size(picture[0]),
          qty_rows: map_size(picture)
        }
      )

    {:reply, {:ok, picture}, new_state}
  end

  @impl GenServer
  def handle_call({:qty_matrices}, _from, state) do
    {:reply, {:ok, state[:qty_matrices]}, state}
  end
end
