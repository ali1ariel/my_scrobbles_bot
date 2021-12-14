defmodule MyScrobblesBot.LastFm.Artist do
  alias MyScrobblesBot.LastFm

  def artist(message) do
    %{last_fm_username: username} =
      MyScrobblesBot.Accounts.get_user_by_telegram_user_id!(message.from.telegram_id)

    {:ok, track} = LastFm.get_recent_track(%{username: username})
    {:ok, attrs} = LastFm.get_artist(track)
    {:ok, tracks} = LastFm.get_artist_top_tracks(track)

    extra =
      artist_tracks(tracks, username)
      |> Enum.reduce("\n *Some of your power tracks*\n", fn %{
                                                              track: track,
                                                              userloved?: loved,
                                                              playcount: count
                                                            },
                                                            acc ->
        "#{acc}#{if loved, do: "💘", else: "▪️"} *#{track}* - _#{count} plays_\n"
      end)

    LastFm.get_artist_top_tracks(track)

    query =
      Map.merge(track, %{playcount: attrs["stats"]["userplaycount"]})
      |> Map.merge(%{with_photo?: false, user: message.from.first_name})

    msg = LastFm.get_now_artist(query)
    %{text: "#{msg}#{extra}", parse_mode: "markdown", chat_id: message.chat_id}
  end

  def artistplus(message) do
    %{last_fm_username: username} =
      MyScrobblesBot.Accounts.get_user_by_telegram_user_id!(message.from.telegram_id)

    {:ok, track} = LastFm.get_recent_track(%{username: username})
    {:ok, attrs} = LastFm.get_artist(track)

    query =
      Map.merge(track, attrs)
      |> Map.merge(%{with_photo?: false, user: message.from.first_name})

    msg = LastFm.get_now_artist(query)
    %{text: msg, parse_mode: "markdown", chat_id: message.chat_id}
  end

  def yourartist(message) do
    %{
      message: %{
        from: %{
          telegram_id: user_id,
          first_name: user_first_name
        },
        reply_to_message: %{
          from: %{
            telegram_id: friend_user_id,
            first_name: friend_first_name
          }
        }
      }
    } = message

    %{last_fm_username: username} = MyScrobblesBot.Accounts.get_user_by_telegram_user_id!(user_id)

    %{last_fm_username: friend_username} =
      MyScrobblesBot.Accounts.get_user_by_telegram_user_id!(friend_user_id)

    {:ok, track} = LastFm.get_recent_track(%{username: friend_username})
    {:ok, attrs} = LastFm.get_artist(%{track | username: username})

    query =
      Map.merge(track, attrs)
      |> Map.merge(%{with_photo?: true, user: user_first_name, friend: friend_first_name})

    msg = LastFm.get_your_artist(query)
    %{text: msg, parse_mode: "markdown", chat_id: message.chat_id}
  end

  def myartist(message) do
    %{
      message: %{
        from: %{
          telegram_id: user_id,
          first_name: user_first_name
        },
        reply_to_message: %{
          from: %{
            telegram_id: friend_user_id,
            first_name: friend_first_name
          }
        }
      }
    } = message

    %{last_fm_username: username} = MyScrobblesBot.Accounts.get_user_by_telegram_user_id!(user_id)

    %{last_fm_username: friend_username} =
      MyScrobblesBot.Accounts.get_user_by_telegram_user_id!(friend_user_id)

    {:ok, track} = LastFm.get_recent_track(%{username: username})
    {:ok, attrs} = LastFm.get_artist(%{track | username: friend_username})

    query =
      Map.merge(track, attrs)
      |> Map.merge(%{with_photo?: true, user: user_first_name, friend: friend_first_name})

    msg = LastFm.get_my_artist(query)
    %{text: msg, parse_mode: "markdown", chat_id: message.chat_id}
  end

  def myartist(message) do
    %{
      message: %{
        from: %{
          telegram_id: user_id,
          first_name: user_first_name
        },
        reply_to_message: %{
          from: %{
            telegram_id: friend_user_id,
            first_name: friend_first_name
          }
        }
      }
    } = message

    %{last_fm_username: username} = MyScrobblesBot.Accounts.get_user_by_telegram_user_id!(user_id)

    %{last_fm_username: friend_username} =
      MyScrobblesBot.Accounts.get_user_by_telegram_user_id!(friend_user_id)

    {:ok, track} = LastFm.get_recent_track(%{username: username})
    {:ok, attrs} = LastFm.get_artist(%{track | username: friend_username})

    query =
      Map.merge(track, attrs)
      |> Map.merge(%{with_photo?: true, user: user_first_name, friend: friend_first_name})

    msg = LastFm.get_my_artist(query)
    %{text: msg, parse_mode: "markdown", chat_id: message.chat_id}
  end

  def artist_tracks(tracks, username) do
    Enum.map(tracks["track"] |> Enum.take(20), fn %{
                                                    "name" => track,
                                                    "artist" => %{"name" => artist}
                                                  } ->
      {:ok, counter} = LastFm.get_track(%{trackname: track, artist: artist, username: username})

      %{track: track}
      |> Map.merge(counter)
    end)
    |> Enum.sort_by(& &1.playcount, :desc)
    |> Enum.take(3)
  end
end
