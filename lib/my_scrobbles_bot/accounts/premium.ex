defmodule MyScrobblesBot.Accounts.Premium do
  use Ecto.Schema
  import Ecto.Changeset

  # alias MyScrobblesBot.Accounts.Premium
  alias MyScrobblesBot.Accounts.UsersPremium

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "premiums" do
    field :final_date, :date
    field :initial_date, :date
    field :validate,  Ecto.Enum, values: [trial: 1, active: 2, expired: 3]
    field :type,  Ecto.Enum, values: [personal: 1, duo: 2, group: 3]


    has_many :user_premium, UsersPremium, foreign_key: :premium_id
    has_many :user, through: [:user_premium, :user]

    timestamps()
  end

  @doc false
  def changeset(premium, attrs) do
    premium
    |> cast(attrs, [:initial_date, :final_date, :type, :validate])
    |> validate_required([:initial_date, :final_date, :type, :validate])
  end
end
