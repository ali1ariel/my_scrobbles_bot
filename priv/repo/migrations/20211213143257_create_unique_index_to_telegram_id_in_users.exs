defmodule MyScrobblesBot.Repo.Migrations.CreateUniqueIndexToTelegramIdInUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      remove :telegram_id, :string
      add :telegram_id, :integer
    end
    create unique_index(:users, [:telegram_id])
  end
end
