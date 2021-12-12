defmodule MyScrobblesBot.Telegram do

  require Logger

  alias MyScrobblesBot.Telegram.Message
  alias MyScrobblesBot.Events


  def build_message(params) do
    params
    |> Message.cast()
    |> case do
      %Ecto.Changeset{valid?: true} = changeset ->
        {:ok, Ecto.Changeset.apply_changes(changeset)}

      changeset ->
        {:error, changeset}
    end
  end


  @doc """
  Processes a message with its handler
  """
  def process_message(%Message{} = m) do
    IO.puts " here guys"
    with {:ok, handler} <- MyScrobblesBot.Telegram.Handlers.get_handler(m) do
      Logger.info("Processing message #{inspect(m.message_id)} with handler #{inspect(handler)}")
      handler.handle(m)
    end
  end

  @doc """
  Enqueues processing for a message

  Publishes it as an event in the pubsub
  """
  def enqueue_processing!(%Message{} = m) do
    Events.publish!(Events.TelegramMessage, m)
  end

end
