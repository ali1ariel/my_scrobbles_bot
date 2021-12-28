defmodule MyScrobblesBot.Telegram.Handlers.InlineQueryCommandHandler do
  @moduledoc """
  Just logs the message
  """

  require Logger

  alias MyScrobblesBot.Telegram.InlineQuery
  alias MyScrobblesBotWeb.Services.Telegram

  @behaviour MyScrobblesBot.Telegram.Handlers

  @impl true
  def handle(%InlineQuery{query: "/" <> _command = _query} = inline_query) do

    # {:ok, nil}
    %{
      inline_query_id: inline_query.inline_query_id,
      results: [
        %{
          type: "article",
          title: "okay",
          input_message_content: %{
            parse_mode: "HTML",
            message_text: "okay"
          },
          description: "this is <b>just</b> a <i>sample</i> message",
          id: "1",
        },%{
          type: "article",
          title: "okay2",
          description: "this is <b>just</b> a <i>sample</i> message",
          input_message_content: %{
            parse_mode: "HTML",
            message_text: "okay"
          },
          id: "2",
        }
      ],
      is_personal: true
    }
    |> Telegram.send_inline()
  end
end
