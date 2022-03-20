defmodule WeirdoLotteryWeb.API.LotteryControllerTest do
  use WeirdoLotteryWeb.ConnCase
  import WeirdoLottery.UsersFixtures
  alias WeirdoLottery.{Lottery.LotteryMinion}

  setup %{conn: conn} do
    {:ok, _} = start_supervised({LotteryMinion, max_number_override: 10})
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "GET /",
       %{conn: conn} do
    _non_winner = user_fixture(%{points: 1})
    winner_1 = user_fixture(%{points: 23})
    winner_2 = user_fixture(%{points: 42})

    # First drawing
    approx_timestamp_first_drawing = DateTime.utc_now() |> DateTime.truncate(:second)
    conn = get(conn, Routes.lottery_path(conn, :draw_winners))

    %{
      "timestamp" => nil,
      "users" => users
    } = json_response(conn, 200)

    assert Enum.member?(users, %{"id" => winner_1.id, "points" => 23})
    assert Enum.member?(users, %{"id" => winner_2.id, "points" => 42})

    # Second drawing
    conn = get(conn, Routes.lottery_path(conn, :draw_winners))

    %{
      "timestamp" => timestamp_first_drawing,
      "users" => users
    } = json_response(conn, 200)

    {:ok, timestamp_first_drawing, 0} = DateTime.from_iso8601(timestamp_first_drawing)
    assert DateTime.diff(timestamp_first_drawing, approx_timestamp_first_drawing) <= 1
    assert Enum.member?(users, %{"id" => winner_1.id, "points" => 23})
    assert Enum.member?(users, %{"id" => winner_2.id, "points" => 42})
  end
end
