defmodule MyScrobblesBot.Confs.UserConfs do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "user_confs" do
    field :ban_expiration, :date
    field :banned?, :boolean, default: false
    field :conf_language, Ecto.Enum, values: [portuguese: 1, english: 2, spanish: 3]
    field :language, Ecto.Enum, values: [portuguese: 1, english: 2, spanish: 3]
    field :continent, :string
    field :country, :string
    field :email, :string
    field :private?, :boolean, default: false
    field :share_username?, :boolean, default: true
    field :show_as_premium?, :boolean, default: true
    field :show_premium?, :boolean, default: true
    field :telegram_id, :string
    field :user_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(user_confs, attrs) do
    user_confs
    |> cast(attrs, [
      :share_username?,
      :private?,
      :language,
      :show_premium?,
      :show_as_premium?,
      :conf_language,
      :telegram_id,
      :banned?,
      :ban_expiration,
      :country,
      :continent,
      :email
    ])
    |> validate_required([
      :share_username?,
      :private?,
      :language,
      :show_premium?,
      :show_as_premium?,
      :conf_language,
      :telegram_id,
      :banned?,
      :ban_expiration,
      :country,
      :continent,
      :email
    ])
  end
end
