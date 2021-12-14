defmodule MyScrobblesBot.LastFm.User do
  alias MyScrobblesBot.LastFm

  def myuser(message) do
    %{last_fm_username: username} =
      MyScrobblesBot.Accounts.get_user_by_telegram_user_id!(message.from.telegram_id)

    msg = LastFm.get_user_plus(%{username: username})
    %{text: msg, parse_mode: "markdown", chat_id: message.chat_id}
  end

  def myuserplus(message) do
    %{last_fm_username: username} =
      MyScrobblesBot.Accounts.get_user_by_telegram_user_id!(message.from.telegram_id)

    msg = LastFm.get_user(%{username: username})
    %{text: msg, parse_mode: "markdown", chat_id: message.chat_id}
  end

  def youruser(message) do
    %{last_fm_username: username} =
      MyScrobblesBot.Accounts.get_user_by_telegram_user_id!(message.reply_to_message.from.id)

    msg = LastFm.get_user(%{username: username})
    %{text: msg, parse_mode: "markdown", chat_id: message.chat_id}
  end

  def register(message) do
    ## CREATE OR UPDATE
    %{last_fm_username: username} =
      MyScrobblesBot.Accounts.get_user_by_telegram_user_id!(message.reply_to_message.from.id)

    msg = LastFm.get_user(%{username: username})
    %{text: msg, parse_mode: "markdown", chat_id: message.chat_id}
  end
end
