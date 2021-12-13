defmodule MyScrobblesBot.LastFm.Artist do


  alias MyScrobblesBot.LastFm
  alias MyScrobblesBotWeb.Services.Telegram


  def artist(update) do
    %{last_fm_username: username} = MyScrobblesBot.Accounts.get_user_by_telegram_user_id!(update.message.from.id)
    {:ok, track} = LastFm.get_recent_track(%{username: username})
    {:ok, attrs} = LastFm.get_artist(track)

    query =
      Map.merge(track, attrs)
      |> Map.merge(%{with_photo?: false, user: update.message.from.first_name})

    msg = LastFm.get_now_artist(query)
    {:ok, _} =Telegram.send_message(%{text: msg, parse_mode: :markdown})
  end

  def yourartist(update) do
    %{
      message:
      %{
        from:
        %{
          id: user_id,
          first_name: user_first_name
        },
        reply_to_message: %{
          from:
            %{
              id: friend_user_id,
              first_name: friend_first_name
            }
        }
      }
    } = update
    %{last_fm_username: username} = MyScrobblesBot.Accounts.get_user_by_telegram_user_id!(user_id)

    %{last_fm_username: friend_username} = MyScrobblesBot.Accounts.get_user_by_telegram_user_id!(friend_user_id)

    {:ok, track} = LastFm.get_recent_track(%{username: friend_username})
    {:ok, attrs} = LastFm.get_artist(%{track | username: username})

    query =
      Map.merge(track, attrs)
      |> Map.merge(%{with_photo?: true, user: user_first_name, friend: friend_first_name})

    msg = LastFm.get_your_artist(query)
    {:ok, _} =Telegram.send_message(%{text: msg, parse_mode: :markdown})
  end


  def myartist(update) do
    %{
      message:
      %{
        from:
        %{
          id: user_id,
          first_name: user_first_name
        },
        reply_to_message: %{
          from:
            %{
              id: friend_user_id,
              first_name: friend_first_name
            }
        }
      }
    } = update
    %{last_fm_username: username} = MyScrobblesBot.Accounts.get_user_by_telegram_user_id!(user_id)

    %{last_fm_username: friend_username} = MyScrobblesBot.Accounts.get_user_by_telegram_user_id!(friend_user_id)

    {:ok, track} = LastFm.get_recent_track(%{username: username})
    {:ok, attrs} = LastFm.get_artist(%{track | username: friend_username})

    query =
      Map.merge(track, attrs)
      |> Map.merge(%{with_photo?: true, user: user_first_name, friend: friend_first_name})

    msg = LastFm.get_my_artist(query)
    {:ok, _} =Telegram.send_message(%{text: msg, parse_mode: :markdown})
  end
end
