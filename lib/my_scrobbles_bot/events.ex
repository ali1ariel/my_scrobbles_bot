defmodule MyScrobblesBot.Events do
  @moduledoc """
  Provides the interface to publish events in te pubsub and manages supported
  events
  """

  require Logger

  alias Phoenix.PubSub

  @events [
    MyScrobblesBot.Events.TelegramMessage,
    MyScrobblesBot.Events.TelegramInlineQuery,
    MyScrobblesBot.Events.TelegramCallbackQuery
  ]

  @doc """
  Publishes a message in the pubsub
  """
  def publish!(event_module, input) when event_module in @events do
    Logger.info("Publishing in #{inspect(event_module)}")

    PubSub.broadcast(
      pubsub_channel(),
      event_module.topic(input),
      coerce!(event_module, input)
    )
  end

  defp coerce!(event_module, input) do
    case event_module.cast(input) do
      {:ok, data} ->
        data

      error ->
        raise ArgumentError, "invalid input given for #{event_module}, failed
        with error #{inspect(error)}"
    end
  end

  defp pubsub_channel, do: Application.get_env(:my_scrobbles_bot, :pubsub_channel)
end
