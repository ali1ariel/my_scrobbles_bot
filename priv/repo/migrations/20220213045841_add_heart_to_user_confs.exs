defmodule MyScrobblesBot.Repo.Migrations.AddHeartToUserConfs do
  use Ecto.Migration

  def change do
    alter table(:user_confs) do
      add :heart, :integer, default: 1
    end
  end
end
