defmodule MyScrobblesBot.BotOutput do
  require MyScrobblesBot.Gettext

  import MyScrobblesBot.Helpers, only: [put_space: 1, put_heart: 1]

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

        #Output Message
        "<a href=\"#{Enum.at(user["image"], 2)["#text"]}\">👥</a> <b>#{Map.get(user, "name")}</b>\n#{put_space(0)}#{Gettext.gettext(MyScrobblesBot.Gettext, "got")} #{Map.get(user, "playcount")} scrobbles #{Gettext.gettext(MyScrobblesBot.Gettext, "since")} #{MyScrobblesBot.Helpers.month(date.month)} #{date.day}, #{date.year}."

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

      #Output Message
      "<a href=\"#{Enum.at(user["image"], 2)["#text"]}\">👥</a> <b>#{Map.get(user, "name")}</b> #{Gettext.gettext(MyScrobblesBot.Gettext, "got")} <i>#{Map.get(user, "playcount")} scrobbles</i> #{Gettext.gettext(MyScrobblesBot.Gettext, "since")} #{MyScrobblesBot.Helpers.month(date.month)} #{date.day}, #{date.year}.\n\n<b>#{Gettext.gettext(MyScrobblesBot.Gettext, "Some loved tracks")}</b>\n#{Enum.map(tracks, fn track -> "#{put_space(0)}#{put_heart(attrs.heart)} #{track["artist"]["name"]} - #{track["name"]}\n" end)}
🎧💎
"
    else
      {:error, error} ->
        "error: #{error}"
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
        with_photo?: with_photo,
        heart: heart
      } = value) do
    "<b>#{user |> Phoenix.HTML.html_escape() |> Phoenix.HTML.safe_to_string}</b> #{playcount_user_text(playcount, now)}:\n\n#{put_space(0)}#{if with_photo, do: "<a href=\"#{photo_link}\">🎶</a>", else: "🎶"} <b>#{track |> Phoenix.HTML.html_escape() |> Phoenix.HTML.safe_to_string}</b>\n#{put_space(0)}💿 #{album |> Phoenix.HTML.html_escape() |> Phoenix.HTML.safe_to_string}\n#{put_space(0)}👥 #{artist |> Phoenix.HTML.html_escape() |> Phoenix.HTML.safe_to_string}\n#{put_space(0)}#{if loved, do: put_heart(heart)}"
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
        verse: verse,
        heart: heart
      }) do
    "<b>#{user |> Phoenix.HTML.html_escape() |> Phoenix.HTML.safe_to_string}</b> #{playcount_user_text(playcount, now)} #{Gettext.gettext(MyScrobblesBot.Gettext, "time")}:\n\n#{put_space(0)}#{if with_photo, do: "<a href=\"#{photo_link}\">🎶</a>", else: "🎶"} <b>#{track |> Phoenix.HTML.html_escape() |> Phoenix.HTML.safe_to_string}</b>\n#{put_space(0)}💿 #{album |> Phoenix.HTML.html_escape() |> Phoenix.HTML.safe_to_string}\n#{put_space(0)}👥 #{artist |> Phoenix.HTML.html_escape() |> Phoenix.HTML.safe_to_string}\n#{put_space(0)}#{if loved, do: put_heart(heart)}\n\n<u><i>#{verse}</i></u>"
  end

  # @spec get_now_album(%{username: String.t(), user: String.t()}) :: String.t()
  def get_now_album(%{
        user: user,
        playcount: playcount,
        playing?: now,
        artist: artist,
        album: album,
        photo: photo_link,
        with_photo?: with_photo
      }) do
    "<b>#{user |> Phoenix.HTML.html_escape() |> Phoenix.HTML.safe_to_string}</b> #{playcount_user_text(playcount, now)}:\n\n#{put_space(0)}#{if with_photo, do: "<a href=\"#{photo_link}\">💿</a>", else: "💿"} <b>#{album |> Phoenix.HTML.html_escape() |> Phoenix.HTML.safe_to_string}</b>\n#{put_space(0)}👥 #{artist |> Phoenix.HTML.html_escape() |> Phoenix.HTML.safe_to_string}"
  end

  # @spec get_now_artist(%{username: String.t(), user: String.t()}) :: String.t()
  def get_now_artist(%{
        user: user,
        playcount: playcount,
        playing?: now,
        artist: artist,
        photo: photo_link,
        with_photo?: with_photo
      }) do
    "<b>#{user |> Phoenix.HTML.html_escape() |> Phoenix.HTML.safe_to_string}</b> #{playcount_user_text(playcount, now)}:\n\n#{put_space(0)}#{if with_photo, do: "<a href=\"#{photo_link}\">👥</a>", else: "👥"} <b>#{artist |> Phoenix.HTML.html_escape() |> Phoenix.HTML.safe_to_string}</b>"
  end

  def get_your_music(%{
        user: user,
        friend: friend,
        playcount: playcount,
        trackname: track,
        artist: artist,
        album: album,
        userloved?: loved,
        photo: photo_link,
        heart: heart
      }) do
    "<b>#{user |> Phoenix.HTML.html_escape() |> Phoenix.HTML.safe_to_string}</b> #{playcount_text(playcount)}:\n\n#{put_space(0)}<a href=\"#{photo_link}\">🎶</a> <b>#{track |> Phoenix.HTML.html_escape() |> Phoenix.HTML.safe_to_string}</b>\n#{put_space(0)}💿 #{album |> Phoenix.HTML.html_escape() |> Phoenix.HTML.safe_to_string}\n#{put_space(0)}👥 #{artist |> Phoenix.HTML.html_escape() |> Phoenix.HTML.safe_to_string}\n#{put_space(0)}#{if loved, do: put_heart(heart)}\n\n<u><i>#{Gettext.gettext(MyScrobblesBot.Gettext, "listening by")} #{friend |> Phoenix.HTML.html_escape() |> Phoenix.HTML.safe_to_string}</i></u>"
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
        with_photo?: with_photo,
        heart: heart
      }) do
    "<b>#{friend |> Phoenix.HTML.html_escape() |> Phoenix.HTML.safe_to_string}</b> #{playcount_text(playcount)}:\n\n#{put_space(0)}#{if with_photo, do: "<a href=\"#{photo_link}\">🎶</a>", else: "🎶"} <b>#{track |> Phoenix.HTML.html_escape() |> Phoenix.HTML.safe_to_string}</b>\n\n#{put_space(0)}💿 #{album |> Phoenix.HTML.html_escape() |> Phoenix.HTML.safe_to_string}\n#{put_space(0)}👥 #{artist |> Phoenix.HTML.html_escape() |> Phoenix.HTML.safe_to_string}\n#{if loved, do: put_heart(heart)}\n<u><i>#{Gettext.gettext(MyScrobblesBot.Gettext, "requested by")} #{user |> Phoenix.HTML.html_escape() |> Phoenix.HTML.safe_to_string}</i></u>\n"
  end

  def get_your_album(%{
        user: user,
        friend: friend,
        playcount: playcount,
        artist: artist,
        album: album,
        photo: photo_link
      }) do
    "<b>#{user |> Phoenix.HTML.html_escape() |> Phoenix.HTML.safe_to_string}</b> #{playcount_text(playcount)}:\n\n#{put_space(0)}<a href=\"#{photo_link}\">💿</a> <b>#{album |> Phoenix.HTML.html_escape() |> Phoenix.HTML.safe_to_string}</b>\n#{put_space(0)}👥 #{artist |> Phoenix.HTML.html_escape() |> Phoenix.HTML.safe_to_string}\n\n<u><i>#{Gettext.gettext(MyScrobblesBot.Gettext, "listening by")} #{friend |> Phoenix.HTML.html_escape() |> Phoenix.HTML.safe_to_string}</i></u>
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
    "<b>#{friend |> Phoenix.HTML.html_escape() |> Phoenix.HTML.safe_to_string}</b> #{playcount_text(playcount)}:\n\n#{put_space(0)}<a href=\"#{photo_link}\">💿</a> <b>#{album |> Phoenix.HTML.html_escape() |> Phoenix.HTML.safe_to_string}</b>\n#{put_space(0)}👥 #{artist |> Phoenix.HTML.html_escape() |> Phoenix.HTML.safe_to_string}\n\n<u><i>#{Gettext.gettext(MyScrobblesBot.Gettext, "requested by")} #{user |> Phoenix.HTML.html_escape() |> Phoenix.HTML.safe_to_string}</i></u>"
  end

  def get_your_artist(%{
        :user => user,
        :friend => friend,
        "stats" => stats,
        :artist => artist,
        :photo => photo_link
      }) do
    "<b>#{user |> Phoenix.HTML.html_escape() |> Phoenix.HTML.safe_to_string}</b> #{playcount_text(stats["userplaycount"])}:\n\n#{put_space(0)}<a href=\"#{photo_link}\">👥</a> <b>#{artist |> Phoenix.HTML.html_escape() |> Phoenix.HTML.safe_to_string}</b>\n\n<u><i>#{Gettext.gettext(MyScrobblesBot.Gettext, "listening by")} #{friend |> Phoenix.HTML.html_escape() |> Phoenix.HTML.safe_to_string}</i></u>"
  end

  def get_my_artist(%{
        :user => user,
        :friend => friend,
        "stats" => stats,
        :artist => artist,
        :photo => photo_link
      }) do
    "<b>#{friend |> Phoenix.HTML.html_escape() |> Phoenix.HTML.safe_to_string}</b> #{playcount_text(stats["userplaycount"])}:\n\n#{put_space(0)}<a href=\"#{photo_link}\">👥</a> <b>#{artist |> Phoenix.HTML.html_escape() |> Phoenix.HTML.safe_to_string}</b>\n\n<u><i>#{Gettext.gettext(MyScrobblesBot.Gettext, "requested by")} #{user |> Phoenix.HTML.html_escape() |> Phoenix.HTML.safe_to_string}</i></u>"
  end

  def playcount_text(playcount) when is_binary(playcount) do
    case playcount do
      "0" -> "<i>#{Gettext.gettext(MyScrobblesBot.Gettext, "never")}</i> #{Gettext.gettext(MyScrobblesBot.Gettext, "listened")}"
      "1" -> "#{Gettext.gettext(MyScrobblesBot.Gettext, "listened")} #{Gettext.gettext(MyScrobblesBot.Gettext, "only")} <i>#{Gettext.gettext(MyScrobblesBot.Gettext, "once")}</i>"
      value -> "#{Gettext.gettext(MyScrobblesBot.Gettext, "listened")} <i>#{value}</i> #{Gettext.gettext(MyScrobblesBot.Gettext, "times to")}"
    end
  end

  def playcount_text(playcount) when is_integer(playcount),
    do: playcount_text(Integer.to_string(playcount))

  def playcount_text(playcount) when is_integer(playcount),
    do: playcount_text(Integer.to_string(playcount))

  def playcount_user_text(playcount, now) when is_binary(playcount) do
    case {String.last(playcount), now} do
      {"0", true} ->
        "#{Gettext.gettext(MyScrobblesBot.Gettext, "is")} #{Gettext.gettext(MyScrobblesBot.Gettext, "listening for the")} <b>#{String.to_integer(playcount) + 1}#{Gettext.gettext(MyScrobblesBot.Gettext, "st")}</b> #{Gettext.gettext(MyScrobblesBot.Gettext, "time to")}"

      {"1", true} ->
        "#{Gettext.gettext(MyScrobblesBot.Gettext, "is")} #{Gettext.gettext(MyScrobblesBot.Gettext, "listening for the")} <b>#{String.to_integer(playcount) + 1}#{Gettext.gettext(MyScrobblesBot.Gettext, "nd")}</b> #{Gettext.gettext(MyScrobblesBot.Gettext, "time to")}"

      {"2", true} ->
        "#{Gettext.gettext(MyScrobblesBot.Gettext, "is")} #{Gettext.gettext(MyScrobblesBot.Gettext, "listening for the")} <b>#{String.to_integer(playcount) + 1}#{Gettext.gettext(MyScrobblesBot.Gettext, "rd")}</b> #{Gettext.gettext(MyScrobblesBot.Gettext, "time to")}"

      {_, true} ->
        "#{Gettext.gettext(MyScrobblesBot.Gettext, "is")} #{Gettext.gettext(MyScrobblesBot.Gettext, "listening for the")} <b>#{String.to_integer(playcount) + 1}#{Gettext.gettext(MyScrobblesBot.Gettext, "th")}</b> #{Gettext.gettext(MyScrobblesBot.Gettext, "time to")}"

      {"0", false} when playcount == "0" ->
        "<i>#{Gettext.gettext(MyScrobblesBot.Gettext, "never")}</i> #{Gettext.gettext(MyScrobblesBot.Gettext, "listened")}"

      {"1", false} when playcount == "1" ->
        "#{Gettext.gettext(MyScrobblesBot.Gettext, "listened")} #{Gettext.gettext(MyScrobblesBot.Gettext, "only")} <i>#{Gettext.gettext(MyScrobblesBot.Gettext, "once")}</i>"

      {_, false} ->
        "#{Gettext.gettext(MyScrobblesBot.Gettext, "listened")} <i>#{playcount}</i> #{Gettext.gettext(MyScrobblesBot.Gettext, "times to")}"
    end
  end


  def playcount_user_text(playcount, now) when is_integer(playcount),
    do: playcount_user_text(Integer.to_string(playcount), now)

  def playcount_user_text(playcount, now) when is_nil(playcount) do
    case now do
      true ->
        "#{Gettext.gettext(MyScrobblesBot.Gettext, "is")} #{Gettext.gettext(MyScrobblesBot.Gettext, "listening")}"

      false ->
        "#{Gettext.gettext(MyScrobblesBot.Gettext, "listened")}"
    end
  end
end
