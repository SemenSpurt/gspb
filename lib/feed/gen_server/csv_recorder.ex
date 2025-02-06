defmodule Feed.GenServer.CsvRecorder do
  use GenServer, restart: :permanent, shutdown: 1000 * 60 * 60 * 24

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
        state =
          response
          |> Map.fetch!(:body)
          |> Jason.decode!()
          |> Map.fetch!("result")
          |> Stream.map(fn entry ->
            %{
              route_id: entry["routeId"],
              vehicle_id: entry["vehicleId"],
              direction_id: entry["directionId"],
              timestamp: entry["timestamp"],
              lon: entry["position"]["lon"],
              lat: entry["position"]["lat"],
              label: entry["vehicleLabel"],
              order: entry["orderNumber"],
              plate: entry["licensePlate"]
            }
          end)
          |> Stream.filter(
            &(%{
                vehicle_id: &1.vehicle_id,
                timestamp: &1.timestamp
              } not in state)
          )

        state
        |> Stream.map(
          &[
            &1.route_id,
            &1.vehicle_id,
            &1.direction_id,
            &1.timestamp,
            &1.lon,
            &1.lat,
            &1.label,
            &1.order,
            &1.plate
          ]
        )
        |> CSV.encode(headers: false)
        |> Stream.chunk_every(1000)
        |> Enum.each(&tocsv(&1))

      {:error, couse} ->
        File.write!(
          "./temp/csv_recorder_errors.txt",
          "#{Timex.now("GMT+3")} : #{inspect(couse)}\n\n",
          [:append]
        )
    end

    state =
      state
      |> Enum.map(
        &%{
          route_id: &1.vehicle_id,
          timestamp: &1.timestamp
        }
      )

    # Reschedule once more
    schedule_work()

    {:noreply, state}
  end

  defp schedule_work do
    Process.send_after(self(), :get, 1000)
  end

  defp tocsv(data) do
    file_name =
      Timex.now("GMT+3")
      |> to_string
      |> String.slice(0, 15)
      |> String.replace(":", ".")

    File.write!(
      "temp/#{file_name}0.csv",
      data,
      [:append]
    )
  end
end
