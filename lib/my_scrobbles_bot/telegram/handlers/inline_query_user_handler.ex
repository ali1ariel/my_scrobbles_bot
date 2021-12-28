defmodule MyScrobblesBot.Telegram.Handlers.InlineQueryUserHandler do
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
      input_message_content: %{
        text: "this is <b>just</b> a <i>sample</i> message",
        parse_mode: "HTML"
      }
    }
    |> Telegram.send_inline()
  end
end
