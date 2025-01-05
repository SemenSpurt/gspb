defmodule Feed.Handlers do
  import Ecto.Query, warn: false
  import Geo.PostGIS

  alias Feed.Repo
  alias Feed.Ecto.{
    Stops.Stop,
    Routes.Route,
    StopTimes.StopTime
  }

  @doc "Handler 1 ~ 30ms) List stops within radius specified"
  def stops_within_radius(args) do
    types =
      if args.types == [] do
        Stop
        |> select([r], r.transport)
        |> distinct([r], r.transport)
        |> Repo.all()
      else
        # |> Enum.map(&Atom.to_string(&1))
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
  end

  @doc "Handler 2 ~ 60ms) List routes with total distance gt ^dist_gt"
  def routes_dist_gt(args) do
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
        where: r.transport in ^types,
        where: ilike(r.long_name, ^"%#{args.search}%"),
        where:
          fragment(
            """
              EXISTS (
                SELECT * FROM trips AS t
                JOIN tracks AS t1 ON t1.track_id = t.track_id
                JOIN calendar AS c ON c.service_id = t.service_id
                JOIN week AS w ON w.name = c.name
                WHERE t.route_id = ?
                AND st_length(t1.line) > ?
                AND c.end_date = ?

              )
            """,
            r.id,
            ^args.dist_gt / 1000,
            ^Date.from_iso8601!(args.day)
          )

    Repo.all(query)
  end

  @doc "Handler 3 ~ 220ms) List routes that visit the stop at day specified"
  def routes_over_stop(args) do
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
                AND c.end_date = ?
              )
            """,
            r.id,
            ^args.stop_id,
            # ,
            ^Date.from_iso8601!(args.day)
            # subquery(names)
          )

    Repo.all(query)
  end

  @doc "Handler 4 ~ 300ms) Routes to stop hourly mean arrival time"
  def hourly_mean_arrival(args) do
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
                AND c.end_date = ?
              )
            """,
            t.trip_id,
            ^Date.from_iso8601!(args.day)
          )

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
  end

  @doc "Handler 5 ~ 650ms) List routes between two subsequent stops"
  def routes_between_two_stops(args) do
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
                AND c.end_date = ?
                AND EXISTS (
                  SELECT * FROM stop_times AS st1
                  WHERE st1.stop_id = ?
                  AND st1.stop_sequence - st.stop_sequence = 1
                )
              )
            """,
            r.id,
            ^args.stop_id1,
            ^Date.from_iso8601!(args.day),
            ^args.stop_id2
          )

    Repo.all(query)
  end

  @doc "Handler 6 ~ 700 ms) List routes with percent of similarity"
  def route_substitutions(args) do
    query =
      from r in Route,
        distinct: r,
        where:
          fragment(
            """
              EXISTS (
                WITH
                  target AS (
                  SELECT DISTINCT ON (t1.route_id) t.line AS route
                  FROM tracks AS t
                  JOIN trips AS t1 ON t1.track_id = t.track_id
                  WHERE t1.route_id = ?
                  AND t1.direction_id
                )
                SELECT * FROM trips AS t
                JOIN tracks AS t1 ON t1.track_id = t.track_id
                WHERE t.route_id != ?
                AND t.route_id = ?
                AND st_length(
                  st_intersection(
                    t1.line, st_buffer((SELECT route FROM target), 5)
                  )
                ) > st_length((SELECT route FROM target)) * ? * 0.01
              )
            """,
            ^args.route_id,
            ^args.route_id,
            r.id,
            ^args.percent
          ),
        where:
          fragment(
            """
              EXISTS (
                SELECT * FROM trips AS t
                JOIN calendar AS c ON c.service_id = t.service_id
                WHERE t.route_id = ?
                AND c.end_date = ?
              )
            """,
            r.id,
            ^Date.from_iso8601!(args.day)
          )

    Repo.all(query)
  end
end
