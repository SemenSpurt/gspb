defmodule Feed.Utils.Handlers do
  import Ecto.Query, warn: false
  import Geo.PostGIS

  alias Bandit
  alias Math

  alias Feed.{
    Repo,
    Utils.Toolkit
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
    types: [:bus, :tram],
    search: "",
    radius: 5750,
    coords: [30.336146, 59.934243]
  }

  @doc "Handler 1"
  def stops_within_the_area(attrs \\ @handle1_attrs) do
    types =
      if attrs.types == [] do
        Route
        |> select([r], r.transport)
        |> distinct([r], r.transport)
        |> Repo.all()
      else
        attrs.types
        # |> Enum.map(&Atom.to_string(&1))
      end

    point =
      %Geo.Point{coordinates: List.to_tuple(attrs.coords)}

    Stop
    |> where([s], s.transport in ^types)
    |> where([s], ilike(s.name, ^"%#{attrs.search}%"))
    |> where([s], st_distance_in_meters(s.coords, ^point) < ^attrs.radius)
    |> Repo.all()
  end

  @handle2_attrs %{
    types: [],
    search: "ул",
    dist_gt: 150,
    day: :tuesday
  }

  @doc "Handler 2 ~ 50ms"
  def routes_with_dist_gt(attrs \\ @handle2_attrs) do
    now = Time.utc_now()

    types =
      if attrs.types == [] do
        Route
        |> select([r], r.transport)
        |> distinct([r], r.transport)
        |> Repo.all()
      else
        attrs.types |> Enum.map(&Atom.to_string(&1))
      end

    # service_ids =
    #   from w in Week,
    #     join: c in Calendar,
    #     on: c.name == w.name,
    #     select: c.service_id,
    #     where: field(w, ^attrs.day)

      service_ids =
        Calendar
        |> select([c], c.service_id)
        |> where([c],
          fragment("""
            EXIST (
              SELECT * FROM week AS w
              WHERE w.service_name = ?
              AND w.?
            )
          """, c.name, ^attrs.day)
        )

    track_ids =
      from t in Track,
        select: t.track_id,
        where: st_length(t.line) > ^attrs.dist_gt / 1000

    trip_ids =
      from t in Trip,
        # select: t.id,
        # distinct: t.route_id,
        where: t.track_id in subquery(track_ids),
        where: t.service_id in subquery(service_ids)

    query =
      from r in Route,
        where: r.transport in ^types,
        where:
          fragment(
            """
            EXISTS (
              SELECT * FROM trips AS t
              WHERE t.route_id == ?
              AND t.track_id in ?
              AND t.service_id in ?
            """,
            r.id,
            subquery(track_ids),
            subquery(service_ids)
          )

    # Style pipe
    # query =
    #   from r in Route,
    #     join: t in Trip,
    #     on: r.id == t.route_id,
    #     join: t1 in Track,
    #     on: t1.track_id == t.track_id,
    #     where: r.transport in ^types,
    #     where: st_length(t1.line) > (^attrs.dist_gt / 1000),
    #     where: ilike(r.long_name, ^"%#{attrs.search}%")

    Repo.all(service_ids)
    # Time.diff(Time.utc_now(), now, :millisecond)
  end

  @handle3_attrs %{
    stop_id: 18840,
    day: :wednesday
  }

  @doc "Handler 3 ~ 250ms"
  def routes_over_stop_by_weekday(attrs \\ @handle3_attrs) do
    now = Time.utc_now()

    trip_ids =
      from t in StopTime,
        select: t.trip_id,
        distinct: t.trip_id,
        where: t.stop_id == ^attrs.stop_id

    service_ids =
      from w in Week,
        join: c in Calendar,
        on: c.name == w.name,
        select: c.service_id,
        where: field(w, ^attrs.day)

    route_ids =
      from t in Trip,
        select: t.route_id,
        where: t.id in subquery(trip_ids),
        where: t.service_id in subquery(service_ids)

    query =
      from r in Route,
        where: r.id in subquery(route_ids)

    Repo.all(query)
    Time.diff(Time.utc_now(), now, :millisecond)
  end

  @handle4_attrs %{
    stop_id: 18826,
    route_id: 1725,
    day: :tuesday
  }

  @doc "Handler 4 ~ 300ms"
  def route_on_stop_hourly_mean_arrival(attrs \\ @handle4_attrs) do
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

    stop_times =
      from t in StopTime,
        select: t.arrival_time,
        where: t.stop_id == ^attrs.stop_id,
        where: t.trip_id in subquery(trips)

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

  @doc "Handler 5 ~ 750ms"
  def test2(attrs \\ @handle5_attrs) do
    now = Time.utc_now()

    service_ids =
      from w in Week,
        join: c in Calendar,
        on: c.name == w.name,
        select: c.service_id,
        where: field(w, ^attrs.day)

    trip_ids =
      from t in Trip,
        select: t.id,
        where: t.service_id in subquery(service_ids)

    trip_ids =
      from s in StopTime,
        select: s.trip_id,
        distinct: s.trip_id,
        where: s.trip_id in subquery(trip_ids),
        where: s.stop_id == ^attrs.stop_id1,
        where:
          fragment(
            """
              EXISTS (
              SELECT * FROM stop_times as s1
              WHERE s1.trip_id in ?
              AND s1.stop_id = ?
              AND s1.stop_sequence - ? = 1
            )
            """,
            subquery(trip_ids),
            ^attrs.stop_id2,
            s.stop_sequence
          )

    route_ids =
      from t in Trip,
        select: t.route_id,
        where: t.id in subquery(trip_ids),
        where: t.service_id in subquery(service_ids)

    query =
      from r in Route,
        where: r.id in subquery(route_ids)

    Repo.all(query)
    Time.diff(Time.utc_now(), now, :millisecond)
  end

  @handle6_attrs %{
    route_id: 1771,
    percent: 10,
    day: :tuesday
  }

  @doc "Handler 6"
  def route_substitute(attrs \\ @handle6_attrs) do
    services =
      from c in Calendar,
        where: field(c, ^attrs.day),
        select: c.id

    trips =
      from t in Trip,
        where: t.route_id == ^attrs.route_id,
        where: t.service_id in subquery(services),
        select: t.shape_id

    shapes =
      from s in Shape,
        where: s.shape_id in subquery(trips),
        select: [s.shape_id, s.pt_sequence, s.coords],
        order_by: [s.shape_id, s.pt_sequence]

    route =
      Repo.all(shapes)
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.map(fn x ->
        %{
          coords: Enum.map(x, &Enum.at(&1, 2)),
          dist:
            Enum.map(x, &Enum.at(&1, 2))
            |> Toolkit.dist_between_points()
        }
      end)

    route_dist =
      route
      |> Enum.map(& &1.dist)
      |> Enum.sum()

    subsitutions =
      Repo.all(Shape)
      |> Enum.sort_by(&[&1.shape_id, &1.pt_sequence])
      |> Enum.group_by(& &1.shape_id, & &1.coords)
      |> Enum.map(fn {k, v} ->
        [
          k,
          Enum.chunk_every(v, 2, 1, :discard)
          |> Enum.filter(fn x -> x in Enum.map(route, fn x -> x.coords end) end)
        ]
      end)
      |> Enum.filter(&(Enum.at(&1, 1) |> Enum.count() > 0))
      |> Enum.map(fn [k, v] ->
        [
          k,
          v
          |> Enum.map(&Toolkit.dist_between_points(&1))
          |> Enum.sum()
        ]
      end)
      |> Enum.filter(&(Enum.at(&1, 1) > route_dist * attrs.percent * 0.01))
      |> Enum.map(&Enum.at(&1, 0))

    sub =
      from t in Trip,
        distinct: t.route_id,
        where: t.shape_id in ^subsitutions,
        where: t.route_id != ^attrs.route_id,
        select: t.route_id

    query =
      from r in Route,
        where: r.id in subquery(sub)

    Repo.all(query)
  end

  def test() do
    one =
      from t in Track,
        where: t.track_id == "track-168185"

    one = Repo.one(one)

    two =
      from t in Track,
        # select: %{lenght: st_length(st_line(st_intersection(t.line, ^one.line))}
        select: st_intersection(t.line, ^one.line)

    Repo.all(two)
  end
end
