defmodule MyScrobblesBot.Repo.Migrations.CreateUserConfs do
  use Ecto.Migration

  def change do
    create table(:user_confs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :share_username?, :boolean, default: true, null: false
      add :private?, :boolean, default: false, null: false
      add :language, :integer
      add :show_premium?, :boolean, default: true, null: false
      add :show_as_premium?, :boolean, default: true, null: false
      add :conf_language, :integer
      add :telegram_id, :string
      add :banned?, :boolean, default: false, null: false
      add :ban_expiration, :date
      add :country, :string
      add :continent, :string
      add :email, :string
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:user_confs, [:user_id])
  end
end
