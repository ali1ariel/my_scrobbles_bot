defmodule MyScrobblesBot.BotOutput do
  require MyScrobblesBot.Gettext

  import MyScrobblesBot.Helpers, only: [put_space: 1]

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
        "<a href=\"#{Enum.at(user["image"], 2)["#text"]}\">👥</a> <>#{Map.get(user, "name")}</b>\n#{put_space(6)}#{Gettext.gettext(MyScrobblesBot.Gettext, "got")} #{Map.get(user, "playcount")} scrobbles #{Gettext.gettext(MyScrobblesBot.Gettext, "since")} #{MyScrobblesBot.Helpers.month(date.month)} #{date.day}, #{date.year}."

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
      "<a href=\"#{Enum.at(user["image"], 2)["#text"]}\">👥</a> <b>#{Map.get(user, "name")}</b> #{Gettext.gettext(MyScrobblesBot.Gettext, "got")} <i>#{Map.get(user, "playcount")} scrobbles</i> #{Gettext.gettext(MyScrobblesBot.Gettext, "since")} #{MyScrobblesBot.Helpers.month(date.month)} #{date.day}, #{date.year}.\n\n<b>#{Gettext.gettext(MyScrobblesBot.Gettext, "Some loved tracks")}</b>\n#{Enum.map(tracks, fn track -> "#{put_space(6)}💘 #{track["artist"]["name"]} - #{track["name"]}\n" end)}
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
        with_photo?: with_photo
      }) do
    "<b>#{user}</b> #{playcount_user_text(playcount, now)}#{Gettext.gettext(MyScrobblesBot.Gettext, "to")}:\n\n#{put_space(6)}#{if with_photo, do: "<a href=\"#{photo_link}\">🎶</a>", else: "🎶"} <b>#{track}</b>\n#{put_space(6)}💿 #{album}\n#{put_space(6)}👥#{artist}\n#{put_space(6)}#{if loved, do: "💘"}"
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
    "<b>#{user}</b> #{playcount_user_text(playcount, now)} #{Gettext.gettext(MyScrobblesBot.Gettext, "time")}:\n\n#{put_space(6)}#{if with_photo, do: "<a href=\"#{photo_link}\">🎶</a>", else: "🎶"} <b>#{track}</b>\n#{put_space(6)}💿 #{album}\n#{put_space(6)}👥 #{artist}\n#{put_space(6)}#{if loved, do: "💘"}\n\n<u><i>#{verse}</i></u>"
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
    "<b>#{user}</b> #{playcount_user_text(playcount, now)}:\n\n#{put_space(6)}#{if with_photo, do: "<a href=\"#{photo_link}\">💿</a>", else: "💿"} <b>#{album}</b>\n#{put_space(6)}👥 #{artist}"
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
    "<b>#{user}</b> #{playcount_user_text(playcount, now)}:\n\n#{put_space(6)}#{if with_photo, do: "<a href=\"#{photo_link}\">👥</a>", else: "👥"} <b>#{artist}</b>"
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
    "<b>#{user}</b> #{playcount_text(playcount)} #{Gettext.gettext(MyScrobblesBot.Gettext, "to")}:\n\n#{put_space(6)}<a href=\"#{photo_link}\">🎶</a> <b>#{track}</b>\n#{put_space(6)}💿 #{album}\n👥 #{artist}\n#{put_space(6)}#{if loved, do: "💘"}\n\n<u><i>#{Gettext.gettext(MyScrobblesBot.Gettext, "listening by")} #{friend}</i></u>"
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
    "<b>#{friend}</b> #{playcount_text(playcount)}:\n\n#{put_space(6)}#{if with_photo, do: "<a href=\"#{photo_link}\">🎶</a>", else: "🎶"} <b>#{track}</b>\n\n#{put_space(6)}💿 #{album}\n#{put_space(6)}👥 #{artist}\n#{if loved, do: "💘"}\n<u><i>#{Gettext.gettext(MyScrobblesBot.Gettext, "requested by")} #{user}</i></u>\n"
  end

  def get_your_album(%{
        user: user,
        friend: friend,
        playcount: playcount,
        artist: artist,
        album: album,
        photo: photo_link
      }) do
    "<b>#{user}</b> #{playcount_text(playcount)} #{Gettext.gettext(MyScrobblesBot.Gettext, "to")}:\n\n#{put_space(6)}<a href=\"#{photo_link}\">💿</a> <b>#{album}</b>\n#{put_space(6)}👥 #{artist}\n\n<u><i>#{Gettext.gettext(MyScrobblesBot.Gettext, "listening by")} #{friend}</i></u>
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
    "<b>#{friend}</b> #{playcount_text(playcount)} #{Gettext.gettext(MyScrobblesBot.Gettext, "to")}:\n\n#{put_space(6)}<a href=\"#{photo_link}\">💿</a> <b>#{album}</b>\n#{put_space(6)}👥 #{artist}\n<u><i>#{Gettext.gettext(MyScrobblesBot.Gettext, "requested by")} #{user}</i></u>"
  end

  def get_your_artist(%{
        :user => user,
        :friend => friend,
        "stats" => stats,
        :artist => artist,
        :photo => photo_link
      }) do
    "<b>#{user}</b> #{playcount_text(stats["userplaycount"])} #{Gettext.gettext(MyScrobblesBot.Gettext, "to")}:\n\n#{put_space(6)}<a href=\"#{photo_link}\">👥</a> <b>#{artist}</b>\n<u><i>#{Gettext.gettext(MyScrobblesBot.Gettext, "listening by")} #{friend}</i></u>"
  end

  def get_my_artist(%{
        :user => user,
        :friend => friend,
        "stats" => stats,
        :artist => artist,
        :photo => photo_link
      }) do
    "<b>#{friend}</b> #{playcount_text(stats["userplaycount"])} #{Gettext.gettext(MyScrobblesBot.Gettext, "to")}:\n\n#{put_space(6)}<a href=\"#{photo_link}\">👥</a> <b>#{artist}</b>\n<u><i>#{Gettext.gettext(MyScrobblesBot.Gettext, "requested by")} #{user}</i></u>"
  end

  def playcount_text(playcount) when is_binary(playcount) do
    case playcount do
      "0" -> "<i>#{Gettext.gettext(MyScrobblesBot.Gettext, "never")}</i> #{Gettext.gettext(MyScrobblesBot.Gettext, "listened")}"
      "1" -> "#{Gettext.gettext(MyScrobblesBot.Gettext, "listened")} #{Gettext.gettext(MyScrobblesBot.Gettext, "only")} <i>#{Gettext.gettext(MyScrobblesBot.Gettext, "once")}</i>"
      value -> "#{Gettext.gettext(MyScrobblesBot.Gettext, "listened")} <i>#{value}</i> #{Gettext.gettext(MyScrobblesBot.Gettext, "times")}"
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
        "#{Gettext.gettext(MyScrobblesBot.Gettext, "is")} #{Gettext.gettext(MyScrobblesBot.Gettext, "listening for the")} <b>#{String.to_integer(playcount) + 1}#{Gettext.gettext(MyScrobblesBot.Gettext, "nd")}</b> #{Gettext.gettext(MyScrobblesBot.Gettext, "time to")}"

      {_, true} ->
        "#{Gettext.gettext(MyScrobblesBot.Gettext, "is")} #{Gettext.gettext(MyScrobblesBot.Gettext, "listening for the")} <b>#{String.to_integer(playcount) + 1}#{Gettext.gettext(MyScrobblesBot.Gettext, "th")}</b> #{Gettext.gettext(MyScrobblesBot.Gettext, "time to")}"

      {"0", false} when playcount == "0" ->
        "<i>#{Gettext.gettext(MyScrobblesBot.Gettext, "never")}</i> #{Gettext.gettext(MyScrobblesBot.Gettext, "listened")}"

      {"1", false} when playcount == "1" ->
        "#{Gettext.gettext(MyScrobblesBot.Gettext, "listened")} #{Gettext.gettext(MyScrobblesBot.Gettext, "only")} <i>#{Gettext.gettext(MyScrobblesBot.Gettext, "once")}</i>"

      {_, false} ->
        "#{Gettext.gettext(MyScrobblesBot.Gettext, "listened")} <i>#{playcount}</i> #{Gettext.gettext(MyScrobblesBot.Gettext, "times")}"
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