defmodule MyScrobblesBot.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :is_premium?, :boolean, default: false, null: false
      add :telegram_id, :string
      add :last_fm_username, :string

      timestamps()
    end
  end
end
