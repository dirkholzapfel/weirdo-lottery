defmodule WeirdoLottery.Lottery.LotteryMinion do
  @moduledoc """
  A GenServer that handles the drawing of winners.

  Mixes the lottery drum regularly. That means:
    - Update the points of all users randomly.
    - Draw a new `max_number`, potential winners need
      more points than this threshold.
  """

  use GenServer
  alias WeirdoLottery.{Lottery, Users.PointsUpdater, Users.User}
  @name __MODULE__
  @default_mix_lottery_drum_interval_in_milliseconds :timer.minutes(1)

  @doc """
  ## Options

    * `:max_number_override` - if you want to cheat, you can override
      the `max_number`. Useful for testing.
    * `:mix_lottery_drum_interval_in_milliseconds` - how often the lottery
      drum is mixed in the background. Defaults to `:timer.minutes(1)`.
    * `:sync_points_updater` - whether `WeirdoLottery.Users.PointsUpdater`
      should work synchronously. Useful for testing. Defaults to `false`.
  """
  def start_link(opts \\ []) do
    GenServer.start_link(@name, opts, name: @name)
  end

  @spec draw_winners() :: %{timestamp: nil | DateTime.t(), winners: list(User.t())}
  @doc """
  Draws up to 2 winners. Returns them and the timestamp of the *previous* drawing.

  ## Examples

      iex> draw_winners()
      %{timestamp: ~U[2022-03-18 11:58:15.886469Z], winners: [%User{}, %User{}]}
  """
  def draw_winners() do
    GenServer.call(@name, :draw_winners)
  end

  @impl true
  def init(opts) do
    mix_lottery_drum_interval_in_milliseconds =
      Keyword.get(
        opts,
        :mix_lottery_drum_interval_in_milliseconds,
        @default_mix_lottery_drum_interval_in_milliseconds
      )

    max_number_override = Keyword.get(opts, :max_number_override)

    sync_points_updater = Keyword.get(opts, :sync_points_updater, false)

    schedule_periodic_update(mix_lottery_drum_interval_in_milliseconds)

    {:ok,
     %{
       max_number: get_random_max_number(),
       timestamp: nil,
       settings: %{
         mix_lottery_drum_interval_in_milliseconds: mix_lottery_drum_interval_in_milliseconds,
         sync_points_updater: sync_points_updater,
         max_number_override: max_number_override
       }
     }}
  end

  @impl true
  def handle_info(
        :mix_lottery_drum,
        state
      ) do
    schedule_periodic_update(state.settings.mix_lottery_drum_interval_in_milliseconds)

    if state.settings.sync_points_updater do
      PointsUpdater.start_task(send_message_when_finished: true)

      receive do
        {:points_updater, :finished} -> :noop
      end
    else
      PointsUpdater.start_task()
    end

    {:noreply, %{state | max_number: get_random_max_number()}}
  end

  @impl true
  def handle_call(
        :draw_winners,
        _from,
        %{max_number: max_number, timestamp: timestamp} = state
      ) do
    result = %{
      winners: Lottery.draw_winners(state.settings.max_number_override || max_number),
      timestamp: timestamp
    }

    {:reply, result, %{state | timestamp: DateTime.utc_now()}}
  end

  defp schedule_periodic_update(mix_lottery_drum_interval_in_milliseconds) do
    Process.send_after(self(), :mix_lottery_drum, mix_lottery_drum_interval_in_milliseconds)
  end

  defp get_random_max_number do
    Enum.random(0..100)
  end
end
