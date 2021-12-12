defmodule MyScrobblesBot.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  # alias MyScrobblesBot.Accounts.Premium
  alias MyScrobblesBot.Accounts.UsersPremium


  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :is_premium?, :boolean, default: false
    field :last_fm_username, :string
    field :telegram_id, :string

    has_one :user_premium, UsersPremium, foreign_key: :user_id
    has_one :premium, through: [:user_premium, :premium]

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:is_premium?, :telegram_id, :last_fm_username])
    |> validate_required([:is_premium?, :telegram_id, :last_fm_username])
  end
end
