defmodule WeirdoLottery.LotteryTest do
  use WeirdoLottery.DataCase
  import WeirdoLottery.UsersFixtures
  alias WeirdoLottery.Lottery

  describe "draw_winners/1" do
    test "returns an empty list if there are no users" do
      assert [] = Lottery.draw_winners(0)
    end

    test "returns an empty list if there are no users above the points_threshold" do
      _non_winner = user_fixture(%{points: 23})
      _non_winner = user_fixture(%{points: 42})
      assert [] = Lottery.draw_winners(42)
    end

    test "returns a list with one winning user if just one user is a possible winner" do
      _non_winner = user_fixture(%{points: 23})
      possible_winner = user_fixture(%{points: 42})
      [winner] = Lottery.draw_winners(33)
      assert winner.id == possible_winner.id
    end

    test "returns a maximum of 2 winners" do
      _non_winner = user_fixture(%{points: 0})
      _non_winner = user_fixture(%{points: 1})
      possible_winner_1 = user_fixture(%{points: 23})
      possible_winner_2 = user_fixture(%{points: 42})
      possible_winner_3 = user_fixture(%{points: 77})

      possible_winner_ids =
        Enum.map([possible_winner_1, possible_winner_2, possible_winner_3], & &1.id)

      winners = Lottery.draw_winners(10)
      winner_ids = Enum.map(winners, & &1.id)

      assert length(winners) == 2
      assert Enum.all?(winner_ids, &Enum.member?(possible_winner_ids, &1))
    end

    test "draw_winners/1 randomizes the possible winners" do
      _possible_winner_1 = user_fixture(%{points: 23})
      _possible_winner_2 = user_fixture(%{points: 42})
      _possible_winner_3 = user_fixture(%{points: 77})

      Lottery.draw_winners()
      |> Enum.map(& &1.id)
      |> assert_other_users_are_drawn()
    end
  end

  defp assert_other_users_are_drawn(winner_ids) do
    other_winner_ids = Lottery.draw_winners() |> Enum.map(& &1.id)

    if Enum.sort(winner_ids) == Enum.sort(other_winner_ids) do
      assert_other_users_are_drawn(winner_ids)
    end
  end
end
