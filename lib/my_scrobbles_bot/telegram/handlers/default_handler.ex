defmodule MyScrobblesBot.Telegram.Handlers.DefaultHandler do
  @moduledoc """
  Just logs the message
  """

  require Logger

  alias MyScrobblesBot.Telegram.Message

  @behaviour MyScrobblesBot.Telegram.Handlers

  @impl true
  def handle(%Message{message_id: id}) do

    {:ok, nil}
  end
end
