defmodule MyScrobblesBot.LastFm.Track do
  alias MyScrobblesBot.LastFm
  alias MyScrobblesBotWeb.Services.Telegram
  alias MyScrobblesBot.Telegram.Message
  alias MyScrobblesBot.Accounts.User

  def error_handler(request, %Message{} = message) do
    case request do
      {:ok, info} ->
        {:ok, info}

      {:error, %{"message" => msg}} ->
        Telegram.send_message(%{
          text: msg,
          parse_mode: "markdown",
          chat_id: message.chat_id,
          reply_to_message_id: message.message_id
        })

      {:error, %{reason: reason}} ->
        Telegram.send_message(%{
          text: reason,
          parse_mode: "HTML",
          chat_id: message.chat_id,
          reply_to_message_id: message.message_id
        })

      {:error, error} ->
        Telegram.send_message(%{
          text: error,
          parse_mode: "HTML",
          chat_id: message.chat_id,
          reply_to_message_id: message.message_id
        })
    end
  end

  def mymusic(%Message{} = message, %User{} = user) do
    %{last_fm_username: username} = user

    {:ok, track} =
      LastFm.get_recent_track(%{username: username})
      |> error_handler(message)

    {:ok, attrs} =
      LastFm.get_track(track)
      |> error_handler(message)

    query =
      Map.merge(track, attrs)
      |> Map.merge(%{with_photo?: true, user: message.from.first_name})

    msg = LastFm.get_now_track(query)
    %{text: msg, parse_mode: "markdown", chat_id: message.chat_id}
  end

  def yourmusic(%Message{} = message) do
    %{last_fm_username: username} =
      MyScrobblesBot.Accounts.get_user_by_telegram_user_id!(message.reply_to_message.from.telegram_id)

    {:ok, track} =
      LastFm.get_recent_track(%{username: username})
      |> error_handler(message)

    {:ok, attrs} =
      LastFm.get_track(track)
      |> error_handler(message)

    query =
      Map.merge(track, attrs)
      |> Map.merge(%{with_photo?: true, user: message.reply_to_message.from.first_name})

    msg = LastFm.get_now_track(query)
    %{text: msg, parse_mode: "markdown", chat_id: message.chat_id}
  end

  def mymusicmarked(%Message{} = message, %User{} = user) do
    %{last_fm_username: username} = user

    {:ok, track} =
      LastFm.get_recent_track(%{username: username})
      |> error_handler(message)

    {:ok, attrs} =
      LastFm.get_track(track)
      |> error_handler(message)

    query =
      Map.merge(track, attrs)
      |> Map.merge(%{with_photo?: true, user: message.from.first_name})

    msg = LastFm.get_now_track(query)

    %{
      text: msg,
      parse_mode: "markdown",
      chat_id: message.chat_id,
      reply_to_message_id: message.message_id
    }
  end

  def mymusictext(%Message{} = message, %User{} = user) do
    %{last_fm_username: username} = user

    {:ok, track} =
      LastFm.get_recent_track(%{username: username})
      |> error_handler(message)

    {:ok, attrs} =
      LastFm.get_track(track)
      |> error_handler(message)

    query =
      Map.merge(track, attrs)
      |> Map.merge(%{with_photo?: false, user: message.from.first_name})

    msg = LastFm.get_now_track(query)
    %{text: msg, parse_mode: "markdown", chat_id: message.chat_id}
  end

  def mymusicphoto(%Message{} = message, %User{} = user) do
    %{last_fm_username: username} = user

    {:ok, track} =
      LastFm.get_recent_track(%{username: username})
      |> error_handler(message)

    {:ok, attrs} =
      LastFm.get_track(track)
      |> error_handler(message)

    query =
      Map.merge(track, attrs)
      |> Map.merge(%{with_photo?: false, user: message.from.first_name})

    msg = LastFm.get_now_track(query)

    {:ok, _} = Telegram.send_photo(%{photo: query.photo, caption: msg, parse_mode: "markdown"})
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

    {:ok, track} =
      LastFm.get_recent_track(%{username: username})
      |> error_handler(message)

    {:ok, attrs} =
      LastFm.get_track(%{track | username: friend_username})
      |> error_handler(message)

    query =
      Map.merge(track, attrs)
      |> Map.merge(%{with_photo?: true, user: user_first_name, friend: friend_first_name})

    msg = LastFm.get_my_music(query)
    %{text: msg, parse_mode: "markdown", chat_id: message.chat_id}
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

    {:ok, track} =
      LastFm.get_recent_track(%{username: friend_username})
      |> error_handler(message)

    {:ok, attrs} =
      LastFm.get_track(%{track | username: username})
      |> error_handler(message)

    query =
      Map.merge(track, attrs)
      |> Map.merge(%{with_photo?: true, user: user_first_name, friend: friend_first_name})

    msg = LastFm.get_your_music(query)
    %{text: msg, parse_mode: "markdown", chat_id: message.chat_id}
  end

end
