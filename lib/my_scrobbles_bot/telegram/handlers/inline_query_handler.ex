defmodule MyScrobblesBot.Telegram.Handlers.InlineQueryHandler do
  @moduledoc """
  Just logs the message
  """

  require Logger

  alias MyScrobblesBot.Telegram.InlineQuery
  alias MyScrobblesBotWeb.Services.Telegram

  @behaviour MyScrobblesBot.Telegram.Handlers

  @impl true
  def handle(%InlineQuery{query: query} = inline_query) do
    Logger.info("Received and ignored message #{inline_query.inline_query_id} - #{query}")

    # {:ok, nil}
    %{
      chat_id: inline_query.inline_query_id,
      text: "this is *just* a _sample_ message",
      parse_mode: "markdown"
    }
    |> Telegram.send_inline()
  end
end
