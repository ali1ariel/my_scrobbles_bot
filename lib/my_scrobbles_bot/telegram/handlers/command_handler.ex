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
    "-1001786739075",
    # Adm
    "-1001165893434"
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
    |> case do
      :nothing -> :nothing
      something -> Telegram.send_message(something)
    end
  end

  def match_user(%Message{} = message) do
    case MyScrobblesBot.Accounts.get_user_by_telegram_user_id(message.from.telegram_id) do
      {:ok, %User{} = user} ->
        {message, user}

      _ ->
        {message, nil}
    end
  end

  def match_command({%Message{text: "/" <> command, chat_type: type, chat_id: id} = message, nil})
      when type == "private" or (type == "supergroup" and id in @allowed_groups)
      do
    command = String.downcase(command)

      case command do
        "msregister " <> username ->
          register(message, username)

        _ ->
          Gettext.put_locale(
            MyScrobblesBot.Gettext,
            if(message.from.language_code in Helpers.supported_languages(),
              do: Helpers.message_language_handler(message.from.language_code),
              else: "en"
            )
          )

          "<i>#{Gettext.gettext(MyScrobblesBot.Gettext, "user_not_found")}</i>"
          |> response(message)
      end
  end

  def match_command(
        {%Message{text: "/set" <> command, chat_type: type} = message, %User{} = user}
      )
      when type == "private" do
    command = String.downcase(command)

    case command do
      "language" ->
        Helpers.set_language(user.user_confs.conf_language |> Helpers.internal_language_handler())

        select_language(message)

      "systemlanguage" ->
        Helpers.set_language(user.user_confs.conf_language |> Helpers.internal_language_handler())

        select_system_language(message)

      "heart" ->
        Helpers.set_language(user.user_confs.conf_language |> Helpers.internal_language_handler())

        select_heart(message)
    end
  end

  def match_command(
        {%Message{text: "/" <> command, chat_type: type, chat_id: id} = message, %User{} = user}
      )
      when type == "private" or (type == "supergroup" and id in @allowed_groups)
       do
    command = String.downcase(command)

    case command do
      x when x in ["lt", "listen", "mymusic", "mm"] ->
        Helpers.set_language(user.user_confs.language |> Helpers.internal_language_handler())

        MyScrobblesBot.LastFm.Track.mymusic(message, user)

      x when x in ["wyl", "ym", "yourmusic"] ->
        Helpers.set_language(user.user_confs.language |> Helpers.internal_language_handler())

        MyScrobblesBot.LastFm.Track.yourmusic(message)

      x when x in ["ltmarked", "ltm", "mymusicmarked", "mmm"] ->
        Helpers.set_language(user.user_confs.language |> Helpers.internal_language_handler())

        MyScrobblesBot.LastFm.Track.mymusicmarked(message, user)

      x when x in ["textlisten", "tlisten", "txtl", "mymusictext", "mmt"] ->
        Helpers.set_language(user.user_confs.language |> Helpers.internal_language_handler())

        MyScrobblesBot.LastFm.Track.mymusictext(message, user)

      x when x in ["ltphoto", "ltp", "mymusicphoto", "mmp"] ->
        Helpers.set_language(user.user_confs.language |> Helpers.internal_language_handler())

        MyScrobblesBot.LastFm.Track.mymusicphoto(message, user)

      x when x in ["andyou", "mytrack", "mt"] ->
        Helpers.set_language(user.user_confs.language |> Helpers.internal_language_handler())

        MyScrobblesBot.LastFm.Track.mytrack(message)

      x when x in ["andme", "yourtrack", "yt"] ->
        Helpers.set_language(user.user_confs.language |> Helpers.internal_language_handler())

        MyScrobblesBot.LastFm.Track.yourtrack(message)

      x when x in ["artist"] ->
        Helpers.set_language(user.user_confs.language |> Helpers.internal_language_handler())

        MyScrobblesBot.LastFm.Artist.artist(message, user)

      x when x in ["yourartist", "yar"] ->
        Helpers.set_language(user.user_confs.language |> Helpers.internal_language_handler())

        MyScrobblesBot.LastFm.Artist.yourartist(message)

      x when x in ["myartist", "mar"] ->
        Helpers.set_language(user.user_confs.language |> Helpers.internal_language_handler())

        MyScrobblesBot.LastFm.Artist.myartist(message)

      x when x in ["album"] ->
        Helpers.set_language(user.user_confs.language |> Helpers.internal_language_handler())

        MyScrobblesBot.LastFm.Album.album(message, user)

      x when x in ["youralbum", "yal"] ->
        Helpers.set_language(user.user_confs.language |> Helpers.internal_language_handler())

        MyScrobblesBot.LastFm.Album.youralbum(message)

      x when x in ["myalbum", "mal"] ->
        Helpers.set_language(user.user_confs.language |> Helpers.internal_language_handler())

        MyScrobblesBot.LastFm.Album.myalbum(message)

      x when x in ["youruser", "yu"] ->
        Helpers.set_language(user.user_confs.language |> Helpers.internal_language_handler())

        MyScrobblesBot.LastFm.User.youruser(message)

      x when x in ["myuser", "mu"] ->
        Helpers.set_language(user.user_confs.language |> Helpers.internal_language_handler())

        MyScrobblesBot.LastFm.User.myuser(message, user)

      x when x in ["register", "msregister"] ->
        Helpers.set_language(user.user_confs.conf_language |> Helpers.internal_language_handler())

        command_register()
        |> response(message)

      "msregister " <> username ->
        Helpers.set_language(user.user_confs.conf_language |> Helpers.internal_language_handler())

        register(message, username)

      "msgetuser " <> info ->
        Helpers.set_language(user.user_confs.conf_language |> Helpers.internal_language_handler())

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
        Helpers.set_language(user.user_confs.conf_language |> Helpers.internal_language_handler())

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
        Helpers.set_language(user.user_confs.conf_language |> Helpers.internal_language_handler())

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
        Helpers.set_language(user.user_confs.conf_language |> Helpers.internal_language_handler())

        if(message.from.telegram_id in @admins) do
          with {:ok, %{expiration: _date}} <- MyScrobblesBot.Accounts.promote_user(message, info) do
            "#{Gettext.gettext(MyScrobblesBot.Gettext, "Welcome")} #{message.reply_to_message.from.first_name} #{Gettext.gettext(MyScrobblesBot.Gettext, "to premium life")}."
            |> response(message)
          end
        else
          not_administrator()
          |> response(message)
        end

      "msremove" ->
        Helpers.set_language(user.user_confs.conf_language |> Helpers.internal_language_handler())

        if(message.from.telegram_id in @admins) do
          with {:ok, :removed} <- MyScrobblesBot.Accounts.remove_premium_user(message) do
            "successfully removed."
            |> response(message)
          else
            {:ok, :not_premium} ->
              "#{message.reply_to_message.from.first_name} #{Gettext.gettext(MyScrobblesBot.Gettext, "is not a premium user")}."
              |> response(message)
          end
        else
          not_administrator()
          |> response(message)
        end

      "msremoveid " <> info ->
        Helpers.set_language(user.user_confs.conf_language |> Helpers.internal_language_handler())

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

      "setlanguage" ->
        Helpers.set_language(user.user_confs.conf_language |> Helpers.internal_language_handler())

        select_language_group(message)

      "setsystemlanguage" ->
        Helpers.set_language(user.user_confs.conf_language |> Helpers.internal_language_handler())

        select_system_language_group(message)

      "setheart" ->
        Helpers.set_language(user.user_confs.conf_language |> Helpers.internal_language_handler())

        select_system_language_group(message)

      _ ->
        :nothing
    end
  end

  def match_command({%Message{text: "/" <> command} = message, _}) do
    if command in ["lt", "artist", "album"] do
      beta_message()
      |> response(message)
    else
      :nothing
    end
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
        "#{Gettext.gettext(MyScrobblesBot.Gettext, "user")} #{Gettext.gettext(MyScrobblesBot.Gettext, "created")} #{Gettext.gettext(MyScrobblesBot.Gettext, "successfully")}!"
        |> response(message)

      {:updated, _user} ->
        "#{Gettext.gettext(MyScrobblesBot.Gettext, "user")} #{Gettext.gettext(MyScrobblesBot.Gettext, "updated")} #{Gettext.gettext(MyScrobblesBot.Gettext, "successfully")}!"
        |> response(message)

      {:error, error} ->
        "_oh sorry you got the error: #{inspect(error)}._"
        |> response(message)
    end
  end

  def select_language(message) do
    %{
      text:
        "<i>#{Gettext.gettext(MyScrobblesBot.Gettext, "select the language of the posts")}</i>",
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
        "<i>#{Gettext.gettext(MyScrobblesBot.Gettext, "select the language of the options, helps and other system items")}</i>.",
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

  def select_language_group(message) do
    %{
      text:
        "<i>#{Gettext.gettext(MyScrobblesBot.Gettext, "This command is not allowed in groups")}.</i>",
      parse_mode: "HTML",
      chat_id: message.chat_id,
      reply_to_message_id: message.message_id
    }
  end

  def select_heart(message) do
    %{
      text:
        "<i>#{Gettext.gettext(MyScrobblesBot.Gettext, "select the heart you want in your favorites")}</i>.",
      parse_mode: "HTML",
      chat_id: message.chat_id,
      reply_to_message_id: message.message_id,
      reply_markup: %{
        inline_keyboard: [
          [
            %{text: "❤️", callback_data: "heart_selected-1"},
            %{text: "🖤", callback_data: "heart_selected-2"},
            %{text: "❤️‍🔥", callback_data: "heart_selected-3"},
            %{text: "❤️‍🩹", callback_data: "heart_selected-4"}
          ],
          [
            %{text: "❣️", callback_data: "heart_selected-5"},
            %{text: "💕", callback_data: "heart_selected-6"},
            %{text: "💗", callback_data: "heart_selected-7"},
            %{text: "💖", callback_data: "heart_selected-8"}
          ],
          [
            %{text: "💘", callback_data: "heart_selected-9"},
            %{text: "🫀", callback_data: "heart_selected-10"},
            %{text: "😍", callback_data: "heart_selected-11"},
            %{text: "🥰", callback_data: "heart_selected-12"}
          ]
        ]
      }
    }
  end

  def select_system_language_group(message) do
    %{
      text:
        "<i>#{Gettext.gettext(MyScrobblesBot.Gettext, "This command is not allowed in groups")}.</i>.",
      parse_mode: "HTML",
      chat_id: message.chat_id,
      reply_to_message_id: message.message_id
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
    "<i>#{Gettext.gettext(MyScrobblesBot.Gettext, "you're not an administrator")}.</i>"
  end

  def beta_message() do
    "<i>#{Gettext.gettext(MyScrobblesBot.Gettext, "Beta message bot")}.</i>"
  end

  def command_register() do
    "<i>#{Gettext.gettext(MyScrobblesBot.Gettext, "register command message")}.</i>"
  end

  def command_start() do
    "<i>#{Gettext.gettext(MyScrobblesBot.Gettext, "start command message")}.</i>"
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
