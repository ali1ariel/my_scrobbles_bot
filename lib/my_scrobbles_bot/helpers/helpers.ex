defmodule MyScrobblesBot.Helpers do
  import MyScrobblesBot.Gettext
  alias MyScrobblesBot.Telegram.Message
  alias MyScrobblesBotWeb.Services.Telegram

  @supported_languages ["en", "es", "pt-br"]

  def supported_languages, do: @supported_languages

  def month(month) do
    case month do
      1 -> gettext("January")
      2 -> gettext("February")
      3 -> gettext("March")
      4 -> gettext("April")
      5 -> gettext("May")
      6 -> gettext("June")
      7 -> gettext("July")
      8 -> gettext("August")
      9 -> gettext("September")
      10 -> gettext("October")
      11 -> gettext("November")
      12 -> gettext("December")
    end
  end

  def language_handler(lang) do
    case lang do
      "en" -> :english
      "pt-br" -> :portuguese
      "es" -> :spanish
    end
  end

  def internal_language_handler(lang) do
    case lang do
      :english -> "en"
      :portuguese -> "pt_BR"
      :spanish -> "es"
    end
  end

  def message_language_handler(lang) do
    case lang do
      "en" -> "en"
      "pt-br" -> "pt_BR"
      "es" -> "es"
    end
  end

  def set_language(language) do
    Gettext.put_locale(
      MyScrobblesBot.Gettext,
      language
    )
  end
end
