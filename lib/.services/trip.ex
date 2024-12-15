"""
%{
  route_id:     124156 integer and uniq 549!
  service_id:   integer uniq 977
  trip_id:      integer
  direction_id: boolean %{false: 62221, true: 61935}
  shape_id:     string 1077 autogenerated
}
"""

defmodule TripParser do

  file_path = "C:/Users/SamJa/Desktop/Notebooks/feed/trips.txt"
  NimbleCSV.define(Parser, separator: ",", escape: "\"")

  records =
    file_path
    |> File.stream!
    |> Enum.drop(1)
    |> Parser.parse_stream
    |> Enum.map(
      fn [
        route_id,
        service_id,
        trip_id,
        direction_id,
        shape_id
      ] -> {
        String.to_integer(route_id),
        String.to_integer(service_id),
        String.to_integer(trip_id),
        direction_id == "1",
        shape_id
      }
    end)

  counts =
    records
    |> Enum.map(&Kernel.elem(&1, 0))
    |> Enum.count

  uniq =
    records
    |> Enum.map(&Kernel.elem(&1, 0))
    |> Enum.uniq
    |> Enum.count

  ints =
      [0, 1, 2]
    |> Enum.map(
    fn col -> records
    |> Enum.map(&Kernel.elem(&1, col))
    |> Enum.map(&Kernel.is_integer(&1))
    |> Enum.all?
    end)


  boolean =
    [3]
    |> Enum.map(
    fn col -> records
    |> Enum.map(&Kernel.elem(&1, col))
    |> Enum.map(&Kernel.is_boolean(&1))
    |> Enum.all?
    end)


  direction_couts =
    records
    |> Enum.map(&Kernel.elem(&1, 3))
    |> Enum.frequencies
end