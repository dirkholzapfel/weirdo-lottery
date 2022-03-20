defmodule WeirdoLotteryWeb.API.LotteryView do
  use WeirdoLotteryWeb, :view
  alias WeirdoLotteryWeb.API.LotteryView

  def render("drawing.json", %{winners: winners, timestamp: timestamp}) do
    timestamp = if timestamp, do: DateTime.truncate(timestamp, :second) |> DateTime.to_string()

    %{
      timestamp: timestamp,
      users: render_many(winners, LotteryView, "user.json", as: :user)
    }
  end

  def render("user.json", %{user: user}) do
    %{
      id: user.id,
      points: user.points
    }
  end
end
