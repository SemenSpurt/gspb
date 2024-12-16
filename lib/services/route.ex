"""
%{
  records: 553

  route_id: integer all uniq 553!
  agency_id: string all equal "orgp"! : drop

  route_short_name: string and "[\d]{3}[aA-zZ]{3}, uniq: 468!
    # %{1 => 407, 2 => 37, 3 => 24}

  route_long_name: string contains commas (173)
    uniq: 528!
    upcase uniq: 527!
    # %{1 => 504, 2 => 23, 3 => 1}


  route_type: integer
    # %{0 => 43, 3 => 510}!
    # transport_type "tram" ?= route_type 0 !

  transport_type: string
    # %{
    # "bus" => 463,
    # "tram" => 43,
    # "trolley" => 47
    # }!

  circular: boolean %{false: 523, true: 30}!
  urban:    boolean %{false: 56, true: 497}!
  night:    boolean %{false: 553}! : drop
}
"""


defmodule RouteParser do

  NimbleCSV.define(Route, separator: ",", escape: "\"")

  def records do
    "C:/Users/SamJa/Desktop/Notebooks/feed/routes.txt"
    |> File.stream!
    |> Enum.drop(1)
    |> Route.parse_stream
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
  end
end


count =
  RouteParser.records
  |> Enum.map(&Kernel.elem(&1, 0)
  ) |> Enum.count

uniq =
  RouteParser.records
  |> Enum.map(&Kernel.elem(&1, 0))
  |> Enum.uniq
  |> Enum.count

is_int =
  [0, 4]
  |> Enum.map(
  fn col -> RouteParser.records
  |> Enum.map(&Kernel.elem(&1, col))
  |> Enum.map(&Kernel.is_integer(&1))
  |> Enum.all?
  end)

all_orgp =
  RouteParser.records
  |> Enum.map(&Kernel.elem(&1, 1))
  |> Enum.map(fn x -> x == "orgp" end)
  |> Enum.all?()

short_name_counts =
    RouteParser.records
    |> Enum.map(&Kernel.elem(&1, 2))
    |> Enum.frequencies
    |> Enum.sort_by(fn {_, x} -> x end)
    |> Enum.reverse
    |> Enum.map(&Kernel.elem(&1, 1))
    |> Enum.frequencies

route_to_short_name =
  RouteParser.records
  |> Enum.map(
    fn x ->
      {
        Kernel.elem(x, 0),
        Kernel.elem(x, 2)
      }
    end
  )

tram_route_type =
  RouteParser.records
  |> Enum.filter(
    fn x ->
      Kernel.elem(x, 4) == 0
    end
  ) |> Enum.map(&Kernel.elem(&1, 5) == "tram")
  |> Enum.all?

names_with_commas =
  RouteParser.records
  |> Enum.map(&Kernel.elem(&1, 3))
  |> Enum.map(&String.contains? &1, ",")
  |> Enum.filter(fn x -> x == true end)
  |> Enum.count

route_types =
  RouteParser.records
  |> Enum.map(&Kernel.elem(&1, 4))
  |> Enum.frequencies

transport_type =
  RouteParser.records
  |> Enum.map(&Kernel.elem(&1, 5))
  |> Enum.frequencies


booleans =
  [6, 7, 8]
  |> Enum.map(
  fn col -> RouteParser.records
  |> Enum.map(&Kernel.elem(&1, col))
  |> Enum.map(&Kernel.is_boolean(&1))
  |> Enum.all?
  end)
