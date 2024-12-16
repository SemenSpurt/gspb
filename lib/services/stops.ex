"""
%{
  records: 8556!

  stop_id: integer all uniq 8556!

  stop_code: integer all uniq 8556! and -all (except 3) equal :stop_id : drop
    # [
    #   {41884, 41870, "МАЛЫЙ ПР. В.О.", {59.93826, 30.23253}, 0, 2, "bus"},
    #   {41885, 41871, "УЛ. ТКАЧЕЙ", {59.893068, 30.427847}, 0, 2, "bus"},
    #   {41883, 41869, "МАЛЫЙ ПР. В.О.", {59.94078, 30.22499}, 0, 2, "bus"}
    # ]

    {
      "type": "FeatureCollection",
      "features": [
      {
        "type": "Feature",
        "geometry": {
            "type": "MultiPoint",
            "coordinates": [
              [30.23253, 59.93826],
              [30.427847,59.893068],
              [30.22499, 59.94078]
            ]
          },
        "properties": {}
      }]
    }

    {"type": "FeatureCollection", "features": [ { "type": "Feature", "properties": { "name": "Point" }, "geometry": { "type": "Point", "coordinates": #{}}}]}

    ##  Somewhere in Iran

  stop_name: string contains commas
    uniq: 4288!
    + upcase uniq: 3670!
    + String.replace(" ", "") uniq: 3601!
    + String.replace("\"", "") uniq: 3595!
    + String.replace(",", "") uniq: 3556!
    + String.replace(".", "") uniq: 3546!

  {lat, lon}: {float, float} coordinates
    uniq: 8541!

  location_type: integer all equal 0  : drop
    # %{0 => 8556}!

  wheelchair_boarding: integer  : drop
    # %{1 => 1, 2 => 8555}!

    # transport_type: %{
    #   "bus" => 6315,
    #   "tram" => 897,
    #   "trolley" => 1344
    #   }
}
"""


defmodule StopParser do
  NimbleCSV.define(Parser, separator: ",", escape: "\"")

  def records do
    "C:/Users/SamJa/Desktop/Notebooks/feed/stops.txt"
    |> File.stream!
    |> Enum.drop(1)
    |> Parser.parse_stream
    |> Enum.map(fn [
        id,
        code,
        name,
        lat, lon,
        location_type,
        wheelchair_boarding,
        transport_type
      ] -> {
        String.to_integer(id),
        String.to_integer(code),
        name,
        {String.to_float(lat), String.to_float(lon)},
        String.to_integer(location_type),
        String.to_integer(wheelchair_boarding),
        transport_type
      }
    end)
  end
end

count =
  StopParser.records
  |> Enum.count

count_uniq =
  StopParser.records
  |> Enum.map(&Kernel.elem(&1, 1))
  |> Enum.uniq
  |> Enum.count

is_int =
  [0, 1, 4, 5]
  |> Enum.map(
  fn col -> StopParser.records
  |> Enum.map(&Kernel.elem(&1, col))
  |> Enum.map(&Kernel.is_integer(&1))
  |> Enum.all?
  end)
# [true, true, true, true]


id_miss_code =
  StopParser.records
  |> Enum.filter(fn row ->
    Kernel.elem(row, 0) != Kernel.elem(row, 1)
  end)

stop_freqs =
  StopParser.records
  |> Enum.map(&Kernel.elem(&1, 2))
  |> Enum.frequencies
  |> Enum.sort_by(fn {_, x} -> x end)
  |> Enum.reverse

stop_names_uniq  =
  StopParser.records
  |> Enum.map(
    &Kernel.elem(&1, 2)
    |> String.upcase
    |> String.replace(" ", "")
    |> String.replace("\"", "")
    |> String.replace(",", "")
    |> String.replace(".", "")
  ) |> Enum.uniq |> Enum.count


to_geojson =
  StopParser.records
  |> Enum.map(&Kernel.elem(&1, 3) |> Tuple.to_list)

"{'type': 'FeatureCollection', 'features': [ { 'type': 'Feature', 'properties': { 'name': 'Point' }, 'geometry': { 'type': 'Point', 'coordinates': #{inspect(StopParser.records  |> Enum.map(&Kernel.elem(&1, 3) |> Tuple.to_list))}}}]}"
