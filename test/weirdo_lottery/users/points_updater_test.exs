defmodule WeirdoLottery.Users.PointsUpdaterTest do
  use WeirdoLottery.DataCase
  import WeirdoLottery.UsersFixtures
  alias WeirdoLottery.{Repo, Users, Users.PointsUpdater}

  test "updates all users with randomized points between 0 and 100" do
    Repo.query!("ALTER TABLE users DROP CONSTRAINT IF EXISTS constraint_points_range")

    _user_1 = user_fixture(%{points: -1})
    _user_2 = user_fixture(%{points: -1})
    _user_3 = user_fixture(%{points: -1})

    :ok = PointsUpdater.start_task(send_message_when_finished: true)
    assert_receive {:points_updater, :finished}

    assert Users.list_users()
           |> Enum.map(& &1.points)
           |> Enum.all?(&Enum.member?(0..100, &1))
  end

  test "sends a message to all callers when the update finished" do
    pid = self()

    task_1 =
      Task.async(fn ->
        :ok =
          PointsUpdater.start_task(
            send_message_when_finished: true,
            min_runtime_in_milliseconds: 20
          )

        send(pid, :task_started)
        assert_receive {:points_updater, :finished}
      end)

    assert_receive :task_started

    task_2 =
      Task.async(fn ->
        :already_running = PointsUpdater.start_task(send_message_when_finished: true)
        assert_receive {:points_updater, :finished}
      end)

    Task.await_many([task_1, task_2])
  end
end
