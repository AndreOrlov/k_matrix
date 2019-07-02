defmodule Store.Image do
  @moduledoc false

  alias Context.Tile

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

  def build_canvas(coords, matrix_dimensions, default_value \\ "none")

  def build_canvas(coords, {qty_cols, qty_rows}, default_value) do
    {x_max, y_max} = max_value_axis(coords)

    width = measure(x_max, qty_cols)
    height = measure(y_max, qty_rows)

    default_value
    |> List.duplicate(width)
    |> List.duplicate(height)
  end

  def draw_image(canvas, coords) do
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

  # TODO: см. формат в тестах
  def __split_by_matrix(coords, matrix_dims \\ {2, 1})

  def __split_by_matrix(coords, {cols, rows}) do
    for y <- 0..(rows - 1), x <- 0..(cols - 1) do
      # TODO: later rad?
    end
  end

  def __leading_rows__([], _limit), do: []

  def __leading_rows__([head | rows], limit) do
    [__leading_row__(head, limit) | __leading_rows__(rows, limit)]
  end

  def __leading_row__(row, limit, value \\ "none")

  def __leading_row__(row, limit, value) when length(row) < limit do
    qty = limit - length(row)
    row ++ List.duplicate(value, qty)
  end

  defp update_canvas(canvas, [x] = axis, value) when length(axis) == 1 do
    List.update_at(canvas, x, fn _ -> value end)
  end

  defp update_canvas(canvas, [y | tail] = coord, value) do
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
  def handle_cast({:put_image_coords, _coords}, state) do
    {:noreply, state}
  end
end
