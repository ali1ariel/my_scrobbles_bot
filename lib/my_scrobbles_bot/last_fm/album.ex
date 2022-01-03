defmodule MyScrobblesBot.LastFm.Album do
  alias MyScrobblesBot.LastFm

  alias MyScrobblesBot.Accounts.User
  alias MyScrobblesBot.Telegram.Message

  alias MyScrobblesBot.Helpers

  def album(%Message{} = message, %User{} = user) do
    %{last_fm_username: username} = user

    {:ok, track} =
      LastFm.get_recent_track(%{username: username})
      |> Helpers.error_handler(message)

    {:ok, attrs} =
      LastFm.get_album(track)
      |> Helpers.error_handler(message)

    extra =
      if(user.is_premium?) do
        data = album_tracks(attrs["tracks"]["track"], username)

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

<b>Your power tracks of this album:</b>
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
            |> then(&"#{&1}🎧💎")
        end
      else
        ""
      end

    query =
      Map.merge(track, %{playcount: attrs["userplaycount"]})
      |> Map.merge(%{with_photo?: true, user: message.from.first_name})

    msg = LastFm.get_now_album(query)
    %{text: "#{msg}#{extra}
", parse_mode: "HTML", chat_id: message.chat_id}
  end

  def youralbum(%Message{} = message) do
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

    {:ok, track} =
      LastFm.get_recent_track(%{username: friend_username})
      |> Helpers.error_handler(message)

    {:ok, attrs} =
      LastFm.get_album(%{track | username: username})
      |> Helpers.error_handler(message)

    query =
      Map.merge(track, %{playcount: attrs["userplaycount"]})
      |> Map.merge(%{with_photo?: true, user: user_first_name, friend: friend_first_name})

    msg = LastFm.get_your_album(query)
    %{text: msg, parse_mode: "HTML", chat_id: message.chat_id}
  end

  def myalbum(%Message{} = message) do
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

    {:ok, track} =
      LastFm.get_recent_track(%{username: username})
      |> Helpers.error_handler(message)

    {:ok, attrs} =
      LastFm.get_album(%{track | username: friend_username})
      |> Helpers.error_handler(message)

    query =
      Map.merge(track, %{playcount: attrs["userplaycount"]})
      |> Map.merge(%{with_photo?: true, user: user_first_name, friend: friend_first_name})

    msg = LastFm.get_my_album(query)
    %{text: msg, parse_mode: "HTML", chat_id: message.chat_id}
  end

  def album_tracks(tracks, username) when is_list(tracks) do
    Enum.map(tracks, fn %{"name" => track, "artist" => %{"name" => artist}} ->
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

  def album_tracks(track, _username) when is_nil(track), do: []

  def album_tracks(track, username) do
    %{"name" => track, "artist" => %{"name" => artist}} = track
    {:ok, counter} = LastFm.get_track(%{trackname: track, artist: artist, username: username})

    %{track: track}
    |> Map.merge(counter)
    |> then(&[&1])
  end
end
