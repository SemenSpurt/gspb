defmodule TripParser do
  # """
  #   route_id:       integer
  #   service_id:     integer
  #   trip_id:        integer
  #   direction_id:   boolean
  #   shape_id:       string : может быть это поле доджно быть в routes?
  # """

  def trips(file_path \\ "C:/Users/SamJa/Desktop/Notebooks/feed/trips.txt") do
    file_path
    |> File.stream!()
    |> FileParser.parse_stream()
    |> Enum.map(
      fn [
        route_id,
        service_id,
        trip_id,
        direction_id,
        shape_id
      ] -> %{
        route_id:     String.to_integer(route_id),
        service_id:   String.to_integer(service_id),
        trip_id:      String.to_integer(trip_id),
        direction_id: direction_id,
        shape_id:     shape_id
      }
    end)
  end


  @doc "0) Как много записей в таблице trips?"
  def count_table_records, do: trips() |> Enum.count()
  # 124157


  @doc "1) Есть ли нецелочисленные значения в столбце route_id?"
  def nonintegers_in_route_id?, do: trips() |> Toolkit.check_nonintegers_in(:route_id)
  # false


  @doc "1.1) Сколько всего уникальных route_id?"
  def count_uniq_route_id, do: trips() |> Toolkit.count_uniq_in(:route_id)
  # 549


  @doc "2) Есть ли нецелочисленные значения в столбце service_id?"
  def nonintegers_in_service_id?, do: trips() |> Toolkit.check_nonintegers_in(:service_id)
  # false


  @doc "2.1) Сколько всего уникальных service_id?"
  def count_uniq_service_id, do: trips() |> Toolkit.count_uniq_in(:service_id)
  # 977


  @doc "3) Какие значения принемает столбец direction_id?"
  def direction_id_frequencies, do: trips() |> Enum.frequencies_by(& &1.direction_id)
  # %{"0" => 62221, "1" => 61936}


  @doc "4) Есть ли нецелочисленные значения в столбце trip_id?"
  def nonintegers_in_trip_id?, do: trips() |> Toolkit.check_nonintegers_in(:trip_id)
  # false


  @doc "4.1) Сколько всего уникальных trip_id?"
  def count_uniq_trip_id, do: trips() |> Toolkit.count_uniq_in(:trip_id)
  # 124157


  @doc "5) Сколько всего уникальных shape_id?"
  def count_uniq_shape_id, do: trips() |> Toolkit.count_uniq_in(:shape_id)
  # 1077


  @doc "5.1) 'track-' есть во всех записях shape_id?"
  def shape_id_prefix_frequencies do
    trips()
    |> Enum.frequencies_by(
      & &1.shape_id
      |> String.split("-")
      |> Enum.at(0)
    )
  end
  # %{"" => 2251, "track" => 121906}


  ### Multitable questions ###
  @doc "Есть ли в этой таблице route_id, которых нет в таблице routes?"
  def are_there_trips_route_ids_missed_in_routes? do
    routes =
      RouteParser.routes()
      |> Enum.map(& &1.id)

    trips()
    |> Enum.any?(& &1.route_id not in routes)
  end
  # false


  @doc "Есть ли такие shape_id, которых нет в таблице shapes?"
  def are_there_trips_shape_ids_missed_in_shapes? do
    shapes =
      ShapeParser.shapes()
      |> Enum.uniq_by(& &1.id)
      |> Enum.map(& &1.id)

    trips()
    |> Enum.filter(fn row -> row.shape_id not in shapes end)
    |> Enum.frequencies_by(& &1.shape_id)
  end
  # %{
  #   "" => 2251,
  #   "track-155230" => 25,
  #   "track-155234" => 56,
  #   "track-162787" => 136,
  #   "track-168210" => 84,
  #   "track-176513" => 161,
  #   "track-176515" => 81,
  #   "track-177487" => 236,
  #   "track-178867" => 189,
  #   "track-178869" => 190,
  #   "track-178889" => 247,
  #   "track-179717" => 201
  # }

  @doc "Есть ли в этой таблице service_id, которых нет в таблице calendar?"
  def are_there_trips_service_id_missed_in_calendar? do
    calendar_services =
      CalendarParser.calendar()
      |> Enum.map(& &1.service_id)

    trips()
    |> Enum.any?(& &1.service_id not in calendar_services)
  end
  # false
end
