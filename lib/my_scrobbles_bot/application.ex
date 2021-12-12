defmodule MyScrobblesBot.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      MyScrobblesBot.Repo,
      # Start the Telemetry supervisor
      MyScrobblesBotWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: MyScrobblesBot.PubSub},
      # Start the consumer for telegram messages
      MyScrobblesBot.Telegram.Consumers.MessageHandler,
      # Start the Endpoint (http/https)
      MyScrobblesBotWeb.Endpoint
      # Start a worker by calling: MyScrobblesBot.Worker.start_link(arg)
      # {MyScrobblesBot.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MyScrobblesBot.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    MyScrobblesBotWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
