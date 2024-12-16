"""
%{
  records: 124156!

  route_id:     integer, uniq: 549!
  service_id:   integer, uniq: 977!

  #   [
  #     {136985, 1},
  #     {137688, 1},
  #     {137685, 1},
  #     {132171, 2},
  #     {126442, 2},
  #     {136734, 2},
  #     . . .
  #     {134777, 548},
  #     {138930, 526},
  #     {137993, 508},
  #     {138511, 471},
  #     {134586, 434},
  # ]

  trip_id:      integer, uniq: 124156!

  direction_id: boolean %{false: 62221, true: 61935}!

  shape_id:     string uniq parts: 1077!
    # %{"" => 2251, "track" => 121905}!

    # [
    #   {nil, 2251},
    #   {"109752", 24},
    #   {"109753", 23},
    #   {"111906", 5},
    #   {"111907", 7},
    #   {"124032", 19},
    #   {"124033", 19},
    #   {"125865", 44},
    #   {"125866", 44},
    #   . . .
    # ]
}
"""

defmodule TripParser do

  NimbleCSV.define(Trip, separator: ",", escape: "\"")

  def records do
    "C:/Users/SamJa/Desktop/Notebooks/feed/trips.txt"
    |> File.stream!
    |> Enum.drop(1)
    |> Trip.parse_stream
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
  end
end

is_int =
  [0, 1, 2]
  |> Enum.map(
  fn col -> TripParser.records
  |> Enum.map(&Kernel.elem(&1, col))
  |> Enum.map(&Kernel.is_integer(&1))
  |> Enum.all?
  end)
# [true, true, true]

counts =
  TripParser.records
  |> Enum.map(&Kernel.elem(&1, 0))
  |> Enum.count

uniq =
  TripParser.records
  |> Enum.map(&Kernel.elem(&1, 0))
  |> Enum.uniq
  |> Enum.count


boolean =
  [3]
  |> Enum.map(
  fn col -> TripParser.records
  |> Enum.map(&Kernel.elem(&1, col))
  |> Enum.map(&Kernel.is_boolean(&1))
  |> Enum.all?
  end)

service_trips =
  TripParser.records
  |> Enum.map(
    &Kernel.elem(&1, 1)
  ) |> Enum.frequencies
  |> Enum.sort_by(fn {_, v} -> v end)
  |> Enum.reverse

direction_couts =
  TripParser.records
  |> Enum.map(&Kernel.elem(&1, 3))
  |> Enum.frequencies

shape_types =
  TripParser.records
  |> Enum.map(&Kernel.elem(&1, 4))
  |> Enum.map(&String.split(&1, "-"))
  |> Enum.map(&Enum.at(&1, 0))
  |> Enum.frequencies
  # %{"" => 2251, "track" => 121905}

empty_shapes =
  TripParser.records
  |> Enum.filter(
    fn x -> y =
      Kernel.elem(x, 4)
      |> String.split("-")
      |> Enum.at(0);
      y==""
    end)

uniq_digit_part =
  TripParser.records
  |> Enum.map(
    &Kernel.elem(&1, 4)
    |> String.split("-")
    |> Enum.at(1)
  )
  |> Enum.uniq
  |> Enum.count
