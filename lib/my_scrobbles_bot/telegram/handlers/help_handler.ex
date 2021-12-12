defmodule MyScrobblesBot.Telegram.Handlers.HelpHandler do
  @moduledoc """
  Sends a simple help message
  """

  alias MyScrobblesBot.Telegram.{Client, Message}
  @behaviour MyScrobblesBot.Telegram.Handlers

  def handle(%Message{chat_id: c_id, message_id: m_id}) do
    %{
      chat_id: c_id,
      reply_to_message_id: m_id,
      text: "this is just a sample message"
    }
    |> Client.send_message()
  end
end
