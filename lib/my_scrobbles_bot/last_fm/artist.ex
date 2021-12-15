defmodule MyScrobblesBot.LastFm.Artist do
  alias MyScrobblesBot.LastFm

  def artist(message) do
    %{last_fm_username: username} =
      user = MyScrobblesBot.Accounts.get_user_by_telegram_user_id!(message.from.telegram_id)

    {:ok, track} = LastFm.get_recent_track(%{username: username})
    {:ok, attrs} = LastFm.get_artist(track)

    extra =
      if(user.is_premium?) do
        {:ok, tracks} = LastFm.get_artist_top_tracks(track)

        data = artist_tracks(tracks["track"], username)

        case Enum.count(data) do
          0 ->
            "\n🎧 _It comes from_ *#{track.trackname}*\n"

          _ ->
            data
            |> Enum.reduce(
              "\n🎧 _It comes from_ *#{track.trackname}*\n\n*Your plays of the most famous tracks:*\n",
              fn %{
                   track: track,
                   userloved?: loved,
                   playcount: count
                 },
                 acc ->
                "#{acc}#{if loved, do: "💘", else: "▪️"} *#{track}* - _#{count} plays_\n"
              end
            )
        end
      else
        ""
      end

    query =
      Map.merge(track, %{playcount: attrs["stats"]["userplaycount"]})
      |> Map.merge(%{with_photo?: false, user: message.from.first_name})

    msg = LastFm.get_now_artist(query)
    %{text: "#{msg}#{extra}`---premium---`\n", parse_mode: "markdown", chat_id: message.chat_id}
  end

  def yourartist(message) do
    %{
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
    } = message

    %{last_fm_username: username} = MyScrobblesBot.Accounts.get_user_by_telegram_user_id!(user_id)

    %{last_fm_username: friend_username} =
      MyScrobblesBot.Accounts.get_user_by_telegram_user_id!(friend_user_id)

    {:ok, track} = LastFm.get_recent_track(%{username: username})
    {:ok, attrs} = LastFm.get_artist(%{track | username: friend_username})
    # {:ok, attrs} = LastFm.get_artist(%{track | username: username})

    query =
      Map.merge(track, attrs)
      |> Map.merge(%{with_photo?: true, user: user_first_name, friend: friend_first_name})

    msg = LastFm.get_my_artist(query)
    %{text: msg, parse_mode: "markdown", chat_id: message.chat_id}
  end

  def artist_tracks(tracks, username) when is_list(tracks) do
    Enum.map(tracks |> Enum.take(20), fn %{
                                           "name" => track,
                                           "artist" => %{"name" => artist}
                                         } ->
      Task.async(fn ->
        {:ok, counter} = LastFm.get_track(%{trackname: track, artist: artist, username: username})

        %{track: track}
        |> Map.merge(counter)
      end)
    end)
    |> Enum.map(&Task.await/1)
    |> Enum.sort_by(& &1.playcount, :desc)
    |> Enum.uniq_by(& &1.track)
    |> Enum.take(3)
  end

  def artist_tracks(track, username) when is_nil(track), do: []
end
