defmodule Context.Tile.Sender do
  @moduledoc false

  alias Context.Tile.Driver
  alias Context.Tile

  def init() do
    __sender__(&__test_leds__/1)
  end

  # coords [[x1, y1], ... ,[xn, yn]]
  def send_coords(coords) do
    __sender__(fn ref ->
      :ok = Driver.lights_on_by_coords(ref, Tile.coord_by_tiles(coords))
    end)
  end

  def __test_leds__(ref) do
    # Проверка исправности диодов
    :ok = Driver.test_on(ref)
    Process.sleep(3000)
    :ok = Driver.test_off(ref)
  end

  # Инициализирует матрицу диодов, формирование SPI команд
  def __sender__(callback) when is_function(callback) do
    {:ok, ref} = Driver.open()

    # Не горят диоды, но команды можно отправлять при ткаом режиме
    :ok = Driver.shutdown(ref)

    # Настройка start

    # Активировать все строки диодов в матрице
    :ok = Driver.activate_rows(ref)

    # Отключить декодирование сегментов (у нас диоды, а не цифровые сегменты)
    :ok = Driver.disable_code(ref)

    # Настройка end

    # Погасить все, ранее включенные диоды
    :ok = Driver.lights_off(ref)

    callback.(ref)

    # Выйти из режима shutdown
    :ok = Driver.resume(ref)

    :ok = Driver.close(ref)
  end
end
