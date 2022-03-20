defmodule WeirdoLotteryWeb.API.LotteryController do
  use WeirdoLotteryWeb, :controller
  alias WeirdoLottery.Lottery.LotteryMinion

  def draw_winners(conn, _params) do
    render(conn, "drawing.json", LotteryMinion.draw_winners())
  end
end
