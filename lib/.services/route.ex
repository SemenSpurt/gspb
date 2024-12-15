"""
%{
  route_id: integer all uniq 553!
  agency_id: string all equal "orgp"!
  route_short_name: string and "[\d]{3}[aA-zZ]{3}.
  route_long_name: string contains commas (173).
  route_type: integer %{0 => 43, 3 => 510}!

  transport_type: string
    %{
    "bus" => 463,
    "tram" => 43,
    "trolley" => 47
    }

  circular: boolean!
  urban: boolean!
  night: boolean!
}
"""

defmodule RouteParser do

  file_path = "C:/Users/SamJa/Desktop/Notebooks/feed/routes.txt"
  NimbleCSV.define(Parser, separator: ",", escape: "\"")

  records =
    file_path
    |> File.stream!
    |> Enum.drop(1)
    |> Parser.parse_stream
    |> Enum.map(
      fn [
        route,
        agency_id,
        short_name,
        long_name,
        type,
        transport,
        circular,
        urban,
        night
      ] -> {
        String.to_integer(route),
        agency_id,
        short_name,
        long_name,
        String.to_integer(type),
        transport,
        circular == "1",
        urban == "1",
        night == "1",
      }
    end)

  count =
    records
    |> Enum.map(&Kernel.elem(&1, 0)
    ) |> Enum.count

  uniq =
    records
    |> Enum.map(&Kernel.elem(&1, 0))
    |> Enum.uniq
    |> Enum.count

  all_orgp =
    records
    |> Enum.map(&Kernel.elem(&1, 1))
    |> Enum.map(fn x -> x == "orgp" end)
    |> Enum.all?()

  names_with_commas =
    records
    |> Enum.map(&Kernel.elem(&1, 3))
    |> Enum.map(&String.contains? &1, ",")
    |> Enum.filter(fn x -> x == true end)
    |> Enum.count

  route_types =
    records
    |> Enum.map(&Kernel.elem(&1, 4))
    |> Enum.frequencies

  transport_type =
    records
    |> Enum.map(&Kernel.elem(&1, 5))
    |> Enum.frequencies


  booleans =
    [6, 7, 8]
    |> Enum.map(
    fn col -> records
    |> Enum.map(&Kernel.elem(&1, col))
    |> Enum.map(&Kernel.is_boolean(&1))
    |> Enum.all?
    end)
end
