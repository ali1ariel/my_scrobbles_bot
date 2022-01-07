defmodule MyScrobblesBot.Telegram.Consumers.CallbackHandler do
  @moduledoc """
  Stateless GenServer that subscribes to telegram callback queries and
  does something if they require an action
  """
  use GenServer

  require Logger

  alias MyScrobblesBot.Events
  alias MyScrobblesBot.Telegram
  alias MyScrobblesBot.Telegram.CallbackQuery

  def start_link(_), do: GenServer.start_link(__MODULE__, nil)

  @impl true
  def init(_) do
    Logger.info("Starting #{__MODULE__}")

    Phoenix.PubSub.subscribe(
      Application.get_env(:my_scrobbles_bot, :pubsub_channel),
      Events.TelegramCallbackQuery.topic()
    )

    {:ok, nil}
  end

  @impl true
  def handle_info(
        %CallbackQuery{} = callback_query,
        state
      ) do
    Logger.info("#{__MODULE__} handling callback_query")
    # fire and forget, and don't make our genserver stuck
    Task.async(fn -> Telegram.process_callback_query(callback_query) end)

    {:noreply, state}
  end

  def handle_info(_, state), do: {:noreply, state}
end
