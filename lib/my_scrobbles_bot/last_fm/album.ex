defmodule MyScrobblesBot.LastFm.Album do
  alias MyScrobblesBot.LastFm

  def album(message) do
    %{last_fm_username: username} = MyScrobblesBot.Accounts.get_user_by_telegram_user_id!(message.from.id)
    {:ok, track} = LastFm.get_recent_track(%{username: username})
    {:ok, attrs} = LastFm.get_album(track)

    query =
      Map.merge(track, attrs)
      |> Map.merge(%{with_photo?: false, user: message.from.first_name})

    msg = LastFm.get_now_album(query)
    %{text: msg, parse_mode: "markdown", chat_id: message.chat_id}
  end

  def youralbum(message) do
    %{
      message: %{
        from: %{
          id: user_id,
          first_name: user_first_name
        },
        reply_to_message: %{
          from: %{
            id: friend_user_id,
            first_name: friend_first_name
          }
        }
      }
    } = message

    %{last_fm_username: username} = MyScrobblesBot.Accounts.get_user_by_telegram_user_id!(user_id)

    %{last_fm_username: friend_username} =
      MyScrobblesBot.Accounts.get_user_by_telegram_user_id!(friend_user_id)

    {:ok, track} = LastFm.get_recent_track(%{username: friend_username})
    {:ok, attrs} = LastFm.get_album(%{track | username: username})

    query =
      Map.merge(track, attrs)
      |> Map.merge(%{with_photo?: true, user: user_first_name, friend: friend_first_name})

    msg = LastFm.get_your_album(query)
    %{text: msg, parse_mode: "markdown", chat_id: message.chat_id}
  end

  def myalbum(message) do
    %{
      message: %{
        from: %{
          id: user_id,
          first_name: user_first_name
        },
        reply_to_message: %{
          from: %{
            id: friend_user_id,
            first_name: friend_first_name
          }
        }
      }
    } = message

    %{last_fm_username: username} = MyScrobblesBot.Accounts.get_user_by_telegram_user_id!(user_id)

    %{last_fm_username: friend_username} =
      MyScrobblesBot.Accounts.get_user_by_telegram_user_id!(friend_user_id)

    {:ok, track} = LastFm.get_recent_track(%{username: username})
    {:ok, attrs} = LastFm.get_album(%{track | username: friend_username})

    query =
      Map.merge(track, attrs)
      |> Map.merge(%{with_photo?: true, user: user_first_name, friend: friend_first_name})

    msg = LastFm.get_my_album(query)
    %{text: msg, parse_mode: "markdown", chat_id: message.chat_id}
  end
end
