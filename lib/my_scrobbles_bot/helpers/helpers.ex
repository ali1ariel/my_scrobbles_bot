defmodule MyScrobblesBot.Helpers do
  import MyScrobblesBot.Gettext

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

  def escape_markdown(string) do
    if String.contains?(string, "*"), do: String.replace(string, "*", "\*")
    if String.contains?(string, "_"), do: String.replace(string, "_", "\_")
    if String.contains?(string, "`"), do: String.replace(string, "`", "\`")
  end
end
