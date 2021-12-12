defmodule MyScrobblesBot.ConfsTest do
  use MyScrobblesBot.DataCase

  alias MyScrobblesBot.Confs

  describe "user_confs" do
    alias MyScrobblesBot.Confs.UserConfs

    @valid_attrs %{ban_expiration: ~D[2010-04-17], banned?: true, conf_language: 42, continent: "some continent", country: "some country", email: "some email", language: 42, private?: true, share_username?: true, show_as_premium?: true, show_premium?: true, telegram_id: "some telegram_id"}
    @update_attrs %{ban_expiration: ~D[2011-05-18], banned?: false, conf_language: 43, continent: "some updated continent", country: "some updated country", email: "some updated email", language: 43, private?: false, share_username?: false, show_as_premium?: false, show_premium?: false, telegram_id: "some updated telegram_id"}
    @invalid_attrs %{ban_expiration: nil, banned?: nil, conf_language: nil, continent: nil, country: nil, email: nil, language: nil, private?: nil, share_username?: nil, show_as_premium?: nil, show_premium?: nil, telegram_id: nil}

    def user_confs_fixture(attrs \\ %{}) do
      {:ok, user_confs} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Confs.create_user_confs()

      user_confs
    end

    test "list_user_confs/0 returns all user_confs" do
      user_confs = user_confs_fixture()
      assert Confs.list_user_confs() == [user_confs]
    end

    test "get_user_confs!/1 returns the user_confs with given id" do
      user_confs = user_confs_fixture()
      assert Confs.get_user_confs!(user_confs.id) == user_confs
    end

    test "create_user_confs/1 with valid data creates a user_confs" do
      assert {:ok, %UserConfs{} = user_confs} = Confs.create_user_confs(@valid_attrs)
      assert user_confs.ban_expiration == ~D[2010-04-17]
      assert user_confs.banned? == true
      assert user_confs.conf_language == 42
      assert user_confs.continent == "some continent"
      assert user_confs.country == "some country"
      assert user_confs.email == "some email"
      assert user_confs.language == 42
      assert user_confs.private? == true
      assert user_confs.share_username? == true
      assert user_confs.show_as_premium? == true
      assert user_confs.show_premium? == true
      assert user_confs.telegram_id == "some telegram_id"
    end

    test "create_user_confs/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Confs.create_user_confs(@invalid_attrs)
    end

    test "update_user_confs/2 with valid data updates the user_confs" do
      user_confs = user_confs_fixture()
      assert {:ok, %UserConfs{} = user_confs} = Confs.update_user_confs(user_confs, @update_attrs)
      assert user_confs.ban_expiration == ~D[2011-05-18]
      assert user_confs.banned? == false
      assert user_confs.conf_language == 43
      assert user_confs.continent == "some updated continent"
      assert user_confs.country == "some updated country"
      assert user_confs.email == "some updated email"
      assert user_confs.language == 43
      assert user_confs.private? == false
      assert user_confs.share_username? == false
      assert user_confs.show_as_premium? == false
      assert user_confs.show_premium? == false
      assert user_confs.telegram_id == "some updated telegram_id"
    end

    test "update_user_confs/2 with invalid data returns error changeset" do
      user_confs = user_confs_fixture()
      assert {:error, %Ecto.Changeset{}} = Confs.update_user_confs(user_confs, @invalid_attrs)
      assert user_confs == Confs.get_user_confs!(user_confs.id)
    end

    test "delete_user_confs/1 deletes the user_confs" do
      user_confs = user_confs_fixture()
      assert {:ok, %UserConfs{}} = Confs.delete_user_confs(user_confs)
      assert_raise Ecto.NoResultsError, fn -> Confs.get_user_confs!(user_confs.id) end
    end

    test "change_user_confs/1 returns a user_confs changeset" do
      user_confs = user_confs_fixture()
      assert %Ecto.Changeset{} = Confs.change_user_confs(user_confs)
    end
  end
end
