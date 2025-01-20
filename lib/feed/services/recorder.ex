defmodule Feed.Services.Recorder do
  defmodule Slave do
    use GenServer, restart: :permanent, shutdown: 1000 * 60 * 60 * 24

    alias Feed.Services.Research.Log

    # Client

    def start_link(default) when is_list(default) do
      GenServer.start_link(
        __MODULE__,
        default,
        debug: [
          {
            :log_to_file,
            Path.absname("./log.txt")
          }
        ]
      )
    end

    # Server (callbacks)

    @impl true
    def init(state) do
      schedule_work()
      {:ok, state}
    end

    @impl true
    def handle_info(:get, state) do
      # Do the desired work here
      Log.check_vehicles()

      # Reschedule once more
      schedule_work()

      {:noreply, state}
    end

    defp schedule_work do
      Process.send_after(self(), :get, 1000)
    end
  end
end
