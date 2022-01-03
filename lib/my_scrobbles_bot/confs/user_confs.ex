defmodule MyScrobblesBot.Confs.UserConfs do
  use Ecto.Schema
  import Ecto.Changeset

  alias MyScrobblesBot.Accounts.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "user_confs" do
    # date of stop ban automatically
    field :ban_expiration, :date
    # if the user is banned or not.
    field :banned?, :boolean, default: false
    # language of the configs
    field :conf_language, Ecto.Enum, values: [portuguese: 1, english: 2, spanish: 3]
    # language of the bot responses
    field :language, Ecto.Enum, values: [portuguese: 1, english: 2, spanish: 3]
    # for help on payments
    field :continent, :string
    # for payments
    field :country, :string
    # to help on premium access
    field :email, :string
    # other users not allowed to obtain user informations.
    field :private?, :boolean, default: false
    # not show the username to other users.
    field :share_username?, :boolean, default: true
    # show premium info on public posts
    field :show_as_premium?, :boolean, default: true
    # show premium on personal posts
    field :show_premium?, :boolean, default: true
    # show user as he doesn`t registered
    field :registered?, :boolean, default: true
    field :telegram_id, :string

    belongs_to :user, User, foreign_key: :user_id

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
      :language,
      :conf_language,
      :telegram_id
    ])
  end
end
