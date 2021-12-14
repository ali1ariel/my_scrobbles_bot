defmodule MyScrobblesBot.Telegram.Handlers.CommandHandler do
  @moduledoc """
  Sends a simple help message
  """

  alias MyScrobblesBot.Telegram.Message
  alias MyScrobblesBotWeb.Services.Telegram
  @behaviour MyScrobblesBot.Telegram.Handlers

  def handle(%Message{} = message) do
    match_command(message)
    |> Telegram.send_message()

    # %{
    #   chat_id: c_id,
    #   reply_to_message_id: m_id,
    #   text: "this is *just* a _sample_ message",
    #   parse_mode: "markdown"

    # }
  end

  def match_command(%Message{text: "/" <> command} = message) do
    command = String.downcase(command)

    case command do
      x when x in ["lt", "listen", "mymusic", "mm"] ->
        MyScrobblesBot.LastFm.Track.mymusic(message)

      x when x in ["wyl", "ym", "yourmusic"] ->
        MyScrobblesBot.LastFm.Track.yourmusic(message)

      x when x in ["ltmarked", "ltm", "mymusicmarked", "msm"] ->
        MyScrobblesBot.LastFm.Track.mymusicmarked(message)

      x when x in ["textlisten", "tlisten", "txtl", "mymusictext", "mst"] ->
        MyScrobblesBot.LastFm.Track.mymusictext(message)

      x when x in ["ltphoto", "ltp", "mymusicphoto", "msp"] ->
        MyScrobblesBot.LastFm.Track.mymusicphoto(message)

      x when x in ["andyou", "mytrack", "mt"] ->
        MyScrobblesBot.LastFm.Track.mytrack(message)

      x when x in ["andme", "yourtrack", "yt"] ->
        MyScrobblesBot.LastFm.Track.yourtrack(message)

      x when x in ["artist"] ->
        MyScrobblesBot.LastFm.Artist.artist(message)

      x when x in ["yourartist", "yar"] ->
        MyScrobblesBot.LastFm.Artist.yourartist(message)

      x when x in ["myartist", "mar"] ->
        MyScrobblesBot.LastFm.Artist.myartist(message)

      x when x in ["album"] ->
        MyScrobblesBot.LastFm.Album.album(message)

      x when x in ["youralbum", "yal"] ->
        MyScrobblesBot.LastFm.Album.youralbum(message)

      x when x in ["myalbum", "mal"] ->
        MyScrobblesBot.LastFm.Album.myalbum(message)

      x when x in ["youruser", "yu"] ->
        MyScrobblesBot.LastFm.User.youruser(message)

      x when x in ["myuser", "mu"] ->
        MyScrobblesBot.LastFm.User.myuser(message)

      x when x in ["register"] ->
        MyScrobblesBot.LastFm.User.register(message)

      "msbregister " <> username ->
        case MyScrobblesBot.Accounts.insert_or_update_user(%{
               last_fm_username: username,
               telegram_id: message.from.telegram_id
             }) do
          {:created, _user} ->
            %{
              text: "_user created successfully._",
              parse_mode: "markdown",
              chat_id: message.chat_id,
              reply_to_message_id: message.message_id
            }

          {:updated, _user} ->
            %{
              text: "_user updated successfully._",
              parse_mode: "markdown",
              chat_id: message.chat_id,
              reply_to_message_id: message.message_id
            }

          {:error, error} ->
            %{
              text: "_oh sorry you got the error: #{inspect(error)}._",
              parse_mode: "markdown",
              chat_id: message.chat_id,
              reply_to_message_id: message.message_id
            }
        end
    end
  end
end
