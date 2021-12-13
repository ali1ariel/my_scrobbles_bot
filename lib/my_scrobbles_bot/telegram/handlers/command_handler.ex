defmodule MyScrobblesBot.Telegram.Handlers.CommandHandler do
  @moduledoc """
  Sends a simple help message
  """

  alias MyScrobblesBot.Telegram.Message
  alias MyScrobblesBotWeb.Services.Telegram
  @behaviour MyScrobblesBot.Telegram.Handlers

  def handle(%Message{chat_id: c_id, message_id: m_id} = message) do
    match_command(message)
    %{
      chat_id: c_id,
      reply_to_message_id: m_id,
      text: "this is *just* a _sample_ message",
      parse_mode: "markdown"

    }
    |> Telegram.send_message()
  end

  def match_command(%Message{text: "/" <> command} = _message) do
    command = String.downcase(command)
    case command do
      x when x in ["lt", "listen", "mysong", "ms"] ->
        IO.inspect(x)
      x when x in ["wyl", "ys", "yoursong"] ->
        IO.inspect(x)
      x when x in ["ltmarked", "ltm", "mysongmarked", "msm"] ->
        IO.inspect(x)
      x when x in ["textlisten", "tlisten", "txtl", "mysongtext", "mst"] ->
        IO.inspect(x)
      x when x in ["ltphoto", "ltp", "mysongphoto", "msp"] ->
        IO.inspect(x)
      x when x in ["andyou", "mymusic", "mm"] ->
        IO.inspect(x)
      x when x in ["andme", "yourmusic", "ym"] ->
        IO.inspect(x)
      x when x in ["artist"] ->
        IO.inspect(x)
      x when x in ["yourartist", "yar"] ->
        IO.inspect(x)
      x when x in ["myartist", "mar"] ->
        IO.inspect(x)
      x when x in ["album"] ->
        IO.inspect(x)
      x when x in ["youralbum", "yal"] ->
        IO.inspect(x)
      x when x in ["myalbum", "mal"] ->
        IO.inspect(x)
      x when x in ["youruser", "yu"] ->
        IO.inspect(x)
      x when x in ["myuser", "mu"] ->
        IO.inspect(x)
      x when x in ["register"] ->
        IO.inspect(x)
    end
  end

end
