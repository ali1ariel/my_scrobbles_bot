defmodule MyScrobblesBotWeb.BotController do
  use MyScrobblesBotWeb, :controller

  require Logger
  alias MyScrobblesBot.Telegram

  @command_list [
    "lt",
    "listen",
    "mymusic",
    "mm",
    "wyl",
    "ym",
    "yourmusic",
    "ltmarked",
    "ltm",
    "mymusicmarked",
    "mmm",
    "textlisten",
    "tlisten",
    "txtl",
    "mymusictext",
    "mmt",
    "ltphoto",
    "ltp",
    "mymusicphoto",
    "mmp",
    "andyou",
    "mytrack",
    "mt",
    "andme",
    "yourtrack",
    "yt",
    "artist",
    "yourartist",
    "yar",
    "myartist",
    "mar",
    "album",
    "youralbum",
    "yal",
    "myalbum",
    "mal",
    "youruser",
    "yu",
    "myuser",
    "mu",
    "register",
    "msregister",
    "msgetuser",
    "msgetuser",
    "mspromoteid",
    "mspromote",
    "msremove",
    "msremoveid",
    "setlanguage",
    "setsystemlanguage",
    "setheart"
  ]
  def receive(conn, %{"message" => %{"text" => "/"}}), do: send_resp(conn, 204, "")

  def receive(conn, %{"message" => %{"text" => "/" <> command} = message} = _params) do
    command = command |> String.split() |> List.first |> String.downcase()
    with true <- command in @command_list,
    {:ok, message} <- Telegram.build_message(message),
         :ok <- Telegram.enqueue_processing!(message) do
      Logger.info("Message enqueued for later processing")
      send_resp(conn, 204, "")
    else
      _ ->
        send_resp(conn, 204, "")
    end
  end

  def receive(conn, %{"inline_query" => %{"query" => _} = message} = _params) do
    with {:ok, inline_query} <- Telegram.build_inline_query(message),
         :ok <- Telegram.enqueue_processing!(inline_query) do
      Logger.info("Inline Query enqueued for inline later processing")
      send_resp(conn, 204, "")
    else
      _ ->
        send_resp(conn, 204, "")
    end
  end

  def receive(conn, %{"callback_query" => %{"data" => _data} = message} = _params) do
    with {:ok, message} <- Telegram.build_callback_query(message),
         :ok <- Telegram.enqueue_processing!(message) do
      Logger.info("Message enqueued for callback later processing")
      send_resp(conn, 204, "")
    else
      _ ->
        send_resp(conn, 200, "")
    end
  end

  def receive(conn, _params), do: send_resp(conn, 204, "")

  @spec health_check(Plug.Conn.t(), any) :: Plug.Conn.t()
  def health_check(conn, _params), do: send_resp(conn, 204, "")
end
