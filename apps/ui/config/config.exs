# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :ui, UiWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "snz4ywLkMgRwqKgPd5dMepH+tIw5iZOI9v7vaf09ZfZJRjP1kHjmIDtcsFt7LhR6",
  render_errors: [view: UiWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Ui.PubSub, adapter: Phoenix.PubSub.PG2]

config :matrix, :dimensions,
  # TODO: rad удалить позже, будет динамическим параметр
  height: 2,
  # TODO: rad удалить позже, будет динамическим параметр
  width: 2,
  tile_rows: 8,
  tile_cols: 8,
  # Очередность следования tiles в эл. схеме матрицы. Расплоложение диодов tile и
  #   порядок соединения микросхем может быть не одинаков.
  # По умолчанию отсчет tiles идет слева направо, сверху вниз, начиная с левого, верхнего угла.
  # Кол-во элементов должно быть равно height * width
  order: [0, 1, 2, 3]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
