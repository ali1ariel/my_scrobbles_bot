defmodule MyScrobblesBot.Events.TelegramCallbackQuery do
  @moduledoc """
  Models a telegram message
  """

  alias MyScrobblesBot.Telegram.CallbackQuery

  @behaviour MyScrobblesBot.Events.Event

  @impl true
  def topic(_ \\ nil), do: "myscroblesbot:telegram_callback_query"

  @impl true
  def cast(%CallbackQuery{} = message), do: {:ok, message}

  def cast(params) do
    params
    |> CallbackQuery.cast()
    |> case do
      %{valid?: true} = changeset ->
        {:ok, Ecto.Changeset.apply_changes(changeset)}

      changeset ->
        {:error, changeset}
    end
  end
end
