defmodule MyScrobblesBot.Events.TelegramInlineQuery do
  @moduledoc """
  Models a telegram message
  """

  alias MyScrobblesBot.Telegram.InlineQuery

  @behaviour MyScrobblesBot.Events.Event

  @impl true
  def topic(_ \\ nil), do: "myscroblesbot:telegram_inline_query"

  @impl true
  def cast(%InlineQuery{} = message), do: {:ok, message}

  def cast(params) do
    params
    |> InlineQuery.cast()
    |> case do
      %{valid?: true} = changeset ->
        {:ok, Ecto.Changeset.apply_changes(changeset)}

      changeset ->
        {:error, changeset}
    end
  end
end
