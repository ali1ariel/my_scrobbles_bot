defmodule MyScrobblesBot.Services.MusicXMatch do
  @moduledoc """

  """

  require Logger
  use Tesla

  @token Application.get_env(:app, :music_x_match_token)
  @configs "?apikey=#{@token}&"

  plug(Tesla.Middleware.BaseUrl, "https://api.musixmatch.com/ws/1.1/")
  plug(Tesla.Middleware.Headers, [])
  plug(Tesla.Middleware.JSON)
  plug(Tesla.Middleware.FormUrlencoded)

  def search_song(%{trackname: track, artist: artist}) do
    method = "track.search"
    get_answer(%{"method" => method, "q_track" => track, "q_artist" => artist})
  end

  def get_song(%{track_id: track_id }) do
    method = "track.lyrics.get"
    get_answer(%{"method" => method, "track_id" => track_id})
  end

  @spec get_answer(Map.t()) :: {:error, Map.t()} | {:ok, Map.t()}
  def get_answer(args) do
    args =
      Map.merge(args, %{"format" => "json", "api_key" => "#{@token}"})
      |> Map.to_list()

    get!(@configs, query: args)
    |> response_handler()
    |> (fn {status, body} -> {status, Poison.decode!(body)} end).()
  end

  defp response_handler(response) do
    case response.status do
      200 -> {:ok, response.body}
      201 -> {:ok, response.body}
      _ -> {:error, response.body}
    end
  end
end
