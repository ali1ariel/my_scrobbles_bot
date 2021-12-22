defmodule MyScrobblesBot.LastFm do

  alias MyScrobblesBot.Helpers
  @doc """
  request user information in Last FM API
  """
  @spec get_user(%{username: String.t()}) :: String.t()
  def get_user(attrs) do
    case MyScrobblesBotWeb.Services.LastFm.get_user(attrs) do
      {:ok, %{"user" => user}} ->
        date =
          user["registered"]["unixtime"]
          |> String.to_integer()
          |> DateTime.from_unix!(:second)

        "[👥](#{Enum.at(user["image"], 2)["#text"]}) *#{Map.get(user, "name")}* \n got #{Map.get(user, "playcount")} scrobbles since #{MyScrobblesBot.Helpers.month(date.month)} #{date.day}, #{date.year}."

      {:error, error} ->
        "error: #{error}"
    end
  end

  def get_user_plus(attrs) do
    with {:ok, %{"user" => user}} <- MyScrobblesBotWeb.Services.LastFm.get_user(attrs),
         {:ok, %{"lovedtracks" => %{"@attr" => %{"total" => total}}}} <-
           MyScrobblesBotWeb.Services.LastFm.get_loved_tracks(attrs |> Map.merge(%{limit: 1})),
         {:ok, %{"lovedtracks" => %{"track" => all_tracks}}} <-
           MyScrobblesBotWeb.Services.LastFm.get_loved_tracks(
             Map.merge(attrs, %{
               page: (div(total |> String.to_integer(), 50) + 1) |> :rand.uniform()
             })
           ) do
      tracks =
        all_tracks
        |> Enum.shuffle()
        |> Enum.take(3)

      date =
        user["registered"]["unixtime"]
        |> String.to_integer()
        |> DateTime.from_unix!(:second)

      "[👥](#{Enum.at(user["image"], 2)["#text"]}) *#{Map.get(user, "name")}* got _#{Map.get(user, "playcount")} scrobbles_ since #{MyScrobblesBot.Helpers.month(date.month)} #{date.day}, #{date.year}.\n\n*Some loved tracks*\n#{Enum.map(tracks, fn track -> "💘 #{track["artist"]["name"]} - #{track["name"]}\n" end)}\n`---premium---`\n"
    else
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

      {:error, error} ->
        {:error, error}
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

      {:error, error} ->
        {:error, error}
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

      {:error, error} ->
        {:error, error}
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

      {:error, error} ->
        {:error, error}
    end
  end

  def get_artist_top_tracks(attrs) do
    case MyScrobblesBotWeb.Services.LastFm.get_artist_top_tracks(attrs) do
      {:ok, %{"toptracks" => artist}} ->
        {:ok, artist}

      {:error, error} ->
        {:error, error}
    end
  end

  def get_now_track(%{
        user: user,
        playing?: now,
        playcount: playcount,
        trackname: track,
        artist: artist,
        album: album,
        userloved?: loved,
        photo: photo_link,
        with_photo?: with_photo
      }) do
    "*#{user}* #{playcount_user_text(playcount, now)} to:

    #{if with_photo, do: "[🎶](#{photo_link})", else: "🎶"} *#{track |> Helpers.escape_markdown()}*
    💿 #{album |> Helpers.escape_markdown()}
    👥 #{artist |> Helpers.escape_markdown()}
    #{if loved, do: "💘"}
    "
  end

  def lyrics(%{
        user: user,
        playing?: now,
        playcount: playcount,
        trackname: track,
        artist: artist,
        album: album,
        userloved?: loved,
        photo: photo_link,
        with_photo?: with_photo,
        verse: verse
      }) do
    "*#{user}* #{playcount_user_text(playcount, now)} time to:

    #{if with_photo, do: "[🎶](#{photo_link})", else: "🎶"} *#{track |> Helpers.escape_markdown()}*
    💿 #{album |> Helpers.escape_markdown()}
    👥 #{artist |> Helpers.escape_markdown()}
    #{if loved, do: "💘"}

    `#{verse}`
    "
  end

  # @spec get_now_album(%{username: String.t(), user: String.t()}) :: String.t()
  def get_now_album(%{
        user: user,
        playcount: playcount,
        playing?: now,
        artist: artist,
        album: album,
        photo: photo_link
      }) do
    "*#{user}* #{playcount_user_text(playcount, now)} to:

    [💿](#{photo_link}) *#{album |> Helpers.escape_markdown()}*
    👥 #{artist |> Helpers.escape_markdown()}
    "
  end

  # @spec get_now_artist(%{username: String.t(), user: String.t()}) :: String.t()
  def get_now_artist(%{
        user: user,
        playcount: playcount,
        playing?: now,
        artist: artist,
        photo: photo_link
      }) do
    "*#{user}* #{playcount_user_text(playcount, now)} to:

    [👥](#{photo_link}) *#{artist |> Helpers.escape_markdown()}*
    "
  end

  def get_your_music(%{
        user: user,
        friend: friend,
        playcount: playcount,
        trackname: track,
        artist: artist,
        album: album,
        userloved?: loved,
        photo: photo_link
      }) do
    "*#{user}* #{playcount_text(playcount)} to:

    [🎶](#{photo_link}) *#{track |> Helpers.escape_markdown()}*
    💿 #{album |> Helpers.escape_markdown()}
    👥 #{artist |> Helpers.escape_markdown()}
    #{if loved, do: "💘"}

    `listening by #{friend}`
    "
  end

  def get_my_music(%{
        user: user,
        friend: friend,
        playcount: playcount,
        trackname: track,
        artist: artist,
        album: album,
        userloved?: loved,
        photo: photo_link,
        with_photo?: with_photo
      }) do
    "*#{friend}* #{playcount_text(playcount)} to:

    #{if with_photo, do: "[🎶](#{photo_link})", else: "🎶"} *#{track |> Helpers.escape_markdown()}*
    💿 #{album |> Helpers.escape_markdown()}
    👥 #{artist |> Helpers.escape_markdown()}
    #{if loved, do: "💘"}

    `resquested by #{user}`
    "
  end

  def get_your_album(%{
        user: user,
        friend: friend,
        playcount: playcount,
        artist: artist,
        album: album,
        photo: photo_link
      }) do
    "*#{user}* #{playcount_text(playcount)} to:

    [💿](#{photo_link}) *#{album |> Helpers.escape_markdown()}*
    👥 #{artist |> Helpers.escape_markdown()}

    `listening by #{friend}`
    "
  end

  def get_my_album(%{
        user: user,
        friend: friend,
        playcount: playcount,
        artist: artist,
        album: album,
        photo: photo_link
      }) do
    "*#{friend}* #{playcount_text(playcount)} to:

    [💿](#{photo_link}) *#{album |> Helpers.escape_markdown()}*
    👥 #{artist |> Helpers.escape_markdown()}

    `resquested by #{user}`
    "
  end

  def get_your_artist(%{
        :user => user,
        :friend => friend,
        "stats" => stats,
        :artist => artist,
        :photo => photo_link
      }) do
    "*#{user}* #{playcount_text(stats["userplaycount"])} to:

    [👥](#{photo_link}) *#{artist |> Helpers.escape_markdown()}*

    `listening by #{friend}`
    "
  end

  def get_my_artist(%{
        :user => user,
        :friend => friend,
        "stats" => stats,
        :artist => artist,
        :photo => photo_link
      }) do
    "*#{friend}* #{playcount_text(stats["userplaycount"])} to:

    [👥](#{photo_link}) *#{artist |> Helpers.escape_markdown()}*

    `resquested by #{user}`
    "
  end

  def playcount_text(playcount) when is_binary(playcount) do
    case playcount do
      "0" -> "_never_ listened"
      "1" -> "listened only _once_"
      value -> "listened _#{value}_ times"
    end
  end

  def playcount_text(playcount) when is_integer(playcount),
    do: playcount_text(Integer.to_string(playcount))

  def playcount_text(playcount) when is_integer(playcount),
    do: playcount_text(Integer.to_string(playcount))

  def playcount_user_text(playcount, now) when is_binary(playcount) do
    case {String.last(playcount), now} do
      {"0", true} -> "is listening for the *#{String.to_integer(playcount) + 1}st* time"
      {"1", true} -> "is listening for the *#{String.to_integer(playcount) + 1}nd* time"
      {"2", true} -> "is listening for the *#{String.to_integer(playcount) + 1}rd* time"
      {_, true} -> "is listening for the *#{String.to_integer(playcount) + 1}th* time"
      {"0", false} when playcount == "0" -> "_never_ listened"
      {"1", false} when playcount == "1" -> "listened only _once_"
      {_, false} -> "listened _#{playcount}_ times"
    end
  end

  def playcount_user_text(playcount, now) when is_integer(playcount),
    do: playcount_user_text(Integer.to_string(playcount), now)
end
