"""
%{
  stop_id: integer all uniq 8556!

  stop_code: integer and !all (except 3) equal :stop_id : drop
    # [
    #   {41884, 41870, "МАЛЫЙ ПР. В.О.", {59.93826, 30.23253}, 0, 2, "bus"},
    #   {41885, 41871, "УЛ. ТКАЧЕЙ", {59.893068, 30.427847}, 0, 2, "bus"},
    #   {41883, 41869, "МАЛЫЙ ПР. В.О.", {59.94078, 30.22499}, 0, 2, "bus"}
    # ]

  stop_name: string contains commas
  {lat, lon}: {float, float} coordinates

  location_type: integer all equal 0 %{0 => 8556}! : drop
  wheelchair_boarding: integer %{1 => 1, 2 => 8555}! : drop

  transport_type: %{
    "bus" => 6315,
    "tram" => 897,
    "trolley" => 1344
    }
}
"""



defmodule StopParser do
  alias NimbleCSV

  NimbleCSV.define(Parser, separator: ",", escape: "\"")

  file_path = "C:/Users/SamJa/Desktop/Notebooks/feed/stops.txt"

  records =
    file_path
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
        transport_type
      }
    end)

  uniq_stops =
    records
    |> Enum.map(&Kernel.elem(&1, 0))

  id_miss_names =
    records
    |> Enum.filter(fn row ->
      Kernel.elem(row, 0) != Kernel.elem(row, 1)
    end)
end
