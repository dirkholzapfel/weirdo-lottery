defmodule WeirdoLottery.WaitUntilTestHelper do
  defmodule TimeoutError do
    defexception message: nil
  end

  def wait_until(condition_fn, timeout \\ 5_000) do
    timer = Process.send_after(self(), :cancel_wait_until, timeout)
    do_wait_until(condition_fn, timer)
  end

  def do_wait_until(condition_fn, timer) do
    result =
      try do
        condition_fn.()
      rescue
        _ -> false
      end

    if result do
      Process.cancel_timer(timer)
      result
    else
      receive do
        :cancel_wait_until ->
          raise TimeoutError, "received timeout in wait_until"
      after
        10 ->
          do_wait_until(condition_fn, timer)
      end
    end
  end
end
