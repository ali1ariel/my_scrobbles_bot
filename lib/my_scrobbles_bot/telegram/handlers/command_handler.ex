defmodule MyScrobblesBot.Telegram.Handlers.CommandHandler do
  @moduledoc """
  Sends a simple help message
  """

  alias MyScrobblesBot.Telegram.Message
  alias MyScrobblesBotWeb.Services.Telegram
  @behaviour MyScrobblesBot.Telegram.Handlers

  @allowed_groups [
    -1001294571722,
    -1001156236779
  ]

  @admins [
    600_614_550,
  ]


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

  def match_command(%Message{text: "/" <> command, chat_type: type, chat_id: id} = message) when type == "private" or (type == "supergroup" and id in @allowed_groups) do
    command = String.downcase(command)

    case command do
      "start" ->
        %{
          text: "welcome, please, register with /msregister yourlastfmusername, changing yourlastfmusername with your last fm username.",
          parse_mode: "markdown",
          chat_id: message.chat_id,
          reply_to_message_id: message.message_id
        }

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

      "msregister " <> username ->
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

      "msgetuser " <> info ->
        if(message.from.telegram_id == 600_614_550) do
          with user = %MyScrobblesBot.Accounts.User{} <-
            MyScrobblesBot.Repo.get_by(MyScrobblesBot.Accounts.User, last_fm_username: info) do
            %{
              text: "_user: #{user.telegram_id}, ispremium: #{user.is_premium?} _",
              parse_mode: "markdown",
              chat_id: message.chat_id,
              reply_to_message_id: message.message_id
            }
          end
        else
          %{
            text: "you're not an administrator.",
            parse_mode: "markdown",
            chat_id: message.chat_id,
            reply_to_message_id: message.message_id
          }
        end

        "msgetuser" ->
          if(message.from.telegram_id in @admins) do
            with {:ok, user} <-
                   MyScrobblesBot.Accounts.get_user_by_telegram_user_id(message.reply_to_message.from.telegram_id) do
              %{
                text: "user: #{user.telegram_id}, ispremium: #{user.is_premium?}",
                parse_mode: "markdown",
                chat_id: message.chat_id,
                reply_to_message_id: message.message_id
              }
            end
          else
            %{
              text: "you're not an administrator.",
              parse_mode: "markdown",
              chat_id: message.chat_id,
              reply_to_message_id: message.message_id
            }
          end

      "mspromoteid " <> info ->
        if(message.from.telegram_id == 600_614_550) do
          infos = String.split(info)
          %MyScrobblesBot.Accounts.User{} = user =
            MyScrobblesBot.Repo.get_by(MyScrobblesBot.Accounts.User, last_fm_username: List.first(infos))
          with {:ok, %{expiration: _date}} <- MyScrobblesBot.Accounts.promote_user(user, List.last(infos)) do
            %{
              text: "_user added with successful to the premium life._",
              parse_mode: "markdown",
              chat_id: message.chat_id,
              reply_to_message_id: message.message_id
            }
          end
        else
          %{
            text: "you're not an administrator.",
            parse_mode: "markdown",
            chat_id: message.chat_id,
            reply_to_message_id: message.message_id
          }
        end

      "mspromote " <> info ->
        if(message.from.telegram_id == 600_614_550) do
          with {:ok, %{expiration: _date}} <- MyScrobblesBot.Accounts.promote_user(message, info) do
            %{
              text: "welcome #{message.reply_to_message.from.first_name} to the premium life.",
              parse_mode: "markdown",
              chat_id: message.chat_id,
              reply_to_message_id: message.message_id
            }
          end
        else
          %{
            text: "you're not an administrator.",
            parse_mode: "markdown",
            chat_id: message.chat_id,
            reply_to_message_id: message.message_id
          }
        end

      "msremove" ->
        if(message.from.telegram_id == 600_614_550) do
          with {:ok, :removed} <- MyScrobblesBot.Accounts.remove_premium_user(message) do
            %{
              text: "successfully removed.",
              parse_mode: "markdown",
              chat_id: message.chat_id,
              reply_to_message_id: message.message_id
            }
          else
            {:ok, :not_premium} ->
              %{
                text: "#{message.reply_to_message.from.first_name} is not a premium user.",
                parse_mode: "markdown",
                chat_id: message.chat_id,
                reply_to_message_id: message.message_id
              }
          end
        else
          %{
            text: "you're not an administrator.",
            parse_mode: "markdown",
            chat_id: message.chat_id,
            reply_to_message_id: message.message_id
          }
        end
        "msremoveid " <> info ->
          if(message.from.telegram_id == 600_614_550) do
            %MyScrobblesBot.Accounts.User{} = user =
              MyScrobblesBot.Accounts.get_user_by_telegram_user_id!(info)
            with {:ok, :removed} <- MyScrobblesBot.Accounts.remove_premium_user(user) do
              %{
                text: "_usuccessfully removed._",
                parse_mode: "markdown",
                chat_id: message.chat_id,
                reply_to_message_id: message.message_id
              }
            end
          else
            %{
              text: "you're not an administrator.",
              parse_mode: "markdown",
              chat_id: message.chat_id,
              reply_to_message_id: message.message_id
            }
          end
    end
  end

  def match_command(%Message{text: "/" <> command} = message) when command in ["lt", "artist", "album"] do
    %{
      text: "Esse bot está em BETA e grupo não está autorizado no momento, por favor, me removam do grupo, para me usar, entrem em @mygroupfm ou me usem no privado, porém, no momento recomendamos usar o @MeuLastFMBot.\n This bot is in BETA and this group is not allowed at this moment, please remove me, to use, please come to @mygroupfm or talk to me on my private, but we recommend to use @MeuLastFMBot.\n",
      parse_mode: "markdown",
      chat_id: message.chat_id,
      reply_to_message_id: message.message_id
    }
  end

end
