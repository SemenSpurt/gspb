defmodule Feed.Services.Research.Positions do
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

  def records(file_path) do
    file_path
    |> File.stream!()
    |> FileParser.parse_stream()
    |> Enum.map(fn [
                     route_id,
                     vehicle_id,
                     direction_id,
                     timestamp,
                     lat,
                     lon,
                     label,
                     order,
                     plate
                   ] ->
      %{
        route_id: route_id,
        vehicle_id: String.to_integer(vehicle_id),
        direction_id: String.to_integer(direction_id) == 1,
        timestamp:
          timestamp
          |> NaiveDateTime.from_iso8601!()
          |> DateTime.from_naive!("Etc/UTC"),
        position: %Geo.Point{
          coordinates: {
            String.to_float(lon),
            String.to_float(lat)
          }
        },
        label: label,
        order:
          case order do
            "" -> 0
            _ -> String.to_integer(order)
          end,
        plate: plate
      }
    end)
  end
end
