defmodule Feed.Utils.Handlers do
  import Ecto.Query, warn: false
  import Geo.PostGIS

  alias Bandit
  alias Math

  alias Feed.{
    Repo
  }

  alias Feed.Ecto.{
    Trips.Trip,
    Stops.Stop,
    Routes.Route,
    Shapes.Track,
    StopTimes.StopTime,
    Calendar.Week,
    Calendar.Calendar
  }

  @handle1_attrs %{
    types: ["bus", "tram"],
    search: "",
    radius: 5750,
    coords: [30.336146, 59.934243]
  }

  @doc "Handler 1 ~ 30ms) List stops within radius specified"
  def stops_within_radius(args \\ @handle1_attrs) do
    now = Time.utc_now()

    types =
      if args.types == [] do
        Stop
        |> select([r], r.transport)
        |> distinct([r], r.transport)
        |> Repo.all()
      else
        args.types
      end

    point =
      %Geo.Point{
        coordinates: List.to_tuple(args.coords)
      }

    Stop
    |> where([s], s.transport in ^types)
    |> where([s], ilike(s.name, ^"%#{args.search}%"))
    |> where([s], st_distance_in_meters(s.coords, ^point) < ^args.radius)
    |> Repo.all()

    Time.diff(Time.utc_now(), now, :millisecond)
  end

  @handle2_attrs %{
    types: [],
    search: "ул",
    dist_gt: 150,
    day: :tuesday
  }

  @doc "Handler 2 ~ 60ms) List routes with total distance gt ^dist_gt"
  def routes_dist_gt(args \\ @handle2_attrs) do
    types =
      if args.types == [] do
        Route
        |> select([r], r.transport)
        |> distinct([r], r.transport)
        |> Repo.all()
      else
        args.types
      end

    query =
      from r in Route,
        distinct: r.id,
        join: t in Trip,
        on: r.id == t.route_id,
        join: t1 in Track,
        on: t1.track_id == t.track_id,
        where: r.transport in ^types,
        where: st_length(t1.line) > ^args.dist_gt / 1000,
        where: ilike(r.long_name, ^"%#{args.search}%")

    Repo.all(query)
  end

  @handle3_attrs %{
    stop_id: 18840,
    day: :wednesday
  }

  @doc "Handler 3 ~ 220ms) List routes that visit the stop at day specified"
  def routes_over_stop(attrs \\ @handle3_attrs) do
    now = Time.utc_now()

    names =
      from w in Week,
        select: w.name,
        where: field(w, ^attrs.day)

    query =
      from r in Route,
        where:
          fragment(
            """
              EXISTS (
                SELECT * FROM stop_times AS st
                JOIN trips AS t ON t.id = st.trip_id
                JOIN calendar AS c ON c.service_id = t.service_id
                WHERE t.route_id = ?
                AND st.stop_id = ?
                AND c.name in ?
              )
            """,
            r.id,
            ^attrs.stop_id,
            subquery(names)
          )

    Repo.all(query)
    Time.diff(Time.utc_now(), now, :millisecond)
  end

  @handle4_attrs %{
    stop_id: 18826,
    route_id: 1725,
    day: :tuesday
  }

  @doc "Handler 4 ~ 300ms) Routes to stop hourly mean arrival time"
  def routes_on_stop_hourly_mean_arrival(attrs \\ @handle4_attrs) do
    now = Time.utc_now()

    service_ids =
      from w in Week,
        join: c in Calendar,
        on: c.name == w.name,
        select: c.service_id,
        where: field(w, ^attrs.day)

    trips =
      from t in Trip,
        select: t.id,
        where: t.route_id == ^attrs.route_id,
        where: t.service_id in subquery(service_ids)

    names =
      from w in Week,
        select: w.name,
        where: field(w, ^attrs.day)

    stop_times =
      from t in StopTime,
        select: t.arrival_time,
        where:
          fragment(
            """
              EXISTS (
                SELECT * FROM trips AS t
                JOIN calendar AS c ON c.service_id = t.service_id
                WHERE t.id = ?
                AND t.route_id = ?
                AND c.name in ?
              )
            """,
            t.trip_id,
            ^attrs.route_id,
            subquery(names)
          )

    # where: t.stop_id == ^attrs.stop_id,
    # where: t.trip_id in subquery(trips)

    Repo.all(stop_times)
    |> Enum.group_by(& &1.hour)
    |> Enum.map(fn {k, v} ->
      {k,
       Enum.sort(v, :asc)
       |> Enum.chunk_every(2, 1, :discard)
       |> Enum.map(fn [x, y] -> Time.diff(y, x) / 60 end)}
    end)
    |> Enum.map(fn {k, v} ->
      %{
        hour: k,
        interval:
          unless v == [] do
            (Enum.sum(v) / Enum.count(v)) |> Float.round(1)
          end
      }
    end)

    Time.diff(Time.utc_now(), now, :millisecond)
  end

  @handle5_attrs %{
    stop_id1: 22127,
    stop_id2: 3104,
    day: :tuesday
  }

  @doc "Handler 5 ~ 650ms) List routes between two subsequent stops"
  def routes_between_two_stops(attrs \\ @handle5_attrs) do
    names =
      from w in Week,
        select: w.name,
        where: field(w, ^attrs.day)

    query =
      from r in Route,
        where:
          fragment(
            """
              EXISTS (
                SELECT * FROM stop_times AS st
                JOIN trips AS t ON t.id = st.trip_id
                JOIN calendar AS c ON c.service_id = t.service_id
                WHERE t.route_id = ?
                AND st.stop_id = ?
                AND c.name in ?
                AND EXISTS (
                  SELECT * FROM stop_times AS st1
                  WHERE st1.stop_id = ?
                  AND st1.stop_sequence - st.stop_sequence = 1
                )
              )
            """,
            r.id,
            ^attrs.stop_id1,
            subquery(names),
            ^attrs.stop_id2
          )

    Repo.all(query)
  end

  @handle6_attrs %{
    route_id: 237,
    percent: 25,
    day: :monday
  }

  @doc "Handler 6 ~ 700 ms) List routes with percent of similarity"
  def route_substitutions(attrs \\ @handle6_attrs) do
    now = Time.utc_now()
    names =
      from w in Week,
        select: w.name,
        where: field(w, ^attrs.day)


    query =
      from r in Route,
        where:
          fragment(
            """
              EXISTS (
                WITH target AS (
                  SELECT DISTINCT t.line, st_length(t.line) AS dist
                  FROM tracks AS t
                  JOIN trips AS t1 ON t1.track_id = t.track_id
                  WHERE t1.route_id = ?
                  AND t1.direction_id
                )
                SELECT *
                FROM trips AS t
                JOIN tracks AS t1 ON t1.track_id = t.track_id
                JOIN calendar AS c ON c.service_id = t.service_id
                WHERE t.route_id != ?
                AND t.route_id = ?
                AND c.name in ?
                AND st_length(
                  st_intersection(t1.line, (SELECT line FROM target))
                  ) > (SELECT dist FROM target) * ? * 0.01
              )
            """,
            ^attrs.route_id,
            ^attrs.route_id,
            r.id,
            subquery(names),
            ^attrs.percent
          )

    Repo.all(query)
    # Time.diff(Time.utc_now(), now, :millisecond)
  end
end
