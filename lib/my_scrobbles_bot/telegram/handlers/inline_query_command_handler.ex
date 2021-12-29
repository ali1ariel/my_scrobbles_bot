defmodule MyScrobblesBot.Telegram.Handlers.InlineQueryCommandHandler do
  @moduledoc """
  Just logs the message
  """

  require Logger

  alias MyScrobblesBot.Telegram.InlineQuery
  alias MyScrobblesBotWeb.Services.Telegram
  alias MyScrobblesBot.LastFm

  @behaviour MyScrobblesBot.Telegram.Handlers

  @impl true
  def handle(%InlineQuery{from: %{telegram_id: user_id}} = inline_query) do

    case MyScrobblesBot.Accounts.get_user_by_telegram_user_id(user_id) do
      {:ok, %{is_premium?: false} = user} ->
        IO.inspect user
        not_premium(inline_query.inline_query_id)
      {:ok, user} -> IO.inspect user
        match_command(inline_query, user)
      {:not_found, _} -> user_not_found(inline_query.inline_query_id)
    end
    |> Telegram.send_inline()

  end

  defp match_command(%InlineQuery{query: "/" <> command = _query} = inline_query, user) do
    command_to_match = String.downcase(command)

    {:ok, track} =
      LastFm.get_recent_track(%{username: user.last_fm_username})
      # |> Helpers.error_handler(message)

    case command_to_match do
      "track" ->  inline_track(inline_query, track)
      "album" ->  inline_album(inline_query, track)
      "artist" -> inline_artist(inline_query, track)
      _ ->  user_not_found(inline_query.inline_query_id)
    end

    # {:ok, nil}

  end

  def inline_track(inline_query, track) do
    {:ok, full_track} =
      LastFm.get_track(track)

    query =
      Map.merge(track, full_track)
      |> Map.merge(%{with_photo?: true, user: inline_query.from.first_name})


    %{
      inline_query_id: inline_query.inline_query_id,
      results: [
        %{
          type: "article",
          title: "With Photo url",
          description: track.trackname,
          input_message_content: %{
            parse_mode: "HTML",
            message_text: Map.merge(query, %{with_photo?: true, user: inline_query.from.first_name}) |> LastFm.get_now_track()
          },
          reply_markup: %{
            inline_keyboard: [[
            ]]
          },
          id: "1",
        },%{
          type: "article",
          title: "Just Text",
          description: track.trackname,
          input_message_content: %{
            parse_mode: "HTML",
            message_text:  Map.merge(query, %{with_photo?: false, user: inline_query.from.first_name}) |> LastFm.get_now_track()
          },
          reply_markup: %{
            inline_keyboard: [[

            ]]
          },
          id: "2",
        }, %{
          type: "photo",
          title: "Photo and text",
          description: track.trackname,
          parse_mode: "HTML",
          input_message_content: %{
            parse_mode: "HTML",
            message_text: ""
          },
          photo_url: track.photo,
          thumb_url: track.photo,
          caption:  Map.merge(query, %{with_photo?: false, user: inline_query.from.first_name}) |> LastFm.get_now_track(),
          reply_markup: %{
            inline_keyboard: [[
            ]]
          },
          id: "3",
        }
      ],
      is_personal: true,
      cache_time: 10
    }
  end


  def inline_artist(inline_query, track) do


    {:ok, attrs} = LastFm.get_artist(track)

    query =
      Map.merge(track, %{playcount: attrs["stats"]["userplaycount"]})

    %{
      inline_query_id: inline_query.inline_query_id,
      results: [
        %{
          type: "article",
          title: "With Photo url",
          description: track.artist,
          input_message_content: %{
            parse_mode: "HTML",
            message_text: Map.merge(query, %{with_photo?: true, user: inline_query.from.first_name}) |> LastFm.get_now_artist()
          },
          reply_markup: %{
            inline_keyboard: [[
            ]]
          },
          id: "1",
        },%{
          type: "article",
          title: "Just Text",
          description: track.artist,
          input_message_content: %{
            parse_mode: "HTML",
            message_text:  Map.merge(query, %{with_photo?: false, user: inline_query.from.first_name}) |> LastFm.get_now_artist()
          },
          reply_markup: %{
            inline_keyboard: [[

            ]]
          },
          id: "2",
        }, %{
          type: "photo",
          title: "Photo and text",
          description: track.artist,
          parse_mode: "HTML",
          input_message_content: %{
            parse_mode: "HTML",
            message_text: ""
          },
          photo_url: track.photo,
          thumb_url: track.photo,
          caption:  Map.merge(query, %{with_photo?: false, user: inline_query.from.first_name}) |> LastFm.get_now_artist(),
          reply_markup: %{
            inline_keyboard: [[
            ]]
          },
          id: "3",
        }
      ],
      is_personal: true,
      cache_time: 10
    }
  end



  def inline_album(inline_query, track) do


    {:ok, attrs} = LastFm.get_album(track)

    query =
      Map.merge(track, %{playcount: attrs["userplaycount"]})

    %{
      inline_query_id: inline_query.inline_query_id,
      results: [
        %{
          type: "article",
          title: "With Photo url",
          description: track.album,
          input_message_content: %{
            parse_mode: "HTML",
            message_text: Map.merge(query, %{with_photo?: true, user: inline_query.from.first_name}) |> LastFm.get_now_album()
          },
          reply_markup: %{
            inline_keyboard: [[
            ]]
          },
          id: "1",
        },%{
          type: "article",
          title: "Just Text",
          description: track.album,
          input_message_content: %{
            parse_mode: "HTML",
            message_text:  Map.merge(query, %{with_photo?: false, user: inline_query.from.first_name}) |> LastFm.get_now_album()
          },
          reply_markup: %{
            inline_keyboard: [[

            ]]
          },
          id: "2",
        }, %{
          type: "photo",
          title: "Photo and text",
          description: track.album,
          parse_mode: "HTML",
          input_message_content: %{
            parse_mode: "HTML",
            message_text: ""
          },
          photo_url: track.photo,
          thumb_url: track.photo,
          caption:  Map.merge(query, %{with_photo?: false, user: inline_query.from.first_name}) |> LastFm.get_now_album(),
          reply_markup: %{
            inline_keyboard: [[
            ]]
          },
          id: "3",
        }
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
            message_text: "<b>you're not registered yet, please, do it with /msregister yourlastfmusername.</b>"
          },
          id: "1",
          reply_markup: %{
            inline_keyboard: [[

            ]]
          },
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
            message_text: "<b>you're not a premium user, please, wait till the official release, or be premium now, more info in @MyScrobblesBotNews.</b>"
          },
          id: "1",
          reply_markup: %{
            inline_keyboard: [[

            ]]
          },
        }
      ],
      is_personal: true,
      cache_time: 10
    }
  end
end
