defmodule MyScrobblesBot.Telegram.Handlers do
  @moduledoc """
  Behaviour for telegram message handlers.

  Also matches messages with handlers through get_handler/1
  """

  alias MyScrobblesBot.Telegram.Message
  alias MyScrobblesBot.Telegram.Handlers.{DefaultHandler, HelpHandler}

  @callback handle(Message.t()) :: {:ok, term()} | {:error, term()}

  @doc """
  Matches a message with its handler module
  """
  def get_handler(%Message{text: "/help" <> ""}), do: {:ok, HelpHandler}
  def get_handler(_), do: {:ok, DefaultHandler}
end
