defmodule MyScrobblesBot.LastFm.Artist do
  alias MyScrobblesBot.LastFm

  alias MyScrobblesBot.Accounts.User
  alias MyScrobblesBot.Telegram.Message

  alias MyScrobblesBot.Helpers

  def artist(%Message{} = message, %User{} = user) do
    %{last_fm_username: username} = user

    {:ok, track} = LastFm.get_recent_track(%{username: username})

    {:ok, attrs} = LastFm.get_artist(track)

    extra =
      if(user.is_premium?) do
        {:ok, tracks} = LastFm.get_artist_top_tracks(track)

        data = artist_tracks(tracks["track"], username)

        case Enum.count(data) do
          0 ->
            "

🎧 <i>It comes from</i> <b>#{track.trackname}</b>
"

          _ ->
            data
            |> Enum.reduce(
              "

🎧 <i>It comes from</i> <b>#{track.trackname}</b>

<b>Your plays of the most famous tracks:</b>
",
              fn %{
                   track: track,
                   userloved?: loved,
                   playcount: count
                 },
                 acc ->
                "#{acc}#{if loved, do: "💘", else: "▪️"} <b>#{track}</b> - <i>#{count} plays</i>
"
              end
            )
            |> then(&"#{&1}🎧💎
")
        end
      else
        ""
      end

    query =
      Map.merge(track, %{playcount: attrs["stats"]["userplaycount"]})
      |> Map.merge(%{with_photo?: true, user: message.from.first_name})

    msg = BotOutput.get_now_artist(query)
    %{text: "#{msg}#{extra}", parse_mode: "HTML", chat_id: message.chat_id}
  end

  def yourartist(%Message{} = message) do
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

    msg = BotOutput.get_your_artist(query)
    %{text: msg, parse_mode: "HTML", chat_id: message.chat_id}
  end

  def myartist(%Message{} = message) do
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

    query =
      Map.merge(track, attrs)
      |> Map.merge(%{with_photo?: true, user: user_first_name, friend: friend_first_name})

    msg = BotOutput.get_my_artist(query)
    %{text: msg, parse_mode: "HTML", chat_id: message.chat_id}
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

  def artist_tracks(track, _username) when is_nil(track), do: []
end
