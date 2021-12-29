defmodule MyScrobblesBot.Helpers do
  import MyScrobblesBot.Gettext
  alias MyScrobblesBot.Telegram.Message

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


  def error_handler(request, %Message{} = message) do
    case request do
      {:ok, info} ->
        {:ok, info}

      {:error, %{"message" => msg}} ->
        Telegram.send_message(%{
          text: msg,
          parse_mode: "HTML",
          chat_id: message.chat_id,
          reply_to_message_id: message.message_id
        })

      {:error, %{reason: reason}} ->
        Telegram.send_message(%{
          text: reason,
          parse_mode: "HTML",
          chat_id: message.chat_id,
          reply_to_message_id: message.message_id
        })

      {:error, error} ->
        Telegram.send_message(%{
          text: error,
          parse_mode: "HTML",
          chat_id: message.chat_id,
          reply_to_message_id: message.message_id
        })
    end
  end

end
