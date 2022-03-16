defmodule WeirdoLotteryWeb.Router do
  use WeirdoLotteryWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", WeirdoLotteryWeb do
    pipe_through :api
  end
end
