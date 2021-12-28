defmodule MyScrobblesBotWeb.BotController do
  use MyScrobblesBotWeb, :controller

  require Logger
  alias MyScrobblesBot.Telegram

  def receive(conn, %{"message" => %{"text" => "/" <> _} = message} = _params) do
    with {:ok, message} <- Telegram.build_message(message),
         :ok <- Telegram.enqueue_processing!(message) do
      Logger.info("Message enqueued for later processing")
      send_resp(conn, 204, "")
    else
      err ->
        Logger.error("Failed handling telegram webhook with #{inspect(err)}, answering 204")

        send_resp(conn, 204, "")
    end
  end

  def receive(conn, %{"inline_query" => %{"query" => _} = message} = _params) do
    with {:ok, message} <- Telegram.build_inline_query(message),
         :ok <- Telegram.enqueue_processing!(message) do
      Logger.info("Message enqueued for later processing")
      send_resp(conn, 204, "")
    else
      err ->
        Logger.error("Failed handling telegram webhook with #{inspect(err)}, answering 204")
        send_resp(conn, 200, "")
    end
  end

  def receive(conn, _params), do: send_resp(conn, 204, "")

  @spec health_check(Plug.Conn.t(), any) :: Plug.Conn.t()
  def health_check(conn, _params), do: send_resp(conn, 204, "")
end
