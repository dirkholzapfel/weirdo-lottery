defmodule WeirdoLottery.Lottery.LotteryMinionTest do
  use WeirdoLottery.DataCase
  import WeirdoLottery.UsersFixtures
  alias WeirdoLottery.{Lottery.LotteryMinion, Repo}

  setup do
    {:ok, _} =
      start_supervised(
        {LotteryMinion,
         sync_points_updater: true,
         mix_lottery_drum_interval_in_milliseconds: 10,
         max_number_override: 0}
      )

    :ok
  end

  test "draw_winners/1 returns the winners and the timestamp of the last drawing" do
    winner = user_fixture(%{points: 42})

    # First drawing
    %{timestamp: timestamp, winners: [drawn_winner]} = LotteryMinion.draw_winners()

    refute timestamp
    assert winner.id == drawn_winner.id

    # Second drawing
    %{timestamp: timestamp, winners: [drawn_winner]} = LotteryMinion.draw_winners()

    assert timestamp
    assert winner.id == drawn_winner.id
  end

  test "periodically updates the points of all users" do
    initial_points = 23
    user = user_fixture(%{points: initial_points})

    WeirdoLottery.WaitUntilTestHelper.wait_until(fn ->
      new_points = Repo.reload(user).points
      new_points != initial_points
    end)
  end

  test "periodically updates the internal max_points" do
    %{max_number: max_number} = :sys.get_state(LotteryMinion)

    WeirdoLottery.WaitUntilTestHelper.wait_until(fn ->
      %{max_number: new_max_number} = :sys.get_state(LotteryMinion)
      new_max_number != max_number
    end)
  end
end
