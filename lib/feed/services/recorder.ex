defmodule Feed.Services.Recorder do
  defmodule Stack do
    use GenServer

    alias Feed.Services.Research.Log

      # Client

      def start_link(default) when is_binary(default) do
        GenServer.start_link(__MODULE__, default)
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
        # We schedule the work to happen in 2 hours (written in milliseconds).
        # Alternatively, one might write :timer.hours(2)
        Process.send_after(self(), :get, 1000)
      end
    end
end
