defmodule Context.Tile do
  alias Context.Tile.Driver

  # dimensions tile. Tile - отдельная микросхема MAX7219 с матрицей диодов 8 х 8
  @cols Application.get_env(:matrix, :dimensions)[:tile_cols]
  @rows Application.get_env(:matrix, :dimensions)[:tile_rows]

  # matrix in tiles
  @matrix_width Application.get_env(:matrix, :dimensions)[:weight]
  @matrix_height Application.get_env(:matrix, :dimensions)[:height]

  # Инициализирует матрицу диодов, формирование SPI команд
  # coords [[x1, y1], ... ,[xn, yn]]
  def run(coords) do
    {:ok, ref} = Driver.open()
    :ok = Driver.shutdown(ref)
    :ok = Driver.lights_off(ref)
    :ok = Driver.test_on(ref)

    Process.sleep(3000)

    :ok = Driver.test_off(ref)
    :ok = Driver.activate_rows(ref)
    :ok = Driver.disable_code(ref)
    :ok = Driver.resume(ref)

    :ok = Driver.lights_on_by_coords(ref, __coord_by_tiles__(coords))

    :ok = Driver.close(ref)
  end

  defmacro is_valid_coord(x, y) do
    quote do
      is_integer(unquote(x)) and
        is_integer(unquote(y)) and
        unquote(x) > 0 and
        unquote(y) > 0 and
        unquote(x) <= @cols * @matrix_width and
        unquote(y) <= @rows * @matrix_height
    end
  end

  # Params x, y координаты по всей матрице, с началом координат [1, 1]
  # На выходе [[[y1, x1], ..., [yi, xi]], ..., [n_tiles]] - координаты во всей матрице,
  #   разбитые по tiles, с началом координат [0, 0],
  #   координаты поменяны местами [y, x]
  def __coord_by_tiles__(x, y) when is_valid_coord(x, y) do
    {:div, x_div, :rem, x_rem} = div_rem((x - 1), @cols)
    {:div, y_div, :rem, y_rem} = div_rem((y - 1), @rows)

    for y_tile <- 0..(@matrix_height - 1), x_tile <- 0..(@matrix_width - 1) do
      case {y_tile, x_tile} do
        {^y_div, ^x_div} -> [y_rem, x_rem]
        _ -> nil
      end
    end
  end

  # coords [[x1, y1], ...,[xn, yn]], координаты в каждом tile.
  def __coord_by_tiles__([[_, _] | _] = coords) do
    coords
    |> Enum.map(fn [x, y] -> __coord_by_tiles__(x, y) end)
    |> Context.Tile.Helpers.transpose
    |> Enum.map(fn coords_tile ->
      Enum.filter(coords_tile, & &1)
    end)
  end

  defp div_rem(dividend, divisor),
    do: {:div, div(dividend, divisor), :rem, rem(dividend, divisor)}
end
