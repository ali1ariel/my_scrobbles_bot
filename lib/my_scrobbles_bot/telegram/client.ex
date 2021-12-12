defmodule MyScrobblesBot.Telegram.Client do
  @moduledoc """
  Client for the telegram API
  """

  use Tesla

  alias MyScrobblesBot.Telegram.ClientInputs

  # defp token, do: Application.get_env(:my_scrobbles_bot, __MODULE__)[:token]

  plug Tesla.Middleware.BaseUrl, "https://api.telegram.org/bot712946629:AAFmZgW9jH9O3TxfTiHSNgulRs5aLgRovPY"
  plug Tesla.Middleware.Headers
  plug Tesla.Middleware.JSON
  plug Tesla.Middleware.Logger

  @doc """
  Calls the sendMessage method in the telegram api
  """
  def send_message(params) do
    build_and_send(&post/2, "/sendMessage", ClientInputs.SendMessage, params)
  end

  defp build_and_send(fun, route, module, params) do
    with {:ok, input} <- module.build(params) do
      fun.(route, input)
    end
  end
end
