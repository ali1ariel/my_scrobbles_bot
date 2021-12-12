defmodule MyScrobblesBot.Repo.Migrations.CreateUsersPremiums do
  use Ecto.Migration

  def change do
    create table(:users_premiums, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :added_method, :integer
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)
      add :premium_id, references(:premiums, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:users_premiums, [:user_id])
    create index(:users_premiums, [:premium_id])
  end
end
