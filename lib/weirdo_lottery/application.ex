defmodule WeirdoLottery.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      WeirdoLottery.Repo,
      # Start the Telemetry supervisor
      WeirdoLotteryWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: WeirdoLottery.PubSub},
      # Start the Endpoint (http/https)
      WeirdoLotteryWeb.Endpoint,
      # Start the TaskSupervisor
      {Task.Supervisor, name: WeirdoLottery.TaskSupervisor},
      # Start the PointsUpdater GenServer
      WeirdoLottery.Users.PointsUpdater
      # Start a worker by calling: WeirdoLottery.Worker.start_link(arg)
      # {WeirdoLottery.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: WeirdoLottery.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    WeirdoLotteryWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
