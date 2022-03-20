defmodule WeirdoLotteryWeb.Router do
  use WeirdoLotteryWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", WeirdoLotteryWeb.API do
    pipe_through :api

    get "/", LotteryController, :draw_winners
  end
end
