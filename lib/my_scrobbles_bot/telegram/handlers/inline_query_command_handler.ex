defmodule MyScrobblesBot.Telegram.Handlers.InlineQueryCommandHandler do
  @moduledoc """
  Just logs the message
  """

  require Logger

  alias MyScrobblesBot.Telegram.InlineQuery
  alias MyScrobblesBotWeb.Services.Telegram
  alias MyScrobblesBot.LastFm
  alias MyScrobblesBot.BotOutput
  alias MyScrobblesBot.Helpers

  @behaviour MyScrobblesBot.Telegram.Handlers

  @impl true
  def handle(%InlineQuery{from: %{telegram_id: user_id}} = inline_query) do
    case MyScrobblesBot.Accounts.get_user_by_telegram_user_id(user_id) do
      {:ok, %{is_premium?: false} = _user} ->
        not_premium(inline_query.inline_query_id)

      {:ok, user} ->
        match_command(inline_query, user)

      {:not_found, _} ->
        user_not_found(inline_query.inline_query_id)
    end
    |> Telegram.send_inline()
  end

  defp match_command(%InlineQuery{query: "/" <> command = _query} = inline_query, user) do
    Helpers.set_language(user.user_confs.language)

    command_to_match = String.downcase(command)

    {:ok, track} = LastFm.get_recent_track(%{username: user.last_fm_username})
    # |> Helpers.error_handler(message)

    case command_to_match do
      "track" -> inline_track(inline_query, track)
      "album" -> inline_album(inline_query, track)
      "artist" -> inline_artist(inline_query, track)
      _ -> inline_track(inline_query, track)
    end

    # {:ok, nil}
  end

  def inline_track(inline_query, track) do
    full_track =
      case LastFm.get_track(track) do
        {:ok, full_track} ->
          full_track

        {:error, _} ->
          %{playcount: nil, userloved?: nil}
      end

    query =
      Map.merge(track, full_track)
      |> Map.merge(%{with_photo?: true, user: inline_query.from.first_name})

    %{
      inline_query_id: inline_query.inline_query_id,
      results: [
        inline_text_option(
          track,
          :trackname,
          query,
          inline_query.from.first_name,
          "With Photo url",
          true,
          "1",
          fn op -> BotOutput.get_now_track(op) end
        ),
        inline_text_option(
          track,
          :trackname,
          query,
          inline_query.from.first_name,
          "Just Text",
          false,
          "2",
          fn op -> BotOutput.get_now_track(op) end
        ),
        inline_photo_option(
          track,
          :trackname,
          query,
          inline_query.from.first_name,
          "with photo",
          false,
          "3",
          fn op -> BotOutput.get_now_track(op) end
        )
      ],
      is_personal: true,
      cache_time: 10
    }
  end

  def inline_artist(inline_query, track) do
    {:ok, attrs} = LastFm.get_artist(track)

    query = Map.merge(track, %{playcount: attrs["stats"]["userplaycount"]})

    %{
      inline_query_id: inline_query.inline_query_id,
      results: [
        inline_text_option(
          track,
          :artist,
          query,
          inline_query.from.first_name,
          "With Photo url",
          true,
          "1",
          fn op -> BotOutput.get_now_artist(op) end
        ),
        inline_text_option(
          track,
          :artist,
          query,
          inline_query.from.first_name,
          "Just Text",
          false,
          "2",
          fn op -> BotOutput.get_now_artist(op) end
        ),
        inline_photo_option(
          track,
          :artist,
          query,
          inline_query.from.first_name,
          "with photo",
          false,
          "3",
          fn op -> BotOutput.get_now_artist(op) end
        )
      ],
      is_personal: true,
      cache_time: 10
    }
  end

  def inline_album(inline_query, track) do
    {:ok, attrs} = LastFm.get_album(track)

    query = Map.merge(track, %{playcount: attrs["userplaycount"]})

    %{
      inline_query_id: inline_query.inline_query_id,
      results: [
        inline_text_option(
          track,
          :album,
          query,
          inline_query.from.first_name,
          "With Photo url",
          true,
          "1",
          fn op -> BotOutput.get_now_album(op) end
        ),
        inline_text_option(
          track,
          :album,
          query,
          inline_query.from.first_name,
          "Just Text",
          false,
          "2",
          fn op -> BotOutput.get_now_album(op) end
        ),
        inline_photo_option(
          track,
          :album,
          query,
          inline_query.from.first_name,
          "with photo",
          false,
          "3",
          fn op -> BotOutput.get_now_album(op) end
        )
      ],
      is_personal: true,
      cache_time: 10
    }
  end

  def user_not_found(id) do
    %{
      inline_query_id: id,
      results: [
        %{
          type: "article",
          title: "You're not registered yet",
          description: "click here",
          input_message_content: %{
            parse_mode: "HTML",
            message_text:
              "<b>you're not registered yet, please, do it with /msregister yourlastfmusername.</b>"
          },
          id: "1",
          reply_markup: %{
            inline_keyboard: [[]]
          }
        }
      ],
      is_personal: true,
      cache_time: 10
    }
  end

  def not_premium(id) do
    %{
      inline_query_id: id,
      results: [
        %{
          type: "article",
          title: "You're not a premium user.",
          description: "click here",
          input_message_content: %{
            parse_mode: "HTML",
            message_text:
              "<b>you're not a premium user, please, wait till the official release, or be premium now, more info in @MyScrobblesBotNews.</b>"
          },
          id: "1",
          reply_markup: %{
            inline_keyboard: [[]]
          }
        }
      ],
      is_personal: true,
      cache_time: 10
    }
  end

  def only_text() do
  end

  def inline_text_option(content, content_type, query, first_name, type, photo?, id, function) do
    %{
      type: "article",
      title: content[content_type],
      description: type,
      input_message_content: %{
        parse_mode: "HTML",
        message_text:
          Map.merge(query, %{with_photo?: photo?, user: first_name})
          |> function.()
      },
      thumb_url:
        case photo? do
          true ->
            content.photo

          _ ->
            ""
        end,
      reply_markup: %{
        inline_keyboard: [[]]
      },
      id: id
    }
  end

  def inline_photo_option(content, content_type, query, first_name, _type, photo?, id, function) do
    %{
      type: "photo",
      title: "Photo and text",
      description: content[content_type],
      parse_mode: "HTML",
      input_message_content: %{
        parse_mode: "HTML",
        message_text: ""
      },
      reply_markup: %{
        inline_keyboard: [[]]
      },
      photo_url: content.photo,
      thumb_url: content.photo,
      caption:
        Map.merge(query, %{with_photo?: photo?, user: first_name})
        |> function.(),
      id: id
    }
  end
end
