defmodule MyScrobblesBot.Telegram.ClientInputs.SendMessageWithMarkup do
  @moduledoc false

  use MyScrobblesBot.Telegram.ClientInputs

  alias Ecto.Changeset

  defmodule InlineKeyboardButton do
    use Ecto.Schema
    @derive Jason.Encoder

    embedded_schema do
      field :text, :string
      field :url, :string
      field :callback_data, :string
    end
  end

  defmodule InlineKeyboardMarkup do
    use Ecto.Schema
    @derive Jason.Encoder

    embedded_schema do
      field :inline_keyboard, {:array, {:array, :map}}
      # embeds_many :inline_keyboard, InlineKeyboardButton
    end
  end

  embedded_schema do
    field :chat_id, :integer
    field :text, :string
    field :parse_mode, :string
    field :caption_entities, {:array, :map}
    field :disable_web_page_preview, :boolean
    field :disable_notification, :boolean
    field :reply_to_message_id, :string
    field :allow_sending_without_reply, :boolean
    field :reply_markup, :map
  end

  @impl true
  def cast(params) do
    %__MODULE__{}
    |> Changeset.cast(params, __schema__(:fields))
    |> Changeset.validate_required([:chat_id, :text])
    |> put_chat_id()
  end

  defp put_chat_id(%Ecto.Changeset{params: params} = changeset) do
    Ecto.Changeset.put_change(
      changeset,
      :chat_id,
      Changeset.get_change(changeset, :chat_id, params["chat_id"] |> String.to_integer())
    )
  end
end
