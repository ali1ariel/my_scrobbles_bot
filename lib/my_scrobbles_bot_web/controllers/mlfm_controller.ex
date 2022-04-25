defmodule MyScrobblesBotWeb.MLFMController do
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
    with {:ok, inline_query} <- Telegram.build_inline_query(message),
         :ok <- Telegram.enqueue_processing!(inline_query) do
      Logger.info("Inline Query enqueued for later processing")
      send_resp(conn, 204, "")
    else
      err ->
        Logger.error("Failed handling telegram webhook with #{inspect(err)}, answering 204")
        send_resp(conn, 200, "")
    end
  end

  def receive(conn, %{"callback_query" => %{"data" => _data} = message} = _params) do
    with {:ok, message} <- Telegram.build_callback_query(message),
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


# 1 - Vegetal 2 - Responsa 3 - Presença
# 4 - #POTÊNCIA 5 - Assombração 6 - Simpatia
# 7 - Vigilante 8 - Proleta 9 - Neurose
# 10 - Compostura 11 - Maromba 12 - Pontífice
# 13 - Fofoca 14 - Capeta 15 - Agrotop
# 16 - Hippie 17 - Rabugenta 18 - Crente
# 19 - Política 20 - Coadjuvante 21 - Selvagem
# 22 - Autoridade 23 - Malandra 24 - Modelo
# 25 - Comédia 26 - Eremita 27 - Influencer
# 28 - Mártir 29 - Terapeuta 30 - Fidalgo
# 31 - Heroísmo 32 - Cone
