defmodule MyScrobblesBot.Telegram.ClientInputs.AnswerInlineQuery do
  @moduledoc false

  use MyScrobblesBot.Telegram.ClientInputs

  alias Ecto.Changeset

  # maybe move this soon?

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
      field :inline_keyboard, {:array, {:array, :map}}, default: [[]]
      # embeds_many :inline_keyboard, InlineKeyboardButton
    end
  end

  defmodule InputMessageContent do
    use Ecto.Schema
    @derive Jason.Encoder

    embedded_schema do
      field :message_text, :string, default: ""
      field :parse_mode, :string, default: "HTML"
    end
  end

  defmodule InlineQueryResult do
    use Ecto.Schema

    @derive Jason.Encoder

    embedded_schema do
      field :type, Ecto.Enum,
        values: [
          article: 1,
          photo: 2,
          gif: 3,
          mpeg4_gif: 4,
          video: 5,
          audio: 6,
          voice: 7,
          document: 8,
          sticker: 9
        ]

      field :title, :string, default: ""
      field :url, :string, default: ""
      field :hide_url, :boolean, default: true
      field :description, :string, default: ""
      field :thumb_url, :string, default: ""
      field :photo_url, :string, default: ""
      field :gif_url, :string, default: ""
      field :mpeg4_url, :string, default: ""
      field :video_url, :string, default: ""
      field :audio_url, :string, default: ""
      field :voice_url, :string, default: ""
      field :document_url, :string, default: ""
      field :caption, :string, default: ""
      field :parse_mode, :string, default: "HTML"
      embeds_one :reply_markup, InlineKeyboardMarkup
      embeds_one :input_message_content, InputMessageContent
    end
  end

  embedded_schema do
    field :inline_query_id, :string
    field :is_personal, :boolean, default: true
    field :cache_time, :integer
    field :next_offest, :string
    field :switch_pm_text, :string
    field :switch_pm_parameter, :string

    embeds_many :results, InlineQueryResult
  end

  def cast(params) do
    %__MODULE__{}
    |> Changeset.cast(params, [
      :inline_query_id,
      :is_personal,
      :cache_time,
      :next_offest,
      :switch_pm_text,
      :switch_pm_parameter
    ])
    |> put_answer_inline_query_id()
    |> Changeset.cast_embed(:results, with: &answer_inline_query_result_changeset/2)
  end

  defp answer_inline_query_result_changeset(schema, params) do
    schema
    |> Changeset.cast(params, [
      :type,
      :id,
      :title,
      :hide_url,
      :description,
      :url,
      :thumb_url,
      :photo_url,
      :gif_url,
      :mpeg4_url,
      :video_url,
      :audio_url,
      :voice_url,
      :document_url,
      :caption,
      :parse_mode
    ])
    |> Changeset.cast_embed(:input_message_content, with: &input_message_content_changeset/2)
    |> Changeset.cast_embed(:reply_markup, with: &reply_markup_changeset/2)
  end

  defp input_message_content_changeset(schema, params) do
    schema
    |> Changeset.cast(params, [:message_text, :parse_mode])
  end

  defp reply_markup_changeset(schema, params) do
    schema
    |> Changeset.cast(params, [:inline_keyboard])

    # |> Changeset.cast_embed(:inline_keyboard, with: &inline_keyboard_changeset/2)
  end

  defp inline_keyboard_changeset(schema, params) do
    schema
    |> Changeset.cast(params, [
      :text,
      :url,
      :callback_data
    ])
  end

  defp put_answer_inline_query_id(%Ecto.Changeset{params: params} = changeset) do
    Ecto.Changeset.put_change(
      changeset,
      :inline_query_id,
      Changeset.get_change(changeset, :inline_query_id, params["inline_query_id"])
    )
  end

  # defp put_id(%Ecto.Changeset{} = changeset) do
  #   Ecto.Changeset.put_change(
  #     changeset,
  #     :id,
  #     Changeset.get_change(changeset, :id, generate_id())
  #   )
  # end

  def generate_id(), do: "1"
end
