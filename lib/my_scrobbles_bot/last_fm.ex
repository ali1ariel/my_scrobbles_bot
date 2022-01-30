defmodule MyScrobblesBot.LastFm do
  require MyScrobblesBot.Gettext

  @doc """
  request user information in Last FM API
  """
  @spec get_user(%{username: String.t()}) :: String.t()
  def get_user(attrs) do
    case MyScrobblesBotWeb.Services.LastFm.get_user(attrs) do
      {:ok, %{"user" => user}} ->
        {:ok, user}
      {:error, error} ->
        "error: #{error}"
    end
  end

  @spec get_recent_track(%{username: String.t()}) ::
          {:error, any}
          | {:ok,
             %{
               album: String.t(),
               artist: String.t(),
               photo: String.t(),
               playcount: String.t(),
               playing?: boolean,
               trackname: String.t(),
               userloved?: boolean,
               username: String.t()
             }}
  def get_recent_track(attrs) do
    case MyScrobblesBotWeb.Services.LastFm.get_recent_tracks(attrs) do
      {:ok, %{"error" => error, "message" => message}} ->
        {:error, "#{error} - #{message}"}

      {:ok, result} ->
        track =
          result["recenttracks"]["track"]
          |> then(&if is_list(&1), do: List.first(&1), else: &1)

        {:ok,
         %{
           trackname: track["name"],
           artist: track["artist"]["#text"],
           album: track["album"]["#text"],
           photo: Enum.find(track["image"], fn img -> img["size"] == "extralarge" end)["#text"],
           userloved?: if(track["userloved"] == "0", do: true, else: false),
           playcount: track["userplaycount"],
           playing?: Map.has_key?(track, "@attr"),
           username: attrs.username
         }}
    end
  end

  @spec get_track(%{artist: String.t(), trackname: String.t(), username: String.t()}) ::
          {:error, String.t()}
          | {:ok,
             %{
               artist: String.t(),
               playcount: String.t(),
               track: String.t(),
               userloved: boolean
             }}
  def get_track(attrs) do
    case MyScrobblesBotWeb.Services.LastFm.get_track(attrs) do
      {:ok, %{"track" => track}} ->
        {:ok,
         %{
           userloved?: if(track["userloved"] == "1", do: true, else: false),
           playcount: track["userplaycount"] |> String.to_integer()
         }}

      {:ok, %{"error" => error, "message" => message}} ->
        {:error, "#{error} - #{message}"}
    end
  end

  @spec get_album(%{artist: String.t(), album: String.t(), username: String.t()}) ::
          {:error, String.t()}
          | {:ok,
             %{
               playcount: String.t()
             }}
  def get_album(attrs) do
    case MyScrobblesBotWeb.Services.LastFm.get_album(attrs) do
      {:ok, %{"album" => album}} ->
        {:ok, album}

      {:ok, %{"error" => error, "message" => message}} ->
        {:error, "#{error} - #{message}"}
    end
  end

  @spec get_artist(%{artist: String.t(), username: String.t()}) ::
          {:error, String.t()}
          | {:ok,
             %{
               playcount: String.t()
             }}
  def get_artist(attrs) do
    case MyScrobblesBotWeb.Services.LastFm.get_artist(attrs) do
      {:ok, %{"artist" => artist}} ->
        {:ok, artist}

      {:ok, %{"error" => error, "message" => message}} ->
        {:error, "#{error} - #{message}"}
    end
  end

  def get_artist_top_tracks(attrs) do
    case MyScrobblesBotWeb.Services.LastFm.get_artist_top_tracks(attrs) do
      {:ok, %{"toptracks" => artist}} ->
        {:ok, artist}

      {:ok, %{"error" => error, "message" => message}} ->
        {:error, "#{error} - #{message}"}
    end
  end
end
