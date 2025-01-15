defmodule Feed.Services.Research.Log do
  # """
  # route_id       :string
  # direction      :integer
  # direction_id   :boolean
  # vehicle_id     :integer
  # velocity       :integer
  # vehicle_label  :string
  # order_number   :integer
  # license_plate  :string
  # position       {:array, :float}
  # timestamp      :naive_datetime
  # """

  import Geo

  alias Feed.{
    Repo,
    Ecto
  }

  @url "https://portal.gpt.adc.spb.ru/Portal/transport/internalapi/vehicles/positions/?transports=bus,tram,trolley,ship&bbox=29.498291,60.384005,30.932007,59.684381"

  def check_vehicles(url \\ @url) do
    get!(url)
    |> parse()
    |> load()
  end

  def get!(url) do
    url
    |> HTTPoison.get!()
    |> Map.fetch!(:body)
    |> Poison.decode!()
    |> Map.fetch!("result")
  end

  def parse(records) do
    records
    |> Enum.map(fn entry ->
      %{
        route_id: entry["routeId"],
        direction: entry["direction"],
        direction_id: entry["directionId"] == 1,
        velocity: entry["velocity"],
        vehicle_id: entry["vehicleId"],
        vehicle_label: entry["vehicleLabel"],
        order_number: entry["orderNumber"],
        license_plate: entry["licensePlate"],

        # TODO: Try to encode some properties into Geo.Point
        position: %Geo.Point{
          coordinates: {
            entry["position"]["lon"],
            entry["position"]["lat"]
          }
        },
        timestamp: NaiveDateTime.from_iso8601!(entry["timestamp"])
      }
    end)
  end

  def load(records) do
    records
    |> Enum.map(
      &Map.take(&1, [
        :route_id,
        :order_number,
        :direction_id,
        :vehicle_id,
        :vehicle_label,
        :license_plate
      ])
    )
    |> Enum.chunk_every(1000)
    |> Enum.map(
      &Repo.insert_all(
        Ecto.Logs.Vehicles.Vehicle,
        &1,
        conflict_targets: [:vehicle_id, :vehicle_label, :order_number],
        on_conflict: :nothing
      )
    )

    records
    |> Enum.map(
      &Map.take(&1, [
        :vehicle_id,
        :order_number,
        :timestamp,
        :position,
        :direction,
        :direction_id,
        :velocity
      ])
    )
    |> Enum.chunk_every(1000)
    |> Enum.map(
      &Repo.insert_all(
        Ecto.Logs.Positions.Position,
        &1,
        conflict_targets: [:vehicle_id, :timestamp],
        on_conflict: :nothing
      )
    )
  end
end
