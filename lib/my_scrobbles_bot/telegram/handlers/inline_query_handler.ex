defmodule MyScrobblesBot.Telegram.Handlers.CallbackQueryHandler do
  @moduledoc """
  Just logs the message
  """

  require Logger

  alias MyScrobblesBot.Telegram.CallbackQuery
  alias MyScrobblesBotWeb.Services.Telegram

  @behaviour MyScrobblesBot.Telegram.Handlers

  @impl true
  def handle(%CallbackQuery{data: data} = callback_query) do
    IO.inspect callback_query
    Logger.info("Received and ignored message #{callback_query.callback_query_id} - #{data}")

    # {:ok, nil}
    %{
      chat_id: callback_query.from.telegram_id,
      text: "this is <b>just</b> a <i>sample</i> message - #{data}",
      parse_mode: "HTML"
    }
    |> Telegram.send_message()
  end
end
