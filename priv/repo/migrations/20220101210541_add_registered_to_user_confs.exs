defmodule MyScrobblesBot.Repo.Migrations.AddRegisteredToUserConfs do
  use Ecto.Migration

  def change do
    alter table(:user_confs) do
      add :registered?, :boolean, default: true, null: false
    end
  end
end
