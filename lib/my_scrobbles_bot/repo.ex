defmodule MyScrobblesBot.Repo do
  use Ecto.Repo,
    otp_app: :my_scrobbles_bot,
    adapter: Ecto.Adapters.Postgres
end
