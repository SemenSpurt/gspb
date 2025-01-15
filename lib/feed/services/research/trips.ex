defmodule Feed.Services.Research.Trips do
  # """
  #   route_id:       integer
  #   service_id:     integer
  #   trip_id:        integer
  #   direction_id:   boolean
  #   shape_id:       string : может быть это поле доджно быть в routes?
  # """

  alias Feed.Services.Toolkit

  alias Feed.Services.Research.{
    Routes,
    Shapes,
    Calendar,
    StopTimes,
    Frequencies
  }

  @file_path "src/feed"

  def records(file_path \\ @file_path) do
    Path.expand("trips.txt", file_path)
    |> File.stream!()
    |> FileParser.parse_stream()
    |> Enum.map(fn [
                     route_id,
                     service_id,
                     id,
                     direction_id,
                     track_id
                   ] ->
      %{
        route_id: String.to_integer(route_id),
        service_id: String.to_integer(service_id),
        id: String.to_integer(id),
        direction_id: String.to_integer(direction_id) == 1,
        track_id: String.trim(track_id)
      }
    end)
  end

  @doc "0) Как много записей в таблице trips?"
  def count_table_records, do: records() |> Enum.count()
  # 124157

  @doc "1) Сколько всего уникальных route_id?"
  def count_uniq_route_id, do: records() |> Toolkit.count_uniq_in(:route_id)
  # 549

  @doc "2) Сколько всего уникальных service_id?"
  def count_uniq_service_id, do: records() |> Toolkit.count_uniq_in(:service_id)
  # 977

  @doc "3) Какие значения принемает столбец direction_id?"
  def direction_id_frequencies, do: records() |> Enum.frequencies_by(& &1.direction_id)
  # %{"0" => 62221, "1" => 61936}

  @doc "4) Сколько всего уникальных trip_id?"
  def count_uniq_trip_id, do: records() |> Toolkit.count_uniq_in(:trip_id)
  # 124157

  @doc "5) Сколько всего уникальных shape_id?"
  def count_uniq_shape_id, do: records() |> Toolkit.count_uniq_in(:shape_id)
  # 1077

  @doc "5.1) 'track-' есть во всех записях shape_id?"
  def shape_id_prefix_frequencies do
    records()
    |> Enum.frequencies_by(
      &(&1.shape_id
        |> String.split("-")
        |> Enum.at(0))
    )
  end

  # %{"" => 2251, "track" => 121906}

  ### Multitable questions ###
  @doc "Есть ли в этой таблице route_id, которых нет в таблице routes?"
  def are_there_trips_route_ids_missed_in_routes? do
    routes =
      Routes.records()
      |> MapSet.new(& &1.id)

    records()
    |> MapSet.new(& &1.route_id)
    |> MapSet.difference(routes)
  end

  # MapSet.new([])

  @doc "Сколько trip_id из trips можно найти в таблице stop_times?"
  def trips_id_that_has_stop_times do
    all_trips =
      records()
      |> MapSet.new(& &1.trip_id)

    StopTimes.records()
    |> MapSet.new(& &1.trip_id)
    |> MapSet.intersection(all_trips)
    |> Enum.count()
  end

  # 120300

  @doc "Сколько trip_id из trips можно найти в таблице frequencies?"
  def trips_id_that_has_frequencies do
    all_trips =
      records()
      |> MapSet.new(& &1.trip_id)

    Frequencies.records()
    |> MapSet.new(& &1.trip_id)
    |> MapSet.intersection(all_trips)
    |> Enum.count()
  end

  # 106506

  @doc "Пересечение таблиц stop_times и frequencies по trip_id?"
  def stop_times_to_frequencies do
    freqs =
      Frequencies.records()
      |> MapSet.new(& &1.trip_id)

    StopTimes.records()
    |> MapSet.new(& &1.trip_id)
    |> MapSet.intersection(freqs)
    |> Enum.count()
  end

  # 103303

  @doc "trip_id которых нет в frequencies и stop_times"
  def extra_trips do
    freqs =
      Frequencies.records()
      |> MapSet.new(& &1.trip_id)

    stop_times =
      StopTimes.records()
      |> MapSet.new(& &1.trip_id)

    records()
    |> MapSet.new(& &1.trip_id)
    |> MapSet.difference(freqs)
    |> MapSet.difference(stop_times)
    |> Enum.count()
  end

  # 654

  @doc "Получить рейсы shape_id которых отсутствует в таблице shapes"
  def trips_not_in_shapes do
    shapes =
      Shapes.records()
      |> MapSet.new(& &1.id)

    records()
    |> Enum.filter(&(&1.shape_id not in shapes))
  end

  def are_there_trips_without_shapes_in_frequencies? do
    # now = DateTime.utc_now()
    extra_shapes =
      trips_not_in_shapes()
      |> MapSet.new(& &1.trip_id)

    freqs =
      Frequencies.records()
      |> MapSet.new(& &1.trip_id)

    MapSet.intersection(extra_shapes, freqs)
    |> Enum.count()

    # DateTime.diff(DateTime.utc_now(), now, :seconds)
  end

  # 3203

  @doc "Есть ли в этой таблице service_id, которых нет в таблице calendar?"
  def are_there_trips_service_id_missed_in_calendar? do
    calendar_services =
      Calendar.records()
      |> MapSet.new(& &1.service_id)

    records()
    |> MapSet.new(& &1.service_id)
    |> MapSet.difference(calendar_services)
  end

  # MapSet.new([])
end
