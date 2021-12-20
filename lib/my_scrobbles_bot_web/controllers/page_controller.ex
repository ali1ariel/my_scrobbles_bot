defmodule MyScrobblesBotWeb.PageController do
  use MyScrobblesBotWeb, :controller

  require Logger
  # alias MyScrobblesBot.Telegram

  def main(conn, _) do
    render(conn, "page.html")
  end
end
