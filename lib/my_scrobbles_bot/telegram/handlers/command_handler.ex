defmodule MyScrobblesBot.Telegram.Handlers.CommandHandler do
  @moduledoc """
  Sends a simple help message
  """

  alias MyScrobblesBot.Telegram.Message
  alias MyScrobblesBotWeb.Services.Telegram
  alias MyScrobblesBot.Accounts.User

  alias MyScrobblesBot.Helpers

  require MyScrobblesBot.Gettext

  @behaviour MyScrobblesBot.Telegram.Handlers

  @allowed_groups [
    "-1001294571722",
    # meu last fm bot sac
    "-1001156236779",
    # MSB - grupo BETA
    "-1001786739075"
  ]

  @admins [
    # ALisson
    "600614550",
    # Josue
    "1360830999",
    # Felipe
    "1224040266",
    # Frankie
    "5073257888"
  ]

  def handle(%Message{} = message) do
    message
    |> match_user()
    |> match_command()
    |> Telegram.send_message()

  end

  def match_user(%Message{} = message) do
    case MyScrobblesBot.Accounts.get_user_by_telegram_user_id(message.from.telegram_id) do
      {:ok, %User{} = user} ->
        %{user_confs: user_confs} = user |> MyScrobblesBot.Repo.preload(:user_confs)

        Gettext.put_locale(
          MyScrobblesBot.Gettext,
          if(!is_nil(user_confs),
            do: Helpers.internal_language_handler(user_confs.language),
            else: "en"
          )
        )

        {message, user}

      _ ->
        {message, nil}
    end
  end

  def match_command({%Message{text: "/" <> command, chat_type: type, chat_id: id} = message, nil})
      when type == "private" or (type == "supergroup" and id in @allowed_groups) do
    command = String.downcase(command)

    case command do
      "msregister " <> username ->
        register(message, username)

      _ ->
        Gettext.put_locale(
          MyScrobblesBot.Gettext,
          if(message.from.language_code in Helpers.supported_languages(),
            do: Helpers.internal_language_handler(message.from.language_code),
            else: "en"
          )
        )

        "<i>#{Gettext.gettext(MyScrobblesBot.Gettext, "user_not_found")}</i>"
        |> response(message)
    end
  end

  def match_command(
        {%Message{text: "/" <> command, chat_type: type, chat_id: id} = message, %User{} = user}
      )
      when type == "private" or (type == "supergroup" and id in @allowed_groups) do
    command = String.downcase(command)

    case command do
      "start" ->
        command_start()
        |> response(message)

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
        command_register()
        |> response(message)

      "msregister " <> username ->
        register(message, username)

      "msgetuser " <> info ->
        if(message.from.telegram_id in @admins) do
          with user = %MyScrobblesBot.Accounts.User{} <-
                 MyScrobblesBot.Repo.get_by(MyScrobblesBot.Accounts.User, last_fm_username: info) do
            command_get_user(user)
            |> response(message)
          end
        else
          not_administrator()
          |> response(message)
        end

      "msgetuser" ->
        if(message.from.telegram_id in @admins) do
          with {:ok, user} <-
                 MyScrobblesBot.Accounts.get_user_by_telegram_user_id(
                   message.reply_to_message.from.telegram_id
                 ) do
            command_get_user(user)
            |> response(message)
          end
        else
          not_administrator()
          |> response(message)
        end

      "mspromoteid " <> info ->
        if(message.from.telegram_id in @admins) do
          infos = String.split(info)

          %MyScrobblesBot.Accounts.User{} =
            user =
            MyScrobblesBot.Repo.get_by(MyScrobblesBot.Accounts.User,
              last_fm_username: List.first(infos)
            )

          with {:ok, %{expiration: _date}} <-
                 MyScrobblesBot.Accounts.promote_user(user, List.last(infos)) do
            "_user added with successful to the premium life._"
            |> response(message)
          end
        else
          not_administrator()
          |> response(message)
        end

      "mspromote " <> info ->
        if(message.from.telegram_id in @admins) do
          with {:ok, %{expiration: _date}} <- MyScrobblesBot.Accounts.promote_user(message, info) do
            "Welcome #{message.reply_to_message.from.first_name} to premium life."
            |> response(message)
          end
        else
          not_administrator()
          |> response(message)
        end

      "msremove" ->
        if(message.from.telegram_id in @admins) do
          with {:ok, :removed} <- MyScrobblesBot.Accounts.remove_premium_user(message) do
            "successfully removed."
            |> response(message)
          else
            {:ok, :not_premium} ->
              "#{message.reply_to_message.from.first_name} is not a premium user."
              |> response(message)
          end
        else
          not_administrator()
          |> response(message)
        end

      "msremoveid " <> info ->
        if(message.from.telegram_id in @admins) do
          %MyScrobblesBot.Accounts.User{} =
            user = MyScrobblesBot.Accounts.get_user_by_telegram_user_id!(info)

          with {:ok, :removed} <- MyScrobblesBot.Accounts.remove_premium_user(user) do
            "_usuccessfully removed._"
            |> response(message)
          end
        else
          not_administrator()
          |> response(message)
        end

      "selectlanguage" ->
        select_language(message)

      "selectsystemlanguage" ->
        select_system_language(message)
    end
  end

  def match_command({%Message{text: "/" <> command} = message, _})
      when command in ["lt", "artist", "album"] do
    beta_message()
    |> response(message)
  end

  def register(%Message{} = message, username) do
    case MyScrobblesBot.Accounts.insert_or_update_user(%{
           last_fm_username: username,
           telegram_id: message.from.telegram_id,
           user_confs: %{
             telegram_id: message.from.telegram_id,
             language: Helpers.language_handler(message.from.language_code),
             conf_language: Helpers.language_handler(message.from.language_code)
           }
         }) do
      {:created, _user} ->
        "_user created successfully._"
        |> response(message)

      {:updated, _user} ->
        "_user updated successfully._"
        |> response(message)

      {:error, error} ->
        "_oh sorry you got the error: #{inspect(error)}._"
        |> response(message)
    end
  end

  def select_language(message) do
    %{
      text: "#{Gettext.gettext(MyScrobblesBot.Gettext, "select the language of the posts")}",
      parse_mode: "HTML",
      chat_id: message.chat_id,
      reply_to_message_id: message.message_id,
      reply_markup: %{
        inline_keyboard: [
          [
            %{text: "pt-BR 🇧🇷", callback_data: "post_languages-pt-br"},
            %{text: "Español 🇪🇸", callback_data: "post_languages-es"}
          ],
          [%{text: "English 🇺🇸", callback_data: "post_languages-en"}]
        ]
      }
    }
  end

  def select_system_language(message) do
    %{
      text:
        "#{Gettext.gettext(MyScrobblesBot.Gettext, "select the language of the options, helps and other system items.")}",
      parse_mode: "HTML",
      chat_id: message.chat_id,
      reply_to_message_id: message.message_id,
      reply_markup: %{
        inline_keyboard: [
          [
            %{text: "pt-BR 🇧🇷", callback_data: "system_languages-pt-br"},
            %{text: "Español 🇪🇸", callback_data: "system_languages-es"}
          ],
          [%{text: "English 🇺🇸", callback_data: "system_languages-en"}]
        ]
      }
    }
  end

  def preview(string) do
    case String.length(string) do
      0 ->
        IO.puts("okay, zero")

      1 ->
        case string do
          "+" ->
            IO.puts("plus")

          _ ->
            case Integer.parse(string) do
              {number, ""} when is_integer(number) -> IO.puts("number #{number}")
              _ -> IO.puts("n eh inteiro")
            end
        end

      2 ->
        IO.puts("two_arguments")

      _ ->
        IO.puts("invalido")
    end
  end

  def command_get_user(user) do
    "_user: #{user.telegram_id}, ispremium: #{user.is_premium?} _"
  end

  def not_administrator() do
    "you're not an administrator."
  end

  def beta_message() do
    "Esse bot está em BETA e grupo não está autorizado no momento, por favor, me removam do grupo, para me usar, entrem em @mygroupfm ou me usem no privado, porém, no momento recomendamos usar o @MeuLastFMBot.
    This bot is in BETA and this group is not allowed at this moment, please remove me, to use, please come to @mygroupfm or talk to me on my private, but we recommend to use @MeuLastFMBot.
   "
  end

  def command_register() do
    "please, register with /msregister yourlastfmusername, changing yourlastfmusername with your last fm username._
    ------------------
    por favor, registre com /msregister seuuserdolastfm, trocando seuuserdolastfm pelo seu user do last fm._"
  end

  def command_start() do
    "_welcome, please, register with /msregister yourlastfmusername, changing yourlastfmusername with your last fm username._
    ------------------
    _Bem vindo, registre com /msregister seuuserdolastfm, trocando seuuserdolastfm pelo seu user do last fm._"
  end

  def response(text, message) do
    %{
      text: text,
      parse_mode: "HTML",
      chat_id: message.chat_id,
      reply_to_message_id: message.message_id
    }
  end
end
