# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :my_scrobbles_bot,
  ecto_repos: [MyScrobblesBot.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :my_scrobbles_bot, MyScrobblesBotWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "CW+gR9SqU1zimvbG8DDaHoI5DpsZxKiJgMQVS0cWzauNnNZPOGu9B+h9STOH0/ao",
  render_errors: [view: MyScrobblesBotWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: MyScrobblesBot.PubSub,
  live_view: [signing_salt: "fwjvY78k"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason


config :my_scrobbles_bot, pubsub_channel: MyScrobblesBot.PubSub

config :my_scrobbles_bot,
  bot_name: "Boiola bot",
  last_fm_token: "92948e038ad0708dbbed57e977db5fce",
  music_x_match_token: "f1b5674f072c7c7b775118528762ec0d"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
