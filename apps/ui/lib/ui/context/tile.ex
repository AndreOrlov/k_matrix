defmodule Context.Tile do
  @moduledoc false

  # dimensions tile. Tile - отдельная микросхема MAX7219 с матрицей диодов 8 х 8
  @cols Application.get_env(:matrix, :dimensions)[:tile_cols]
  @rows Application.get_env(:matrix, :dimensions)[:tile_rows]

  # matrix in tiles
  @matrix_width Application.get_env(:matrix, :dimensions)[:width]
  @matrix_height Application.get_env(:matrix, :dimensions)[:height]

  # Очередность следования tiles в эл. схеме матрицы. Подробности в config.exs
  @order_tiles Application.get_env(:matrix, :dimensions)[:order]

  # Compile time validations

  len = length(@order_tiles)

  length(Enum.uniq(@order_tiles)) == len ||
    raise "@order_tiles has duplicate"

  len == @matrix_width * @matrix_height ||
    raise "Length @order_tiles not equal (@matrix_width * @matrix_height)"

  {min, max} = Enum.min_max(@order_tiles)

  (min == 0 && max < len) ||
    raise "@order_tiles min(#{min}), max(#{max}) out of range 0..#{len - 1}"

  # validations end

  defmacro is_valid_coord(y, x) do
    quote do
      is_integer(unquote(y)) and
        is_integer(unquote(x)) and
        unquote(y) >= 0 and
        unquote(x) >= 0 and
        unquote(y) < @cols * @matrix_height and
        unquote(x) < @rows * @matrix_width
    end
  end

  # Params y, x координаты по всей матрице, с началом координат [0, 0]
  # На выходе [[[y1, x1], ..., [yi, xi]], ..., [n_tiles]] - координаты во всей матрице,
  #   разбитые по tiles
  def coord_by_tiles(y, x, height \\ @matrix_height, width \\ @matrix_width)

  def coord_by_tiles(y, x, height, width) when is_valid_coord(y, x) do
    {:div, x_div, :rem, x_rem} = div_rem(x, @cols)
    {:div, y_div, :rem, y_rem} = div_rem(y, @rows)

    for y_tile <- 0..(height - 1), x_tile <- 0..(width - 1) do
      case {y_tile, x_tile} do
        {^y_div, ^x_div} -> [y_rem, x_rem]
        _ -> nil
      end
    end
  end

  # coords [[y1, x1], ...,[yn, xn]], координаты в каждом tile
  def coord_by_tiles([[_, _] | _] = coords) do
    coords
    |> Enum.map(fn [y, x] -> coord_by_tiles(y, x) end)
    |> Context.Tile.Helpers.transpose()
    |> Enum.map(fn coords_tile ->
      Enum.filter(coords_tile, & &1)
    end)
    |> sort_tiles()
  end

  defp sort_tiles(coord_by_tiles, order \\ @order_tiles)
  defp sort_tiles(_coord_by_tiles, []), do: []

  defp sort_tiles(coord_by_tiles, [head | tail]) do
    [Enum.at(coord_by_tiles, head) | sort_tiles(coord_by_tiles, tail)]
  end

  def div_rem(dividend, divisor),
    do: {:div, div(dividend, divisor), :rem, rem(dividend, divisor)}
end
