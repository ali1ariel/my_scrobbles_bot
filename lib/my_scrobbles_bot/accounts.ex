defmodule MyScrobblesBot.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias MyScrobblesBot.Repo

  alias MyScrobblesBot.Accounts.User
  alias MyScrobblesBot.Telegram.Message

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  def get_user_by_telegram_user_id(telegram_id) do
    case Repo.get_by(User, telegram_id: telegram_id) do
      %User{} = user ->
        {:ok, user}

      nil ->
        {:not_found, nil}
    end
  end

  def get_user_by_telegram_user_id!(telegram_id), do: Repo.get_by!(User, telegram_id: telegram_id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
    Insert or update a user.
  """
  def insert_or_update_user(attrs) do
    case get_user_by_telegram_user_id(attrs.telegram_id) do
      {:ok, user} ->
        {:updated, user |> update_user(attrs)}

      {:not_found, nil} ->
        {:created, create_user(attrs)}

      error ->
        {:error, error}
    end
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  alias MyScrobblesBot.Accounts.Premium
  alias MyScrobblesBot.Accounts.UsersPremium

  @doc """
  Returns the list of premiums.

  ## Examples

      iex> list_premiums()
      [%Premium{}, ...]

  """
  def list_premiums do
    Repo.all(Premium)
  end

  @doc """
  Gets a single premium.

  Raises `Ecto.NoResultsError` if the Premium does not exist.

  ## Examples

      iex> get_premium!(123)
      %Premium{}

      iex> get_premium!(456)
      ** (Ecto.NoResultsError)

  """
  def get_premium!(id), do: Repo.get!(Premium, id)

  @doc """
  Creates a premium.

  ## Examples

      iex> create_premium(%{field: value})
      {:ok, %Premium{}}

      iex> create_premium(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_premium(attrs \\ %{}) do
    %Premium{}
    |> Premium.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a premium.

  ## Examples

      iex> update_premium(premium, %{field: new_value})
      {:ok, %Premium{}}

      iex> update_premium(premium, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_premium(%Premium{} = premium, attrs) do
    premium
    |> Premium.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a premium.

  ## Examples

      iex> delete_premium(premium)
      {:ok, %Premium{}}

      iex> delete_premium(premium)
      {:error, %Ecto.Changeset{}}

  """
  def delete_premium(%Premium{} = premium) do
    Repo.delete(premium)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking premium changes.

  ## Examples

      iex> change_premium(premium)
      %Ecto.Changeset{data: %Premium{}}

  """
  def change_premium(%Premium{} = premium, attrs \\ %{}) do
    Premium.changeset(premium, attrs)
  end

  def add_premium_to_user(user, premium, added_method) do
    UsersPremium.changeset(%UsersPremium{}, %{user: user, premium: premium, added_method: added_method})
    |> MyScrobblesBot.Repo.insert()

    user
    |> Ecto.Changeset.change(is_premium?: true)
    |> MyScrobblesBot.Repo.update
  end


  def change_user_premium(%UsersPremium{} = users_premium, attrs \\ %{}) do
    UsersPremium.changeset(users_premium, attrs)
  end


  def remove_premium_from_user(user_premium) do

    user_premium
    |> Ecto.Changeset.change(user_id: nil)
    |> MyScrobblesBot.Repo.update

    get_user!(user_premium.user_id)
    |> Ecto.Changeset.change(is_premium?: false)
    |> MyScrobblesBot.Repo.update
  end

  def promote_user(%Message{} = message, info) do
    days = case info do
      "1w" -> 7
      "1m" -> 30
      "6m" -> 180
      "1y" -> 360
      "unlimited" -> 100000
    end
    {:ok, premium} = create_premium(%{initial_date: Date.utc_today(), final_date: Date.utc_today() |> Date.add(days), validate: (if (days == 30), do: :trial, else: :active), type: :personal})
    {:ok, user} = get_user_by_telegram_user_id(message.reply_to_message.from.telegram_id)
    add_premium_to_user(user, premium, 4)
    {:ok, %{expiration: premium.final_date}}
  end


  def promote_user(%User{} = user, info) do
    days = case info do
      "1w" -> 7
      "1m" -> 30
      "6m" -> 180
      "1y" -> 360
      "unlimited" -> 100000
    end
    {:ok, premium} = create_premium(%{initial_date: Date.utc_today(), final_date: Date.utc_today() |> Date.add(days), validate: (if (days == 30), do: :trial, else: :active), type: :personal})
    add_premium_to_user(user, premium, 4)
    {:ok, %{expiration: premium.final_date}}
  end

  def remove_premium_user(%Message{} = message) do
    get_user_by_telegram_user_id!(message.reply_to_message.from.telegram_id)
    |> remove_premium_user()
  end


  def remove_premium_user(%User{} = user) do
    user = user
    |> Repo.preload(:user_premium)

    if (!is_nil(user.user_premium)) do
      remove_premium_from_user(user.user_premium)
      {:ok, :removed}
    else
      {:ok, :not_premium}
    end

  end
end
