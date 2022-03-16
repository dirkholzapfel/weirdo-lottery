defmodule WeirdoLottery.UsersTest do
  use WeirdoLottery.DataCase

  alias WeirdoLottery.Users

  describe "users" do
    alias WeirdoLottery.Users.User

    import WeirdoLottery.UsersFixtures

    @invalid_attrs %{points: nil}

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Users.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Users.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{points: 42}

      assert {:ok, %User{} = user} = Users.create_user(valid_attrs)
      assert user.points == 42
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Users.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      update_attrs = %{points: 43}

      assert {:ok, %User{} = user} = Users.update_user(user, update_attrs)
      assert user.points == 43
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Users.update_user(user, @invalid_attrs)
      assert user == Users.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Users.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Users.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Users.change_user(user)
    end

    test "draw_winners/1 returns an empty list if there are no users" do
      assert [] = Users.draw_winners(0)
    end

    test "draw_winners/1 returns an empty list if there are no users above the points_threshold" do
      _non_winner = user_fixture(%{points: 23})
      _non_winner = user_fixture(%{points: 42})
      assert [] = Users.draw_winners(42)
    end

    test "draw_winners/1 returns a list with one winning user if just one user is a possible winner" do
      _non_winner = user_fixture(%{points: 23})
      possible_winner = user_fixture(%{points: 42})
      [winner] = Users.draw_winners(33)
      assert winner.id == possible_winner.id
    end

    test "draw_winners/1 returns a maximum of 2 winners" do
      _non_winner = user_fixture(%{points: 0})
      _non_winner = user_fixture(%{points: 1})
      possible_winner_1 = user_fixture(%{points: 23})
      possible_winner_2 = user_fixture(%{points: 42})
      possible_winner_3 = user_fixture(%{points: 77})

      possible_winner_ids =
        Enum.map([possible_winner_1, possible_winner_2, possible_winner_3], & &1.id)

      winners = Users.draw_winners(10)
      winner_ids = Enum.map(winners, & &1.id)

      assert length(winners) == 2
      assert Enum.all?(winner_ids, &Enum.member?(possible_winner_ids, &1))
    end

    test "draw_winners/1 randomizes the possible winners" do
      _possible_winner_1 = user_fixture(%{points: 23})
      _possible_winner_2 = user_fixture(%{points: 42})
      _possible_winner_3 = user_fixture(%{points: 77})

      Users.draw_winners()
      |> Enum.map(& &1.id)
      |> assert_other_users_are_drawn()
    end
  end

  defp assert_other_users_are_drawn(winner_ids) do
    other_winner_ids = Users.draw_winners() |> Enum.map(& &1.id)

    if Enum.sort(winner_ids) == Enum.sort(other_winner_ids) do
      assert_other_users_are_drawn(winner_ids)
    end
  end
end
