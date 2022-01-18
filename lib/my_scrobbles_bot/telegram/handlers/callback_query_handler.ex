defmodule MyScrobblesBot.Telegram.Handlers.CallbackQueryHandler do
  @moduledoc """
  Just logs the message
  """

  require Logger

  alias MyScrobblesBot.Telegram.CallbackQuery
  alias MyScrobblesBotWeb.Services.Telegram
  alias MyScrobblesBot.Helpers
  alias MyScrobblesBot.Accounts.User

  @behaviour MyScrobblesBot.Telegram.Handlers

  @impl true
  def handle(%CallbackQuery{data: data} = callback_query) do
    Logger.info("Received and ignored message #{callback_query.callback_query_id} - #{data}")

    match_command(callback_query)
    |> Telegram.send_message()
  end

  defp match_command(callback_query) do
    case callback_query.data do
      "post_languages-" <> language ->


        lang = Helpers.language_handler(language)

        {:ok, user } = match_user(callback_query)
        update_language(user |> MyScrobblesBot.Repo.preload(:user_confs) |> then(& &1.user_confs), lang)

        %{
          chat_id: callback_query.from.telegram_id,
          text: "your language was updated to #{lang}",
          parse_mode: "HTML"
        }

        "system_languages-" <> language ->


          lang = Helpers.language_handler(language)

          {:ok, user } = match_user(callback_query)
          update_system_language(user |> MyScrobblesBot.Repo.preload(:user_confs) |> then(& &1.user_confs), lang)

          %{
            chat_id: callback_query.from.telegram_id,
            text: "your language was updated to #{lang}",
            parse_mode: "HTML"
          }
    end
  end

  def match_user(%CallbackQuery{} = callback_query) do
    case MyScrobblesBot.Accounts.get_user_by_telegram_user_id(callback_query.from.telegram_id) do
      {:ok, %User{} = user} ->
        %{user_confs: user_confs} = user |> MyScrobblesBot.Repo.preload(:user_confs)

        Gettext.put_locale(
          MyScrobblesBot.Gettext,
          (if !is_nil(user_confs), do: Helpers.internal_language_handler(user_confs.language), else: "en")
        )

        {:ok, user}

      _ ->
        {:error, nil}
    end
  end

  def update_language(user_confs, language) do
    Ecto.Changeset.change(user_confs, language: language)
    |> MyScrobblesBot.Repo.update

    Gettext.put_locale(
      MyScrobblesBot.Gettext,
      (if !is_nil(user_confs), do: Helpers.internal_language_handler(language), else: "en")
    )
  end


  def update_system_language(user_confs, language) do
    Ecto.Changeset.change(user_confs, system_language: language)
    |> MyScrobblesBot.Repo.update

    Gettext.put_locale(
      MyScrobblesBot.Gettext,
      (if !is_nil(user_confs), do: Helpers.internal_language_handler(language), else: "en")
    )
  end
end
