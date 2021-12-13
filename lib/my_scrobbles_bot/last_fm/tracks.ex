defmodule MyScrobblesBot.LastFm.Tracks do


  alias MyScrobblesBot.LastFm
  alias MyScrobblesBotWeb.Services.Telegram


  def error_hendler(request, update) do
    case request do

    {:ok, info} ->
      {:ok, info}

    {:error, %{"message" => msg}} ->
     Telegram.send_message(%{text: msg, parse_mode: :markdown})

    {:error, %{reason: reason}} ->
     Telegram.send_message(%{text: reason, parse_mode: :HTML})

    {:error, error} ->
     Telegram.send_message(%{text: error, parse_mode: :HTML})

    end
  end

  def mysong(update) do

    %{last_fm_username: username} = MyScrobblesBot.Accounts.get_user_by_telegram_user_id!(update.message.from.id)

    {:ok, track} = LastFm.get_recent_track(%{username: username})
    |> error_hendler(update)

    {:ok, attrs} = LastFm.get_track(track)
    |> error_hendler(update)

    query =
      Map.merge(track, attrs)
      |> Map.merge(%{with_photo?: true, user: update.message.from.first_name})

    msg = LastFm.get_now_track(query)
    {:ok, _} =Telegram.send_message(%{text: msg, parse_mode: :markdown})

  end


  def yoursong(update) do
    %{last_fm_username: username} = MyScrobblesBot.Accounts.get_user_by_telegram_user_id!(update.message.reply_to_message.from.id)

    {:ok, track} = LastFm.get_recent_track(%{username: username})
    |> error_hendler(update)

    {:ok, attrs} = LastFm.get_track(track)
    |> error_hendler(update)

    query =
      Map.merge(track, attrs)
      |> Map.merge(%{with_photo?: true, user: update.message.reply_to_message.from.first_name})

    msg = LastFm.get_now_track(query)
    {:ok, _} =Telegram.send_message(%{text: msg, parse_mode: :markdown})
  end

  def mysongmarked(update) do

    %{last_fm_username: username} = MyScrobblesBot.Accounts.get_user_by_telegram_user_id!(update.message.from.id)

    {:ok, track} = LastFm.get_recent_track(%{username: username})
    |> error_hendler(update)

    {:ok, attrs} = LastFm.get_track(track)
    |> error_hendler(update)

    query =
      Map.merge(track, attrs)
      |> Map.merge(%{with_photo?: true, user: update.message.from.first_name})

    msg = LastFm.get_now_track(query)

    {:ok, _} =
     Telegram.send_message(%{text: msg, parse_mode: :markdown, reply_to_message_id: update.message.message_id})
  end

  def mysongtext(update) do
    %{last_fm_username: username} = MyScrobblesBot.Accounts.get_user_by_telegram_user_id!(update.message.from.id)
    {:ok, track} = LastFm.get_recent_track(%{username: username})
    |> error_hendler(update)

    {:ok, attrs} = LastFm.get_track(track)
    |> error_hendler(update)

    query =
      Map.merge(track, attrs)
      |> Map.merge(%{with_photo?: false, user: update.message.from.first_name})

    msg = LastFm.get_now_track(query)
    {:ok, _} =Telegram.send_message(%{text: msg, parse_mode: :markdown})
  end


  def mysongphoto(update) do
    %{last_fm_username: username} = MyScrobblesBot.Accounts.get_user_by_telegram_user_id!(update.message.from.id)

    {:ok, track} = LastFm.get_recent_track(%{username: username})
    |> error_hendler(update)

    {:ok, attrs} = LastFm.get_track(track)
    |> error_hendler(update)

    query =
      Map.merge(track, attrs)
      |> Map.merge(%{with_photo?: false, user: update.message.from.first_name})

    msg = LastFm.get_now_track(query)

    {:ok, _} = Telegram.send_photo(%{photo: query.photo, caption: msg, parse_mode: :markdown})
  end

  def mymusic(update) do
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
    |> error_hendler(update)

    {:ok, attrs} = LastFm.get_track(%{track | username: friend_username})
    |> error_hendler(update)

    query =
      Map.merge(track, attrs)
      |> Map.merge(%{with_photo?: true, user: user_first_name, friend: friend_first_name})

    msg = LastFm.get_my_music(query)
    {:ok, _} =Telegram.send_message(%{text: msg, parse_mode: :markdown})
  end

  def yourmusic(update) do
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
    |> error_hendler(update)

    {:ok, attrs} = LastFm.get_track(%{track | username: username})
    |> error_hendler(update)

    query =
      Map.merge(track, attrs)
      |> Map.merge(%{with_photo?: true, user: user_first_name, friend: friend_first_name})

    msg = LastFm.get_your_music(query)
    {:ok, _} =Telegram.send_message(%{text: msg, parse_mode: :markdown})
  end

end
