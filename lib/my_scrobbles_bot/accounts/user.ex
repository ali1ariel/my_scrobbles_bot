defmodule MyScrobblesBot.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  # alias MyScrobblesBot.Accounts.Premium
  alias MyScrobblesBot.Accounts.UsersPremium
  alias MyScrobblesBot.Confs.UserConfs

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :is_premium?, :boolean, default: false
    field :last_fm_username, :string
    field :telegram_id, :string

    has_one :user_premium, UsersPremium, foreign_key: :user_id
    has_one :premium, through: [:user_premium, :premium]

    has_one :user_confs, UserConfs, foreign_key: :user_id

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:is_premium?, :telegram_id, :last_fm_username])
    |> validate_required([:is_premium?, :telegram_id, :last_fm_username])
    |> unique_constraint(:telegram_id)
    |> cast_assoc(:user_confs)
  end

  @doc false
  def update_changeset(user, attrs) do
    user
    |> cast(attrs, [:is_premium?, :telegram_id, :last_fm_username])
    |> validate_required([:is_premium?, :telegram_id, :last_fm_username])
    |> unique_constraint(:telegram_id)
  end
end
