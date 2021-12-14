defmodule MyScrobblesBot.LastFm.User do
  alias MyScrobblesBot.LastFm

  def myuser(message) do
    %{last_fm_username: username} = user =
      MyScrobblesBot.Accounts.get_user_by_telegram_user_id!(message.from.telegram_id)


    msg =
      if(user.is_premium?) do
        LastFm.get_user_plus(%{username: username})
      else
        LastFm.get_user(%{username: username})
      end
    %{text: msg, parse_mode: "markdown", chat_id: message.chat_id}
  end

  def youruser(message) do
    %{last_fm_username: username} =
      MyScrobblesBot.Accounts.get_user_by_telegram_user_id!(message.reply_to_message.from.telegram_id)

    msg = LastFm.get_user(%{username: username})
    %{text: msg, parse_mode: "markdown", chat_id: message.chat_id}
  end

  def register(message) do
    ## CREATE OR UPDATE
    %{last_fm_username: username} =
      MyScrobblesBot.Accounts.get_user_by_telegram_user_id!(message.reply_to_message.from.telegram_id)

    msg = LastFm.get_user(%{username: username})
    %{text: msg, parse_mode: "markdown", chat_id: message.chat_id}
  end
end
