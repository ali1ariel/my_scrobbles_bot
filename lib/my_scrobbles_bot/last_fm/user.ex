defmodule MyScrobblesBot.LastFm.User do
  alias MyScrobblesBot.LastFm
  alias MyScrobblesBot.BotOutput

  alias MyScrobblesBot.Accounts.User
  alias MyScrobblesBot.Telegram.Message

  def myuser(%Message{} = message, %User{} = user) do
    %{last_fm_username: username} = user

    msg =
      if(user.is_premium?) do
        LastFm.get_user_plus(%{username: username})
        |> BotOutput.get_user_plus()
      else
        LastFm.get_user_plus(%{username: username})
        |> BotOutput.get_user()
      end

    %{text: msg, parse_mode: "HTML", chat_id: message.chat_id}
  end

  def youruser(%Message{} = message) do
    %{last_fm_username: username} =
      MyScrobblesBot.Accounts.get_user_by_telegram_user_id!(
        message.reply_to_message.from.telegram_id
      )

    msg =
        LastFm.get_user_plus(%{username: username})
      |> BotOutput.get_user()
    %{text: msg, parse_mode: "HTML", chat_id: message.chat_id}
  end

  def register(%Message{} = message) do
    ## CREATE OR UPDATE
    %{last_fm_username: username} =
      MyScrobblesBot.Accounts.get_user_by_telegram_user_id!(
        message.reply_to_message.from.telegram_id
      )

    msg = BotOutput.get_user(%{username: username})
    %{text: msg, parse_mode: "HTML", chat_id: message.chat_id}
  end
end
