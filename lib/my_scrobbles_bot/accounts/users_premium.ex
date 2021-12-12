defmodule MyScrobblesBot.Accounts.UsersPremium do
  use Ecto.Schema
  import Ecto.Changeset

  alias MyScrobblesBot.Accounts.User
  alias MyScrobblesBot.Accounts.Premium

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users_premiums" do
    field :added_method, Ecto.Enum, values: [main_user: 1, token: 2, link: 3, given_by_admin: 4]


    belongs_to :user, User, foreign_key: :user_id
    belongs_to :premium, Premium, foreign_key: :premium_id

    timestamps()
  end

  @doc false
  def changeset(users_premium, attrs) do
    users_premium
    |> cast(attrs, [:added_method])
    |> validate_required([:added_method])
  end
end
