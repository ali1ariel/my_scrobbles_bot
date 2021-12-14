defmodule MyScrobblesBot.AccountsTest do
  use MyScrobblesBot.DataCase

  alias MyScrobblesBot.Accounts

  describe "users" do
    alias MyScrobblesBot.Accounts.User

    @valid_attrs %{
      is_premium?: true,
      last_fm_username: "some last_fm_username",
      telegram_id: "some telegram_id"
    }
    @update_attrs %{
      is_premium?: false,
      last_fm_username: "some updated last_fm_username",
      telegram_id: "some updated telegram_id"
    }
    @invalid_attrs %{is_premium?: nil, last_fm_username: nil, telegram_id: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.is_premium? == true
      assert user.last_fm_username == "some last_fm_username"
      assert user.telegram_id == "some telegram_id"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Accounts.update_user(user, @update_attrs)
      assert user.is_premium? == false
      assert user.last_fm_username == "some updated last_fm_username"
      assert user.telegram_id == "some updated telegram_id"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end

  describe "premiums" do
    alias MyScrobblesBot.Accounts.Premium

    @valid_attrs %{
      final_date: ~D[2010-04-17],
      initial_date: ~D[2010-04-17],
      type: 42,
      validate: 42
    }
    @update_attrs %{
      final_date: ~D[2011-05-18],
      initial_date: ~D[2011-05-18],
      type: 43,
      validate: 43
    }
    @invalid_attrs %{final_date: nil, initial_date: nil, type: nil, validate: nil}

    def premium_fixture(attrs \\ %{}) do
      {:ok, premium} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_premium()

      premium
    end

    test "list_premiums/0 returns all premiums" do
      premium = premium_fixture()
      assert Accounts.list_premiums() == [premium]
    end

    test "get_premium!/1 returns the premium with given id" do
      premium = premium_fixture()
      assert Accounts.get_premium!(premium.id) == premium
    end

    test "create_premium/1 with valid data creates a premium" do
      assert {:ok, %Premium{} = premium} = Accounts.create_premium(@valid_attrs)
      assert premium.final_date == ~D[2010-04-17]
      assert premium.initial_date == ~D[2010-04-17]
      assert premium.type == 42
      assert premium.validate == 42
    end

    test "create_premium/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_premium(@invalid_attrs)
    end

    test "update_premium/2 with valid data updates the premium" do
      premium = premium_fixture()
      assert {:ok, %Premium{} = premium} = Accounts.update_premium(premium, @update_attrs)
      assert premium.final_date == ~D[2011-05-18]
      assert premium.initial_date == ~D[2011-05-18]
      assert premium.type == 43
      assert premium.validate == 43
    end

    test "update_premium/2 with invalid data returns error changeset" do
      premium = premium_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_premium(premium, @invalid_attrs)
      assert premium == Accounts.get_premium!(premium.id)
    end

    test "delete_premium/1 deletes the premium" do
      premium = premium_fixture()
      assert {:ok, %Premium{}} = Accounts.delete_premium(premium)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_premium!(premium.id) end
    end

    test "change_premium/1 returns a premium changeset" do
      premium = premium_fixture()
      assert %Ecto.Changeset{} = Accounts.change_premium(premium)
    end
  end
end
