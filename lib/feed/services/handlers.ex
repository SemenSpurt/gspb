defmodule Feed.Services.Handlers do
  import Ecto.Query, warn: false
  import Geo.PostGIS

  alias Feed.{
    Repo,
    Services.Toolkit
  }

  alias Feed.Ecto.{
    Trips.Trip,
    Stops.Stop,
    Calendar.Week,
    Calendar.Calendar,
    Shapes.Track,
    Routes.Route,
    StopTimes.StopTime
  }

  alias Feed.Ecto.Logs.{
    Vehicles.Vehicle,
    Positions.Position
  }

  # ПЛ. БЕЛЛИНСГАУЗЕНА
  @args1 %{
    types: ["bus"],
    search: "",
    coords: [30.211210, 59.939270],
    radius: 250
  }
  ## V
  @doc "Handler 1 ~ 30ms) List stops within radius specified"
  def stops_within_radius(args \\ @args1) do
    # now = Time.utc_now()

    types = process_transport_types(args.types, Stop)

    point =
      %Geo.Point{
        coordinates: List.to_tuple(args.coords)
      }

    query =
      from s in Stop,
        where: s.transport in ^types,
        where: ilike(s.name, ^"%#{args.search}%"),
        where: st_distance_in_meters(s.coords, ^point) < ^args.radius

    Repo.all(query)

    # Time.diff(Time.utc_now(), now, :millisecond)
  end

  @args2 %{
    types: [],
    search: "",
    dist_gt: 100_000,
    day: "2024-06-12"
  }

  ## V
  @doc "Handler 2 ~ 400ms) List routes with total distance gt ^dist_gt"
  def routes_dist_gt(args \\ @args2) do
    now = Time.utc_now()

    types = process_transport_types(args.types, Route)

    filter_routes =
      from r in Route,
        distinct: r.id,
        join: t in Trip,
        on: t.route_id == r.id,
        join: tr in Track,
        on: tr.track_id == t.track_id,
        where: r.transport in ^types,
        where: ilike(r.long_name, ^"%#{args.search}%"),
        where: st_length(tr.line) > ^args.dist_gt,
        where:
          fragment(
            """
              EXISTS (
                SELECT service_id FROM ?
                WHERE service_id = ?
              )
            """,
            subquery(filter_services(args.day)),
            t.service_id
          )

    # where:
    #   fragment(
    #     """
    #       EXISTS (
    #         SELECT
    #           t.route_id,
    #           t.track_id
    #         FROM ? AS t
    #         WHERE t.route_id = ?
    #         AND EXISTS (
    #           SELECT
    #             tr.track_id,
    #             tr.line
    #           FROM tracks AS tr
    #           WHERE tr.track_id = t.track_id
    #           AND st_length(tr.line) > ?

    #         )
    #       )
    #     """,
    #     subquery(filter_trips(args.day)),
    #     r.id,
    #     ^args.dist_gt
    #   )

    Repo.all(filter_routes)
    |> Enum.sort_by(& &1.short_name)

    Time.diff(Time.utc_now(), now, :millisecond)
  end

  @args3 %{
    stop_id: 18103,
    day: "2024-06-15"
  }

  ## V
  @doc "Handler 3 ~ 120ms) List routes that visit the stop at day specified"
  def routes_over_stop(args \\ @args3) do
    # now = Time.utc_now()

    filter_routes =
      from r in Route,
        distinct: r.id,
        join: t in Trip,
        on: t.route_id == r.id,
        join: st in StopTime,
        on: st.trip_id == t.id,
        where: st.stop_id == ^args.stop_id,
        where:
          fragment(
            """
              EXISTS (
                SELECT service_id FROM ?
                WHERE service_id = ?
              )
            """,
            subquery(filter_services(args.day)),
            t.service_id
          )

    Repo.all(filter_routes)

    # Time.diff(Time.utc_now(), now, :millisecond)
  end

  @args4 %{
    route_id: 7466,
    stop_id: 27204,
    day: "2024-11-10"
  }

  ## TODO: add absent hours
  @doc "Handler 4 ~ 300ms) Routes on stop hourly average arrival"
  def route_average_interval(args \\ @args4) do
    # now = Time.utc_now()

    stop_times =
      from st in StopTime,
        select: st.arrival_time,
        join: t in Trip,
        on: t.id == st.trip_id,
        where: st.stop_id == ^args.stop_id,
        where: t.route_id == ^args.route_id,
        where:
          fragment(
            """
              EXISTS (
                SELECT service_id FROM ?
                WHERE service_id = ?
              )
            """,
            subquery(filter_services(args.day)),
            t.service_id
          ),
        order_by: st.arrival_time

    Repo.all(stop_times)
    |> Enum.group_by(& &1.hour)
    |> Enum.map(fn {k, v} ->
      {k,
       v
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

    # Time.diff(Time.utc_now(), now, :millisecond)
  end

  @args5 %{
    stop_id1: 31925,
    stop_id2: 27774,
    day: "2024-06-08"
  }

  ## V
  @doc "Handler 5 ~ 650ms) List routes between two subsequent stops"
  def routes_between_two_stops(args \\ @args5) do
    now = Time.utc_now()

    filter_routes =
      from r in Route,
        distinct: r.id,
        join: t in Trip,
        on: t.route_id == r.id,
        join: st in StopTime,
        on: st.trip_id == t.id,
        where: st.stop_id == ^args.stop_id1,
        where:
          fragment(
            """
              EXISTS (
                SELECT service_id FROM ?
                WHERE service_id = ?
              )
            """,
            subquery(filter_services(args.day)),
            t.service_id
          ),
        where:
          fragment(
            """
              EXISTS (
                SELECT * FROM stop_times AS st1
                WHERE st1.stop_sequence - ? = 1
                AND st1.trip_id = ?
                AND st1.stop_id = ?
              )
            """,
            st.stop_sequence,
            st.trip_id,
            ^args.stop_id2
          )

    Repo.all(filter_routes)
    |> Enum.sort_by(fn x -> String.to_integer(x.short_name) end)

    Time.diff(Time.utc_now(), now, :millisecond)
  end

  @args6 %{
    route_id: 9286,
    percent: 25,
    day: "2024-06-16"
  }

  ## V
  @doc "Handler 6 ~ 700 ms) List routes with percent of similarity"
  def route_substitutions1(args \\ @args6) do
    now = Time.utc_now()

    query =
      from r in Route,
        distinct: r.id,
        join: t in Trip,
        on: t.route_id == r.id,
        where:
          fragment(
            """
              EXISTS (
                SELECT service_id FROM ?
                WHERE service_id = ?
              )
            """,
            subquery(filter_services(args.day)),
            t.service_id
          ),
        where:
          fragment(
            """
              EXISTS (
                WITH target AS (
                  SELECT DISTINCT ON (t1.route_id)
                    st_buffer(t.line, 5) AS line,
                    st_length(t.line) * ? * 0.01 AS dist
                  FROM tracks AS t
                  JOIN trips AS t1
                  ON t1.track_id = t.track_id
                  WHERE t1.route_id = ?
                  AND t1.direction_id
                )
                SELECT *
                FROM trips AS t
                JOIN tracks AS t1
                ON t1.track_id = t.track_id
                WHERE t.route_id != ?
                AND t.route_id = ?
                AND st_length(
                  st_intersection(t1.line,(SELECT line FROM target))
                  ) > (SELECT dist FROM target)
              )
            """,
            ^args.percent,
            ^args.route_id,
            ^args.route_id,
            r.id
          )

    Repo.all(query)

    Time.diff(Time.utc_now(), now, :millisecond)
  end

  def route_substitutions(args \\ @args6) do
    now = Time.utc_now()

    target_route =
      Repo.one(
        from t in Track,
          select: %{
            line: st_buffer(t.line, 5),
            len: st_length(t.line)
          },
          distinct: t.track_id,
          join: t1 in Trip,
          on: t1.track_id == t.track_id,
          where: t1.route_id == ^args.route_id,
          where: t1.direction_id
      )

    dist = target_route.len * args.percent * 0.01

    filter_routes =
      from r in Route,
        distinct: r.id,
        join: t in Trip,
        on: t.route_id == r.id,
        join: tr in Track,
        on: tr.track_id == t.track_id,
        where: r.id != ^args.route_id,
        where: st_length(st_intersection(tr.line, ^target_route.line)) > ^dist,
        where:
          fragment(
            """
              EXISTS (
                SELECT service_id FROM ?
                WHERE service_id = ?
              )
            """,
            subquery(filter_services(args.day)),
            t.service_id
          )

    Repo.all(filter_routes)
    Time.diff(Time.utc_now(), now, :millisecond)
  end

  @def_attrs1 %{
    route: 1266,
    stime: "08:00:00",
    etime: "09:00:00",
    day: "2024-12-29"
  }

  @doc "Inspect route schedule and actual trips appearance"
  def inspect_route(args \\ @def_attrs1) do
    # now = Time.utc_now()

    stime = Time.from_iso8601!(args.stime)
    etime = Time.from_iso8601!(args.etime)

    trips_stops =
      from st in StopTime,
        # distinct: st.trip_id,
        join: t in Trip,
        on: t.id == st.trip_id,
        where: t.route_id == ^args.route,
        where:
          fragment(
            """
              EXISTS (
                SELECT service_id FROM ?
                WHERE service_id = ?
              )
            """,
            subquery(filter_services(args.day)),
            t.service_id
          ),
        ## WHERE date BETWEEN dt1, dt2 ?
        where:
          fragment(
            "? > ? ",
            fragment("?::time", st.arrival_time),
            ^stime
          ),
        where:
          fragment(
            "? < ?",
            fragment("?::time", st.arrival_time),
            ^etime
          )

    plan_trips =
      Repo.all(trips_stops)
      |> Enum.group_by(& &1.trip_id)
      |> Enum.map(fn {k, v} ->
        %{
          trip_id: k,
          start:
            v
            |> Enum.sort_by(& &1.stop_sequence)
            |> Enum.at(0),
          finish:
            v
            |> Enum.sort_by(& &1.stop_sequence)
            |> Enum.at(-1)
        }
      end)
      |> Enum.sort_by(& &1.start)
      |> Enum.filter(
        &(Time.compare(&1.start.arrival_time, stime) == :gt and
            Time.compare(&1.finish.arrival_time, etime) == :lt)
      )
      |> Enum.map(
        &%{
          trip_id: &1.trip_id,
          start: &1.start.arrival_time,
          finish: &1.finish.arrival_time
        }
      )
      |> Enum.sort_by(& &1.start)

    ###
    actual_starts =
      Repo.all(
        from p in Position,
          join: v in Vehicle,
          on: v.vehicle_id == p.vehicle_id,
          where: v.route_id == ^to_string(args.route),
          where:
            fragment(
              "? - ? > -5 * interval '1 minute'",
              fragment("?::time", p.timestamp),
              ^stime
            ),
          where:
            fragment(
              "? - ? < 5 * interval '1 minute'",
              fragment("?::time", p.timestamp),
              ^etime
            )
      )
      |> Enum.group_by(
        & &1.vehicle_id,
        &%{
          time: &1.timestamp,
          direction: &1.direction_id
        }
      )
      |> Enum.map(fn {k, v} ->
        %{
          trip_id: k,
          timestamps:
            v
            |> Enum.sort_by(& &1.time)
            |> Enum.chunk_every(2, 1, :discard)
            |> Enum.filter(fn [x, y] -> x.direction != y.direction end)
            |> Enum.map(fn times ->
              case times |> Enum.map(& &1.direction) do
                [true, false] ->
                  %{
                    finish:
                      times
                      |> Enum.map(& &1.time)
                      |> Enum.at(0)
                      |> NaiveDateTime.to_time()
                  }

                [false, true] ->
                  %{
                    start:
                      times
                      |> Enum.map(& &1.time)
                      |> Enum.at(0)
                      |> NaiveDateTime.to_time()
                  }
              end
              |> Enum.reduce(&Map.merge/2)
            end)
        }
      end)
      |> Enum.filter(&(&1.timestamps != []))
      |> Enum.map(fn each ->
        %{
          trip: each.trip_id,
          timestamps:
            case each.timestamps |> Enum.at(0) |> elem(0) do
              :finish -> [start: nil] ++ each.timestamps
              :start -> each.timestamps
            end
        }
      end)
      |> Enum.map(fn each ->
        %{
          trip: each.trip,
          timestamps:
            case each.timestamps |> Enum.at(-1) |> elem(0) do
              :start -> each.timestamps ++ [finish: nil]
              :finish -> each.timestamps
            end
        }
      end)
      |> Enum.map(fn each ->
        each.timestamps
        |> Enum.chunk_every(2, 2)
        |> Enum.map(
          &%{
            trip: each.trip,
            start: &1[:start],
            finish: &1[:finish]
          }
        )
      end)
      |> List.flatten()
      |> Enum.sort_by(&[&1.start, &1.finish])

    %{
      plan_trips: plan_trips,
      actual_trips: actual_starts
    }

    # Time.diff(Time.utc_now(), now, :millisecond)
  end

  @def_attrs2 %{
    trip: 64_883_343
  }

  @doc "Inspect stop list and actual stop appearance for trip specified (400ms)"
  def inspect_trip(args \\ @def_attrs2) do
    # now = Time.utc_now()

    route =
      Repo.one(
        from t in Trip,
          select: t.route_id,
          where: t.id == ^args.trip
      )

    stop_list =
      from s in StopTime,
        distinct: [s.trip_id, s.stop_sequence],
        where: s.trip_id == ^args.trip,
        order_by: s.arrival_time,
        preload: :stop

    trip_stops =
      Repo.all(stop_list)
      |> Enum.map(fn each ->
        %{
          order: each.stop_sequence,
          plan_time: each.arrival_time,
          point: each.stop.coords
        }
      end)

    trip_start =
      trip_stops
      |> Enum.fetch!(0)

    find_trip_vehicles =
      from p in Position,
        select: %{
          id: p.vehicle_id,
          order: p.order_number,
          delay:
            fragment(
              "min(abs(extract(epoch from ? - ?) / 60))",
              fragment("?::time", p.timestamp),
              ^trip_start.plan_time
            )
        },
        join: v in Vehicle,
        on: v.vehicle_id == p.vehicle_id,
        where: v.route_id == ^to_string(route),
        where: st_distance_in_meters(p.position, ^trip_start.point) < 50,
        group_by: [p.vehicle_id, p.order_number]

    vehicle =
      Repo.all(find_trip_vehicles)
      |> Enum.sort_by(& &1.delay)
      |> Enum.at(0)

    trip_stops
    |> Enum.map(fn stop ->
      %{
        order: stop.order,
        plan_time: stop.plan_time,
        actual_time:
          Repo.one(
            from p in Position,
              select: fragment("?::time", p.timestamp),
              # where: fragment("?::date", p.timestamp) == ^Date.from_iso8601!("2025-01-19"),
              where: p.vehicle_id == ^vehicle.id,
              where: p.order_number == ^vehicle.order,
              order_by: [
                fragment(
                  "min(abs(extract(epoch from ? - ?) / 60))",
                  fragment("?::time", p.timestamp),
                  ^stop.plan_time
                ),
                st_distance_in_meters(p.position, ^stop.point)
              ],
              group_by: [p.timestamp, p.position],
              limit: 1
          )
      }
    end)

    # Time.diff(Time.utc_now(), now, :millisecond)
  end

  defp process_transport_types(types, model) do
    model_types =
      Repo.all(
        from m in model,
          select: m.transport,
          distinct: m.transport
      )
      |> MapSet.new()

    case types do
      [] ->
        model_types

      _ ->
        model_types
        |> MapSet.intersection(MapSet.new(types))
    end
    |> MapSet.to_list()
  end

  defp filter_services(date) do
    dt = Date.from_iso8601!(date)
    weekday = Toolkit.weekday_atom_from_date(date)

    from c in Calendar,
      select: c.service_id,
      join: w in Week,
      on: c.name == w.name,
      where: field(w, ^weekday),
      where: c.start_date < ^dt,
      where: c.end_date >= ^dt
  end
end
