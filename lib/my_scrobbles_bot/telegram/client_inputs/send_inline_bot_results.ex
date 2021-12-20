defmodule MyScrobblesBot.Telegram.ClientInputs.SendInlineBotResults do
  @moduledoc false

  use MyScrobblesBot.Telegram.ClientInputs

  alias Ecto.Changeset

  defmodule InputBotInlineMessage do
    use Ecto.Schema

    embedded_schema do
      field :message, :string
    end
  end

  embedded_schema do
    field :text, :string
    field :type, :string
    field :title, :string
    field :description, :string
    field :url, :string
    field :thumb, :string
    field :content, :string

    embeds_one :send_message, InputBotInlineMessage
  end

  @impl true
  def cast(params) do
    %__MODULE__{}
    |> Changeset.cast(params, __schema__(:fields))
    |> Changeset.validate_required([:chat_id, :text])
  end
end
