defmodule MyScrobblesBot.Telegram.Message do
  @moduledoc """
  Representation of a message
  """
  use Ecto.Schema

  alias Ecto.Changeset

  # maybe move this soon?
  defmodule From do
    use Ecto.Schema

    embedded_schema do
      field :username, :string
      field :first_name, :string
      field :language_code, :string
      field :telegram_id, :integer
    end
  end

  embedded_schema do
    field :message_id, :integer
    field :chat_id, :integer
    field :chat_type, :string
    field :text, :string

    embeds_one :from, From

    embeds_one :reply_to_message, ReplyToMessage do
      field :chat_id, :integer
      field :chat_type, :string
      field :chat_first_name, :string
      field :message_id, :integer
      field :text, :string
      embeds_one :from, From
    end
  end

  def cast(params) do
    %__MODULE__{}
    |> Changeset.cast(params, [:text, :message_id, :chat_id, :chat_type])
    |> Changeset.validate_required([:text, :message_id])
    |> put_chat_id()
    |> Changeset.cast_embed(:from, with: &from_changeset/2)
    |> Changeset.cast_embed(:reply_to_message, with: &reply_to_message_changeset/2)
  end

  defp reply_to_message_changeset(schema, params) do
    schema
    |> Changeset.cast(params, [:text, :message_id, :chat_id, :chat_type, :chat_first_name])
    |> Changeset.validate_required([:text, :message_id])
    |> put_chat_id()
    |> Changeset.cast_embed(:from, with: &from_changeset/2)
  end

  defp from_changeset(schema, params), do: Changeset.cast(schema, params, [:first_name, :language_code, :telegram_id, :username])

  defp put_chat_id(%Ecto.Changeset{params: params} = changeset) do
    Ecto.Changeset.put_change(
      changeset,
      :chat_id,
      Changeset.get_change(changeset, :chat_id, params["chat"]["id"])
    )
  end
end
