defmodule WeirdoLottery.Users.PointsUpdater do
  @moduledoc """
  A GenServer that takes care of async updating all users
  with randomized points between 0 and 100.
  """
  use GenServer
  @name __MODULE__

  def start_link(opts) do
    GenServer.start_link(@name, opts, name: @name)
  end

  @spec start_task(keyword) :: :ok | :already_started
  @doc """
  Starts a background task which updates the points of all users
  with randomized values between 0 and 100.

  Singleton pattern: Only one task can be active at any given time,
  so that the database cannot be flooded with expensive queries.

  ## Options

    * `:send_message_when_finished` - whether a message should be sent
      to the caller when the task finishes. Defaults to `false`.
      Syntax of the message: `{:points_updater, :finished}`.
    * `:min_runtime_in_milliseconds` - minimum running time of the task.
      Useful in test scenarios.

  ## Examples

      iex> start_task()
      :ok

      iex> start_task()
      :already_running

  Wait for the update to finish in the calling process:

      :ok = PointsUpdater.start_task()

      receive do
        {:points_updater, :finished} -> do_stuff()
      end
  """
  def start_task(opts \\ []) do
    send_message_when_finished = Keyword.get(opts, :send_message_when_finished, false)
    min_runtime_in_milliseconds = Keyword.get(opts, :min_runtime_in_milliseconds)

    GenServer.call(
      @name,
      {:start_task,
       send_message_when_finished: send_message_when_finished,
       min_runtime_in_milliseconds: min_runtime_in_milliseconds}
    )
  end

  @impl true
  def init(_) do
    {:ok, %{ref: nil, interested_pids: nil}}
  end

  # Task is already running, return :already_running
  @impl true
  def handle_call(
        {:start_task,
         send_message_when_finished: send_message_when_finished, min_runtime_in_milliseconds: _},
        {from_pid, _},
        %{ref: ref, interested_pids: interested_pids} = state
      )
      when is_reference(ref) do
    interested_pids =
      if send_message_when_finished do
        [from_pid | interested_pids]
      else
        interested_pids
      end

    {:reply, :already_running, %{state | interested_pids: interested_pids}}
  end

  # Task is not running, start it
  @impl true
  def handle_call(
        {:start_task,
         send_message_when_finished: send_message_when_finished,
         min_runtime_in_milliseconds: min_runtime_in_milliseconds},
        {from_pid, _},
        %{ref: nil, interested_pids: nil} = state
      ) do
    task =
      Task.Supervisor.async_nolink(
        WeirdoLottery.TaskSupervisor,
        fn ->
          if min_runtime_in_milliseconds, do: :timer.sleep(min_runtime_in_milliseconds)
          update_all_users_with_randomized_points()
        end
      )

    interested_pids =
      if send_message_when_finished do
        [from_pid]
      else
        []
      end

    {:reply, :ok, %{state | ref: task.ref, interested_pids: interested_pids}}
  end

  # Task completed successfully
  @impl true
  def handle_info({ref, _answer}, %{ref: ref, interested_pids: interested_pids} = state) do
    interested_pids
    |> Enum.uniq()
    |> Enum.each(&send(&1, {:points_updater, :finished}))

    Process.demonitor(ref, [:flush])
    {:noreply, %{state | ref: nil, interested_pids: nil}}
  end

  # Task failed
  @impl true
  def handle_info({:DOWN, ref, :process, _pid, _reason}, %{ref: ref} = state) do
    {:noreply, %{state | ref: nil, interested_pids: nil}}
  end

  defp update_all_users_with_randomized_points do
    WeirdoLottery.Repo.query!(
      "UPDATE users SET points = FLOOR(RANDOM() * 101), updated_at = NOW()",
      [],
      timeout: :timer.minutes(1)
    )
  end
end
