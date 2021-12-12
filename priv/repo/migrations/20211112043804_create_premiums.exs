defmodule MyScrobblesBot.Repo.Migrations.CreatePremiums do
  use Ecto.Migration

  def change do
    create table(:premiums, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :initial_date, :date
      add :final_date, :date
      add :type, :integer
      add :validate, :integer

      timestamps()
    end

  end
end
