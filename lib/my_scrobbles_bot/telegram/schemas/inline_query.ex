defmodule MyScrobblesBot.Telegram.InlineQuery do
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
      field :telegram_id, :string
    end
  end

  embedded_schema do
    field :inline_query_id, :string
    field :chat_type, :string
    field :query, :string
    field :offset, :string

    embeds_one :from, From
  end

  def cast(params) do
    %__MODULE__{}
    |> Changeset.cast(params, [:query, :inline_query_id, :chat_type, :offset])
    |> Changeset.validate_required([:chat_type])
    |> put_inline_query_id()
    |> Changeset.cast_embed(:from, with: &from_changeset/2)
  end

  defp from_changeset(schema, params) do
    schema
    |> Changeset.cast(params, [:first_name, :language_code, :telegram_id, :username])
    |> put_telegram_id()
  end

  defp put_inline_query_id(%Ecto.Changeset{params: params} = changeset) do
    Ecto.Changeset.put_change(
      changeset,
      :inline_query_id,
      Changeset.get_change(changeset, :inline_query_id, params["id"])
    )
  end

  defp put_telegram_id(%Ecto.Changeset{params: params} = changeset) do
    Ecto.Changeset.put_change(
      changeset,
      :telegram_id,
      Changeset.get_change(changeset, :telegram_id, params["id"] |> Integer.to_string())
    )
  end
end
