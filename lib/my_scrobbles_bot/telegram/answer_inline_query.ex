defmodule MyScrobblesBot.Telegram.AnswerInlineQuery do
  @moduledoc """
  Representation of a message
  """
  use Ecto.Schema

  alias Ecto.Changeset

  # maybe move this soon?
  defmodule InlineQueryResult do
    use Ecto.Schema

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

      field :answer_inline_query_result_id, :string
      field :title, :string
      field :hide_url, :boolean
      field :description, :string
      field :url, :string
      field :thumb_url, :string
      field :photo_url, :string
      field :parse_mode, :string
      field :gif_url, :string
      field :mpeg4_url, :string
      field :video_url, :string
      field :audio_url, :string
      field :voice_url, :string
      field :document_url, :string
    end
  end

  embedded_schema do
    field :answer_inline_query_id, :string
    field :is_personal, :boolean
    field :cache_time, :integer
    field :next_offest, :string
    field :switch_pm_text, :string
    field :switch_pm_parameter, :string

    embeds_many :results, InlineQueryResult
  end

  def cast(params) do
    %__MODULE__{}
    |> Changeset.cast(params, [
      :answer_inline_query_id,
      :is_personal,
      :cache_time,
      :next_offest,
      :switch_pm_text,
      :switch_pm_parameter
    ])
    |> Changeset.validate_required([:is_personal, :cache_time])
    |> put_answer_inline_query_id()
    |> Changeset.cast_embed(:results, with: &answer_inline_query_result_changeset/2)
  end

  defp answer_inline_query_result_changeset(schema, params) do
    schema
    |> Changeset.cast(params, [
      :type,
      :answer_inline_query_result_id,
      :title,
      :hide_url,
      :description,
      :url,
      :thumb_url,
      :photo_url,
      :parse_mode,
      :gif_url,
      :mpeg4_url,
      :video_url,
      :audio_url,
      :voice_url,
      :document_url
    ])
    |> put_answer_inline_query_result_id()
  end

  defp put_answer_inline_query_id(%Ecto.Changeset{} = changeset) do
    Ecto.Changeset.put_change(
      changeset,
      :answer_inline_query_id,
      Changeset.get_change(changeset, :answer_inline_query_id, generate_id())
    )
  end

  defp put_answer_inline_query_result_id(%Ecto.Changeset{} = changeset) do
    Ecto.Changeset.put_change(
      changeset,
      :answer_inline_query_result_id,
      Changeset.get_change(changeset, :answer_inline_query_result_id, generate_id())
    )
  end

  def generate_id(), do: 1
end
