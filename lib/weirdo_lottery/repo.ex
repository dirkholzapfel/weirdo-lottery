defmodule WeirdoLottery.Repo do
  use Ecto.Repo,
    otp_app: :weirdo_lottery,
    adapter: Ecto.Adapters.Postgres
end
