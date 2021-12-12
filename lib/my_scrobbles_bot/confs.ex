defmodule MyScrobblesBot.Confs do
  @moduledoc """
  The Confs context.
  """

  import Ecto.Query, warn: false
  alias MyScrobblesBot.Repo

  alias MyScrobblesBot.Confs.UserConfs

  @doc """
  Returns the list of user_confs.

  ## Examples

      iex> list_user_confs()
      [%UserConfs{}, ...]

  """
  def list_user_confs do
    Repo.all(UserConfs)
  end

  @doc """
  Gets a single user_confs.

  Raises `Ecto.NoResultsError` if the User confs does not exist.

  ## Examples

      iex> get_user_confs!(123)
      %UserConfs{}

      iex> get_user_confs!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user_confs!(id), do: Repo.get!(UserConfs, id)

  @doc """
  Creates a user_confs.

  ## Examples

      iex> create_user_confs(%{field: value})
      {:ok, %UserConfs{}}

      iex> create_user_confs(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_confs(attrs \\ %{}) do
    %UserConfs{}
    |> UserConfs.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user_confs.

  ## Examples

      iex> update_user_confs(user_confs, %{field: new_value})
      {:ok, %UserConfs{}}

      iex> update_user_confs(user_confs, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_confs(%UserConfs{} = user_confs, attrs) do
    user_confs
    |> UserConfs.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user_confs.

  ## Examples

      iex> delete_user_confs(user_confs)
      {:ok, %UserConfs{}}

      iex> delete_user_confs(user_confs)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user_confs(%UserConfs{} = user_confs) do
    Repo.delete(user_confs)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_confs changes.

  ## Examples

      iex> change_user_confs(user_confs)
      %Ecto.Changeset{data: %UserConfs{}}

  """
  def change_user_confs(%UserConfs{} = user_confs, attrs \\ %{}) do
    UserConfs.changeset(user_confs, attrs)
  end
end
