defmodule MyScrobblesBot.Telegram.Consumers.InlineHandler do
  @moduledoc """
  Stateless GenServer that subscribes to telegram inline queries and
  does something if they require an action
  """
  use GenServer

  require Logger

  alias MyScrobblesBot.Events
  alias MyScrobblesBot.Telegram
  alias MyScrobblesBot.Telegram.InlineQuery

  def start_link(_), do: GenServer.start_link(__MODULE__, spawn_opt: [fullsweep_after: 10])

  @impl true
  def init(_) do
    Logger.info("Starting #{__MODULE__}")

    Phoenix.PubSub.subscribe(
      Application.get_env(:my_scrobbles_bot, :pubsub_channel),
      Events.TelegramInlineQuery.topic()
    )

    {:ok, nil}
  end

  @impl true
  def handle_info(
        %InlineQuery{} = inline_query,
        state
      ) do
    Logger.info("#{__MODULE__} handling inline_query")
    # fire and forget, and don't make our genserver stuck
    Task.async(fn -> Telegram.process_inline_query(inline_query) end)

    {:noreply, state}
  end

  def handle_info(_, state), do: {:noreply, state}
end
