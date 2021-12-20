defmodule MyScrobblesBot.Telegram.Handlers.CommandHandler do
  @moduledoc """
  Sends a simple help message
  """

  alias MyScrobblesBot.Telegram.Message
  alias MyScrobblesBotWeb.Services.Telegram
  alias MyScrobblesBot.Accounts.User
  @behaviour MyScrobblesBot.Telegram.Handlers

  @allowed_groups [
    -1_001_294_571_722,
    -1_001_156_236_779
  ]

  @admins [
    600_614_550
  ]

  def handle(%Message{} = message) do
    message
    |> match_user()
    |> match_command()
    |> Telegram.send_message()

    # %{
    #   chat_id: c_id,
    #   reply_to_message_id: m_id,
    #   text: "this is *just* a _sample_ message",
    #   parse_mode: "markdown"

    # }
  end

  def match_user(%Message{} = message) do
    {message, MyScrobblesBot.Accounts.get_user_by_telegram_user_id!(message.from.telegram_id)}
  end

  def match_command({%Message{text: "/" <> command, chat_type: type, chat_id: id} = message, nil})
      when type == "private" or (type == "supergroup" and id in @allowed_groups) do
    command = String.downcase(command)

    case command do
      "msregister " <> username ->
          register(message, username)
      _ ->
        %{
          text:
            "User not found, please, register yourself.",
          parse_mode: "markdown",
          chat_id: message.chat_id,
          reply_to_message_id: message.message_id
        }
    end
  end

  def match_command(
        {%Message{text: "/" <> command, chat_type: type, chat_id: id} = message, %User{} = user}
      )
      when type == "private" or (type == "supergroup" and id in @allowed_groups) do
    command = String.downcase(command)

    case command do
      "start" ->
        %{
          text:
            "_welcome, please, register with /msregister yourlastfmusername, changing yourlastfmusername with your last fm username._\n------------------\n_Bem vindo, registre com /msregister seuuserdolastfm, trocando seuuserdolastfm pelo seu user do last fm._",
          parse_mode: "markdown",
          chat_id: message.chat_id,
          reply_to_message_id: message.message_id
        }

      x when x in ["lt", "listen", "mymusic", "mm"] ->
        MyScrobblesBot.LastFm.Track.mymusic(message, user)

      x when x in ["wyl", "ym", "yourmusic"] ->
        MyScrobblesBot.LastFm.Track.yourmusic(message)

      x when x in ["ltmarked", "ltm", "mymusicmarked", "msm"] ->
        MyScrobblesBot.LastFm.Track.mymusicmarked(message, user)

      x when x in ["textlisten", "tlisten", "txtl", "mymusictext", "mst"] ->
        MyScrobblesBot.LastFm.Track.mymusictext(message, user)

      x when x in ["ltphoto", "ltp", "mymusicphoto", "msp"] ->
        MyScrobblesBot.LastFm.Track.mymusicphoto(message, user)

      x when x in ["andyou", "mytrack", "mt"] ->
        MyScrobblesBot.LastFm.Track.mytrack(message)

      x when x in ["andme", "yourtrack", "yt"] ->
        MyScrobblesBot.LastFm.Track.yourtrack(message)

      x when x in ["artist"] ->
        MyScrobblesBot.LastFm.Artist.artist(message, user)

      x when x in ["yourartist", "yar"] ->
        MyScrobblesBot.LastFm.Artist.yourartist(message)

      x when x in ["myartist", "mar"] ->
        MyScrobblesBot.LastFm.Artist.myartist(message)

      x when x in ["album"] ->
        MyScrobblesBot.LastFm.Album.album(message, user)

      x when x in ["youralbum", "yal"] ->
        MyScrobblesBot.LastFm.Album.youralbum(message)

      x when x in ["myalbum", "mal"] ->
        MyScrobblesBot.LastFm.Album.myalbum(message)

      x when x in ["youruser", "yu"] ->
        MyScrobblesBot.LastFm.User.youruser(message)

      x when x in ["myuser", "mu"] ->
        MyScrobblesBot.LastFm.User.myuser(message, user)

      x when x in ["register", "msregister"] ->
        MyScrobblesBot.LastFm.User.register(message)

        %{
          text:
            "please, register with /msregister yourlastfmusername, changing yourlastfmusername with your last fm username._\n------------------\npor favor, registre com /msregister seuuserdolastfm, trocando seuuserdolastfm pelo seu user do last fm._",
          parse_mode: "markdown",
          chat_id: message.chat_id,
          reply_to_message_id: message.message_id
        }


      "msregister " <> username ->
        register(message, username)

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
                 MyScrobblesBot.Accounts.get_user_by_telegram_user_id(
                   message.reply_to_message.from.telegram_id
                 ) do
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

          %MyScrobblesBot.Accounts.User{} =
            user =
            MyScrobblesBot.Repo.get_by(MyScrobblesBot.Accounts.User,
              last_fm_username: List.first(infos)
            )

          with {:ok, %{expiration: _date}} <-
                 MyScrobblesBot.Accounts.promote_user(user, List.last(infos)) do
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
          %MyScrobblesBot.Accounts.User{} =
            user = MyScrobblesBot.Accounts.get_user_by_telegram_user_id!(info)

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


  def match_command({%Message{text: "/" <> command} = message, _})
      when command in ["lt", "artist", "album"] do
    %{
      text:
        "Esse bot está em BETA e grupo não está autorizado no momento, por favor, me removam do grupo, para me usar, entrem em @mygroupfm ou me usem no privado, porém, no momento recomendamos usar o @MeuLastFMBot.\n This bot is in BETA and this group is not allowed at this moment, please remove me, to use, please come to @mygroupfm or talk to me on my private, but we recommend to use @MeuLastFMBot.\n",
      parse_mode: "markdown",
      chat_id: message.chat_id,
      reply_to_message_id: message.message_id
    }
  end

  def register(%Message{} = message, username) do
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
