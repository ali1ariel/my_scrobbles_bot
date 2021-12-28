defmodule MyScrobblesBot.Telegram.ClientInputs.AnswerInlineQuery do
  @moduledoc false

  use MyScrobblesBot.Telegram.ClientInputs

  alias Ecto.Changeset

  # maybe move this soon?

  defmodule InputMessageContent do
    use Ecto.Schema
    @derive Jason.Encoder

    embedded_schema do
      field :message_text, :string
      field :parse_mode, :string
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

      field :title, :string
      field :url, :string
      field :hide_url, :boolean
      field :description, :string
      field :thumb_url, :string
      field :photo_url, :string
      field :gif_url, :string
      field :mpeg4_url, :string
      field :video_url, :string
      field :audio_url, :string
      field :voice_url, :string
      field :document_url, :string
      field :caption, :string
      field :parse_mode, :string
      embeds_one :input_message_content, InputMessageContent
    end
  end

  embedded_schema do
    field :inline_query_id, :integer
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
  end


  defp input_message_content_changeset(schema, params) do
    schema
    |> Changeset.cast(params, [:message_text, :parse_mode])
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
