defmodule MyScrobblesBot.LastFm.User do


  alias MyScrobblesBot.LastFm
  alias MyScrobblesBotWeb.Services.Telegram


  def myuser(update) do
    %{last_fm_username: username} = MyScrobblesBot.Accounts.get_user_by_telegram_user_id!(update.message.from.id)
    msg = LastFm.get_user(%{username: username})
    {:ok, _} =Telegram.send_message(%{text: msg, parse_mode: :markdown})
  end


  def youruser(update) do
    %{last_fm_username: username} = MyScrobblesBot.Accounts.get_user_by_telegram_user_id!(update.message.reply_to_message.from.id)
    msg = LastFm.get_user(%{username: username})
    {:ok, _} =Telegram.send_message(%{text: msg, parse_mode: :markdown})
  end

  def register(update) do
    ## CREATE OR UPDATE
    %{last_fm_username: username} = MyScrobblesBot.Accounts.get_user_by_telegram_user_id!(update.message.reply_to_message.from.id)
    msg = LastFm.get_user(%{username: username})
    {:ok, _} =Telegram.send_message(%{text: msg, parse_mode: :markdown})
  end

end
