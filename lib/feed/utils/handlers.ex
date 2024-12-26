defmodule Feed.Utils.Handlers do
  import Ecto.Query, warn: false
  alias Feed.Repo

  alias Time, as: Clock
  alias Math

  alias Feed.Ecto.{
    Trips.Trip,
    Stops.Stop,
    Routes.Route,
    Shapes.Shape,
    StopTimes.Time,
    Calendar.Calendar
  }


  defp compute_coords_range(coords, radius) do
    earth_radius = 6_371_210
    uno_degree = Math.pi / 180

    half_earth = uno_degree * earth_radius

    coords
    |> Enum.map(
      fn x -> [
          x - radius / half_earth * Math.cos(x * uno_degree),
          x + radius / half_earth * Math.cos(x * uno_degree)
        ]
      end
    )
  end


  @doc"Handler 1"
  def stops_within_the_area(
    attrs \\ %{
      types: [:bus, :tram],
      search: "",
      radius: 5_500,
      coords: [30.336146, 59.934243]
    }
  ) do

    types = cond do
      attrs.types == [] ->
        ["bus", "tram", "trolley"]
      attrs.types != [] ->
        attrs.types
        |> Enum.map(&Atom.to_string(&1))
    end

    [
      [low_lon, high_lon],
      [low_lat, high_lat]
    ] =
      compute_coords_range(attrs.coords, attrs.radius)

    query =
      from s in Stop,
        where: s.transport in ^types,
        where: ilike(s.name, ^"%#{attrs.search}%"),
        where: fragment("?[0] BETWEEN ? AND ?", s.coords, ^low_lon, ^high_lon),
        where: fragment("?[1] BETWEEN ? AND ?", s.coords, ^low_lat, ^high_lat)
        # select: s.coords

    Repo.all(query)
  end


  @doc "Handler 2"
  def shapes_with_dist_gt(
    attrs \\ %{
      types: [:bus, :tram],
      search: "",
      dist_gt: 1_500,
      day: :tuesday
    }
  ) do

    types = cond do
      attrs.types == [] ->
        ["bus", "tram", "trolley"]
      attrs.types != [] ->
        attrs.types
        |> Enum.map(&Atom.to_string(&1))
    end

    shape =
      from s in Shape,
        distinct: [s.shape_id, max(s.dist_traveled)],
        group_by: s.shape_id,
        where: s.dist_traveled > ^(attrs.dist_gt / 1000),
        select: s.shape_id

    services =
      from c in Calendar,
        where: field(c, ^attrs.day) == true,
        select: c.id

    routes =
      from t in Trip,
        distinct: t.route_id,
        where: t.service_id in subquery(services),
        where: t.shape_id in subquery(shape),
        select: t.route_id

    query =
      from r in Route,
        where: ilike(r.long_name, ^"%#{attrs.search}%"),
        where: r.transport in ^types,
        where: r.id in subquery(routes)

    Repo.all(query)
  end




  @doc "Handler 3"
  def routes_over_stop_by_weekday(
    attrs \\ %{
      stop_id: 26560,
      day: :wednesday
    }
  ) do

    trips =
      from t in Time,
        distinct: t.trip_id,
        where: t.stop_id == ^attrs.stop_id,
        select: t.trip_id

    services =
      from c in Calendar,
        where: field(c, ^attrs.day) == true,
        select: c.id

    routes =
      from t in Trip,
        where: t.id in subquery(trips),
        where: t.service_id in subquery(services),
        select: t.route_id

    query =
      from r in Route,
        where: r.id in subquery(routes)

    Repo.all(query)
  end

  @doc "Handler 4"
  def hourly_mean_come_interval(
    attrs \\ %{
      stop_id: 33757,
      route_id: 3812,
      day: :tuesday
    }
  ) do

    services =
      from c in Calendar,
        where: field(c, ^attrs.day) == true,
        select: c.id

    trips =
      from t in Trip,
        where: t.route_id == ^attrs.route_id,
        where: t.service_id in subquery(services),
        select: t.id

    stop_times =
      from t in Time,
        where: t.stop_id == ^attrs.stop_id,
        where: t.trip_id in subquery(trips),
        select: t.arrival_time

    Repo.all(stop_times)
    |> Enum.group_by(& &1.hour)
    |> Enum.map(
      fn {k, v} ->
         {k, Enum.sort(v, :asc)
             |> Enum.chunk_every(2, 1, :discard)
             |> Enum.map(fn [x, y] -> Clock.diff(y, x) / 60 end)
         }
      end
    )
    |> Enum.map(
      fn {k, v} -> %{
        hour: k,
        interval: unless v == [] do
          Enum.sum(v) / Enum.count(v) |> Float.round(1)
        end
        }
      end
    )
  end

  @doc "Handler 5"
  def routes_between_two_stops(
    attrs \\ %{
      stop_id1: 35932,
      stop_id2: 1905,
      day: :tuesday
    }
  ) do

    services =
      from c in Calendar,
        where: field(c, ^attrs.day) == true,
        select: c.id

    trips =
      from t in Trip,
        where: t.service_id in subquery(services),
        select: t.id

    stop_times1 =
      from t in Time,
        where: t.trip_id in subquery(trips),
        where: t.stop_id == ^attrs.stop_id1,
        select: t.trip_id

    stop_times2 =
      from t in Time,
        where: t.trip_id in subquery(stop_times1),
        where: t.stop_id == ^attrs.stop_id2,
        join: t1 in Trip,
        on: t1.id == t.trip_id,
        select: [t1.route_id, t.arrival_time]

    Repo.all(stop_times2)
    |> Enum.map(fn [k, v] -> %{route: k, times: v} end)
    |> Enum.group_by(& &1.route, & &1.times)
    |> Enum.map(
      fn {k, v} -> %{
          route: k,
          times: Enum.sort(v, :asc) |> Enum.group_by(& &1.hour)
        }
      end
    )
  end


  def dist_between_points(coords) do
    earth_radius = 6_371_210
    uno_degree = Math.pi / 180

    # half_earth = earth_radius * uno_degree

    [
      [lat1, lon1],
      [lat2, lon2],
    ] =
      coords
      |> Enum.map(
        & Enum.map(&1, fn x -> x * uno_degree end)
      )

    dlat = lat2 - lat1
    dlon = lon2 - lon1

    a =
      Math.sin(dlat / 2)**2 +
      Math.cos(lat1) *
      Math.cos(lat2) *
      Math.sin(dlon / 2)**2

    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))

    earth_radius * c

  end


  @doc "Handler 6"
  def route_substitute(
    attrs \\ %{
      route_id: 1771,
      percent: 10,
      day: :tuesday
    }
  ) do

    services =
      from c in Calendar,
        where: field(c, ^attrs.day) == true,
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
      |> Enum.map(
        fn x -> %{
          coords:
            Enum.map(x, &Enum.at(&1, 2)),
          dist:
            Enum.map(x, &Enum.at(&1, 2))
            |> dist_between_points()
        } end
      )

    route_dist =
      route
      |> Enum.map(& &1.dist)
      |> Enum.sum()

    subsitutions =
      Repo.all(Shape)
      |> Enum.sort_by(& [&1.shape_id, &1.pt_sequence])
      |> Enum.group_by(& &1.shape_id, & &1.coords)
      |> Enum.map(
        fn {k, v} ->
           [k, Enum.chunk_every(v, 2, 1, :discard)
               |> Enum.filter(
                  fn x -> x in Enum.map(route, fn x -> x.coords end) end
                )
          ]
        end
      )
      |> Enum.filter(& Enum.at(&1, 1) |> Enum.count() > 0)
      |> Enum.map(
        fn [k, v] ->
           [k, v |> Enum.map(& dist_between_points(&1))
                 |> Enum.sum()
           ]
        end
      )
      |> Enum.filter(&Enum.at(&1, 1) > route_dist * attrs.percent * 0.01)
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
end
