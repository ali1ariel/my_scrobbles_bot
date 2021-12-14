defmodule MyScrobblesBotWeb.Services.LastFm do
  @moduledoc """

  """

  require Logger
  use Tesla

  @token Application.get_env(:my_scrobbles_bot, :last_fm_token)
  @configs "?format=json&api_key=#{@token}&"

  plug(Tesla.Middleware.BaseUrl, "http://ws.audioscrobbler.com/2.0")
  plug(Tesla.Middleware.Headers, [])
  plug(Tesla.Middleware.JSON)
  plug(Tesla.Middleware.FormUrlencoded)

  @spec get_user(%{username: String.t()}) :: Map.t()
  def get_user(%{username: username}) do
    method = "user.getinfo"
    get_answer(%{"method" => method, "user" => username})
  end

  def get_loved_tracks(attrs) do
    attrs
    |> Map.to_list()
    |> Enum.map(fn {key, value} -> {Atom.to_string(key), value} end)
    |> then(&[{"method", "user.getlovedtracks"} | &1])
    |> Enum.reduce(%{}, fn {key, value}, acc -> Map.merge(acc, %{key => value}) end)
    |> get_answer()
  end

  @spec get_album(%{:album => String.t(), :artist => String.t(), :username => String.t()}) ::
          {:error, Map.t()} | {:ok, Map.t()}
  def get_album(%{username: username, album: album, artist: artist}) do
    method = "album.getinfo"
    get_answer(%{"method" => method, "user" => username, "artist" => artist, "album" => album})
  end

  @spec get_recent_tracks(%{:username => String.t()}) :: {:error, Map.t()} | {:ok, Map.t()}
  def get_recent_tracks(%{username: username}) do
    method = "user.getrecenttracks"
    get_answer(%{"method" => method, "user" => username})
  end

  @spec get_track(%{:artist => String.t(), :trackname => String.t(), :username => String.t()}) ::
          {:error, Map.t()} | {:ok, Map.t()}
  def get_track(%{artist: artist, trackname: trackname, username: username}) do
    method = "track.getinfo"

    get_answer(%{
      "method" => method,
      "artist" => artist,
      "track" => trackname,
      "username" => username,
      "autocorrect" => 1
    })
  end

  @spec get_artist(%{:artist => String.t(), :username => String.t()}) ::
          {:error, Map.t()} | {:ok, Map.t()}
  def get_artist(%{artist: artist, username: username}) do
    method = "artist.getinfo"

    get_answer(%{
      "method" => method,
      "artist" => artist,
      "username" => username,
      "autocorrect" => 1
    })
  end

  def get_artist_top_tracks(%{artist: artist, username: username}) do
    method = "artist.gettoptracks"

    get_answer(%{
      "method" => method,
      "artist" => artist,
      "username" => username,
      "autocorrect" => 1
    })
  end

  ### query most listeneds
  # @spec get_track(%{:username => String.t(), :period => String.t()}) :: {:error, Map.t()} | {:ok, Map.t()}
  # def get_user_top_tracks(%{username: username, period: period}) do
  #   method = "user.gettoptracks"
  #   get_answer(%{ "method" => method, "period" => period, "user" => username })
  # end

  @spec get_answer(Map.t()) :: {:error, Map.t()} | {:ok, Map.t()}
  def get_answer(args) do
    args =
      Map.merge(args, %{"format" => "json", "api_key" => "#{@token}"})
      |> Map.to_list()

    get!(@configs, query: args)
    |> response_handler()
  end

  defp response_handler(response) do
    case response.status do
      200 -> {:ok, response.body}
      201 -> {:ok, response.body}
      _ -> {:error, response.body}
    end
  end
end
