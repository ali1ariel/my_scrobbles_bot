defmodule MyScrobblesBot.LastFm.Track do
  alias MyScrobblesBot.LastFm
  alias MyScrobblesBot.BotOutput
  alias MyScrobblesBotWeb.Services.Telegram
  alias MyScrobblesBot.Telegram.Message
  alias MyScrobblesBot.Accounts.User

  def mymusic(%Message{} = message, %User{} = user) do
    %{last_fm_username: username} = user

    {:ok, track} = LastFm.get_recent_track(%{username: username})

    {:ok, attrs} = LastFm.get_track(track)

    query =
      Map.merge(track, attrs)
      |> Map.merge(%{with_photo?: true, user: message.from.first_name, heart: user.user_confs.heart})

    msg = BotOutput.get_now_track(query)
    %{text: msg, parse_mode: "HTML", chat_id: message.chat_id}
  end

  def yourmusic(%Message{} = message) do
    %{last_fm_username: username} =
      MyScrobblesBot.Accounts.get_user_by_telegram_user_id!(
        message.reply_to_message.from.telegram_id
      )

    {:ok, track} = LastFm.get_recent_track(%{username: username})

    {:ok, attrs} = LastFm.get_track(track)

    query =
      Map.merge(track, attrs)
      |> Map.merge(%{with_photo?: true, user: message.reply_to_message.from.first_name})

    msg = BotOutput.get_now_track(query)
    %{text: msg, parse_mode: "HTML", chat_id: message.chat_id}
  end

  def mymusicmarked(%Message{} = message, %User{} = user) do
    %{last_fm_username: username} = user

    {:ok, track} = LastFm.get_recent_track(%{username: username})

    {:ok, attrs} = LastFm.get_track(track)

    query =
      Map.merge(track, attrs)
      |> Map.merge(%{with_photo?: true, user: message.from.first_name, heart: user.user_confs.heart})

    msg = BotOutput.get_now_track(query)

    IO.inspect message

    %{
      text: msg,
      parse_mode: "HTML",
      chat_id: message.chat_id,
      reply_to_message_id: message.message_id
    }
  end

  def mymusictext(%Message{} = message, %User{} = user) do
    %{last_fm_username: username} = user

    {:ok, track} = LastFm.get_recent_track(%{username: username})

    {:ok, attrs} = LastFm.get_track(track)

    query =
      Map.merge(track, attrs)
      |> Map.merge(%{with_photo?: false, user: message.from.first_name, heart: user.user_confs.heart})

    msg = BotOutput.get_now_track(query)
    %{text: msg, parse_mode: "HTML", chat_id: message.chat_id}
  end

  def mymusicphoto(%Message{} = message, %User{} = user) do
    %{last_fm_username: username} = user

    {:ok, track} = LastFm.get_recent_track(%{username: username})

    {:ok, attrs} = LastFm.get_track(track)

    query =
      Map.merge(track, attrs)
      |> Map.merge(%{with_photo?: false, user: message.from.first_name, heart: user.user_confs.heart})

    msg = BotOutput.get_now_track(query)

    {:ok, _} = Telegram.send_photo(%{photo: query.photo, caption: msg, chat_id: message.chat_id, parse_mode: "HTML"})
  end

  def mytrack(%Message{} = message) do
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

    {:ok, attrs} = LastFm.get_track(%{track | username: friend_username})

    query =
      Map.merge(track, attrs)
      |> Map.merge(%{with_photo?: true, user: user_first_name, friend: friend_first_name})

    msg = BotOutput.get_my_music(query)
    %{text: msg, parse_mode: "HTML", chat_id: message.chat_id}
  end

  def yourtrack(%Message{} = message) do
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

    {:ok, attrs} = LastFm.get_track(%{track | username: username})

    query =
      Map.merge(track, attrs)
      |> Map.merge(%{with_photo?: true, user: user_first_name, friend: friend_first_name})

    msg = BotOutput.get_your_music(query)
    %{text: msg, parse_mode: "HTML", chat_id: message.chat_id}
  end
end
