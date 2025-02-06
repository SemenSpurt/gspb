defmodule Feed.GenServer.Realtime do
  use GenServer, restart: :permanent, shutdown: 1000 * 60 * 60 * 24

  alias Feed.{
    Repo,
    Ecto
  }

  # Client

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
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
    case "https://portal.gpt.adc.spb.ru/Portal/transport/internalapi/vehicles/positions/?transports=bus,tram,trolley,ship&bbox=29.498291,60.384005,30.932007,59.684381"
         |> HTTPoison.get() do
      {:ok, response} ->
        response
        |> Map.fetch!(:body)
        |> Jason.decode!()
        |> Map.fetch!("result")
        |> Stream.map(fn entry ->
          %{
            route_id: entry["routeId"],
            vehicle_id: entry["vehicleId"],
            direction_id: entry["directionId"] == 1,
            timestamp:
              entry["timestamp"]
              |> NaiveDateTime.from_iso8601!()
              |> DateTime.from_naive!("Etc/UTC"),
            # TODO: Try to encode some properties into Geo.Point
            position: %Geo.Point{
              coordinates: {
                entry["position"]["lon"],
                entry["position"]["lat"]
              }
            }
          }
        end)
        |> Stream.map(
          &Map.take(&1, [
            :route_id,
            :vehicle_id,
            :direction_id,
            :timestamp,
            :position
          ])
        )
        |> Stream.chunk_every(1000)
        |> Enum.map(
          &Repo.insert_all(
            Ecto.Position,
            &1,
            conflict_target: [
              :route_id,
              :vehicle_id,
              :direction_id,
              :timestamp
            ],
            on_conflict: :nothing

          )
        )

      {:error, couse} ->
        File.write!(
          "./error_log.txt",
          "#{Time.utc_now()} : #{inspect(couse)}\n\n",
          [:append]
        )
    end

    # Reschedule once more
    schedule_work()

    {:noreply, state}
  end

  defp schedule_work do
    Process.send_after(self(), :get, 1000)
  end
end
