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
    types: [],
    search: "",
    coords: [30.211210, 59.939270],
    radius: 250
  }
  ## V
  @doc "Handler 1 ~ 30ms) List stops within radius specified"
  def stops_within_radius(args \\ @args1) do
    # now = Time.utc_now()
    types =
      if args.types == [] do
        get_all_transport_types(Stop)
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

    # Time.diff(Time.utc_now(), now, :millisecond)
  end

  @args2 %{
    types: [],
    search: "",
    dist_gt: 30000,
    day: "2024-10-10"
  }

  ## V
  @doc "Handler 2 ~ 250ms) List routes with total distance gt ^dist_gt"
  def routes_dist_gt(args \\ @args2) do
    # now = Time.utc_now()

    types =
      if args.types == [] do
        get_all_transport_types(Route)
      else
        args.types
      end

    filter_trips =
      from t in Trip,
        distinct: t.route_id,
        join: t1 in Track,
        on: t1.track_id == t.track_id,
        where:
          fragment(
            """
              EXISTS (SELECT * FROM ? as t1 WHERE t1.service_id = ?)
            """,
            subquery(filter_services(args.day)),
            t.service_id
          ),
        where: st_length(t1.line) > ^args.dist_gt

    filter_routes =
      from r in Route,
        where: r.transport in ^types,
        where: ilike(r.long_name, ^"%#{args.search}%"),
        where:
          fragment(
            """
              EXISTS (SELECT * FROM ? as r WHERE r.route_id = ?)
            """,
            subquery(filter_trips),
            r.id
          )

    Repo.all(filter_routes)
    # Time.diff(Time.utc_now(), now, :millisecond)
  end

  @args3 %{
    stop_id: 17998,
    day: "2024-06-15"
  }

  ## V
  @doc "Handler 3 ~ 120ms) List routes that visit the stop at day specified"
  def routes_over_stop(args \\ @args3) do
    # now = Time.utc_now()

    filter_stop_times =
      from s in StopTime,
        where: s.stop_id == ^args.stop_id

    filter_trips =
      from t in Trip,
        select: t.route_id,
        distinct: t.route_id,
        where:
          fragment(
            """
              EXISTS (
                SELECT * FROM ? as c
                WHERE c.service_id = ?
              )
            """,
            subquery(filter_services(args.day)),
            t.service_id
          ),
        where:
          fragment(
            """
              EXISTS (
                SELECT * FROM ? as st
                WHERE st.trip_id = ?
              )
            """,
            subquery(filter_stop_times),
            t.id
          )

    filter_routes =
      from r in Route,
        where:
          fragment(
            """
              EXISTS (
                SELECT * FROM ? as t
                WHERE t.route_id = ?
              )
            """,
            subquery(filter_trips),
            r.id
          )

    Repo.all(filter_routes)

    # Time.diff(Time.utc_now(), now, :millisecond)
  end

  @args4 %{
    route_id: 3812,
    stop_id: 40382,
    day: "2024-11-10"
  }

  ## High frquencies??
  @doc "Handler 4 ~ 300ms) Routes to stop hourly mean arrival time"
  def hourly_mean_arrival(args \\ @args4) do
    # now = Time.utc_now()

    filter_trips =
      from t in Trip,
        select: t.id,
        where: t.route_id == ^args.route_id,
        where:
          fragment(
            """
              EXISTS (SELECT * FROM ? as s WHERE s.service_id = ?)
            """,
            subquery(filter_services(args.day)),
            t.service_id
          )

    stop_times =
      from s in StopTime,
        select: s.arrival_time,
        where:
          fragment(
            """
              EXISTS (
                SELECT * FROM ? AS t
                WHERE t.id = ?
              )
            """,
            subquery(filter_trips),
            s.trip_id
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

    # Time.diff(Time.utc_now(), now, :millisecond)
  end

  @args5 %{
    stop_id1: 31925,
    stop_id2: 27774,
    day: "2024-11-02"
  }

  ## V
  @doc "Handler 5 ~ 650ms) List routes between two subsequent stops"
  def routes_between_two_stops(args \\ @args5) do
    # now = Time.utc_now()

    filter_stop_times =
      from st in StopTime,
        where: st.stop_id == ^args.stop_id1,
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

    filter_trips =
      from t in Trip,
        distinct: t.route_id,
        where:
          fragment(
            """
              EXISTS (SELECT * FROM ? as t1 WHERE t1.service_id = ?)
            """,
            subquery(filter_services(args.day)),
            t.service_id
          ),
        where:
          fragment(
            """
              EXISTS (SELECT * FROM ? as st WHERE st.trip_id = ?)
            """,
            subquery(filter_stop_times),
            t.id
          )

    filter_routes =
      from r in Route,
        where:
          fragment(
            """
              EXISTS (SELECT * FROM ? AS t WHERE t.route_id = ?)
            """,
            subquery(filter_trips),
            r.id
          )

    Repo.all(filter_routes)

    # Time.diff(Time.utc_now(), now, :millisecond)
  end

  @args6 %{
    route_id: 9286,
    percent: 70,
    day: "2024-06-16"
  }

  ## V
  @doc "Handler 6 ~ 700 ms) List routes with percent of similarity"
  def route_substitutions(args \\ @args6) do
    now = Time.utc_now()

    target =
      Repo.one(
        from t in Track,
          select: %{line: st_buffer(t.line, 5), len: st_length(t.line)},
          distinct: t.track_id,
          join: t1 in Trip,
          on: t1.track_id == t.track_id,
          where: t1.route_id == ^args.route_id,
          where: t1.direction_id
      )

    dist = target.len * args.percent * 0.01

    filter_trips =
      from t in Trip,
        distinct: [t.route_id, t.direction_id],
        where:
          fragment(
            """
              EXISTS (SELECT * FROM ? as t1 WHERE t1.service_id = ?)
            """,
            subquery(filter_services(args.day)),
            t.service_id
          )

    filter_tracks =
      from t in Track,
        select: t.track_id,
        where:
          fragment(
            """
              EXISTS (
                SELECT * FROM ? AS t
                WHERE t.track_id = ?
              )
            """,
            subquery(filter_trips),
            t.track_id
          ),
        where: st_length(st_intersection(t.line, ^target.line)) > ^dist

    route_trip_ids =
      from t in Trip,
        select: t.route_id,
        distinct: t.route_id,
        where:
          fragment(
            """
              EXISTS (
                SELECT * FROM ? AS tr
                WHERE tr.track_id = ?
              )
            """,
            subquery(filter_tracks),
            t.track_id
          )

    filter_routes =
      from r in Route,
        where: r.id != ^args.route_id,
        where:
          fragment(
            """
              EXISTS (
                SELECT * FROM ? AS t WHERE t.route_id = ?
              )
            """,
            subquery(route_trip_ids),
            r.id
          )

    Repo.all(filter_routes)
    # Time.diff(Time.utc_now(), now, :millisecond)
  end

  @def_attrs1 %{
    route_id: 1266,
    day: "2024-11-09",
    start_time: "19:20:00",
    end_time: "21:30:00"
  }

  @doc "Inspect route schedule and actual trips appearance"
  def inspect_route(args \\ @def_attrs1) do
    # now = Time.utc_now()

    stime = Time.from_iso8601!(args.start_time)
    etime = Time.from_iso8601!(args.end_time)

    filter_trips =
      from t in Trip,
        where:
          fragment(
            """
              EXISTS (SELECT * FROM ? as t1 WHERE t1.service_id = ?)
            """,
            subquery(filter_services(args.day)),
            t.service_id
          )

    query =
      from s in StopTime,
        where:
          fragment(
            """
              EXISTS (
                SELECT * FROM ? AS t
                WHERE t.direction_id
                AND t.route_id = ?
                AND t.id = ?
              )
            """,
            subquery(filter_trips),
            ^args.route_id,
            s.trip_id
          )

    plan_trips =
      Repo.all(query)
      |> Enum.group_by(& &1.trip_id)
      |> Enum.map(fn {k, v} ->
        %{
          trip_id: k,
          first_stop_arrival:
            v
            |> Enum.sort_by(& &1.stop_sequence)
            |> Enum.at(0),
          last_stop_arrival:
            v
            |> Enum.sort_by(& &1.stop_sequence)
            |> Enum.at(-1)
        }
      end)
      |> Enum.sort_by(& &1.first_stop_arrival)
      |> Enum.filter(
        &(Time.compare(&1.first_stop_arrival.arrival_time, stime) == :gt and
            Time.compare(&1.first_stop_arrival.arrival_time, etime) == :lt)
      )
      |> Enum.map(
        &%{
          trip_id: &1.trip_id,
          start: &1.first_stop_arrival.arrival_time,
          finish: &1.last_stop_arrival.arrival_time
        }
      )
      |> Enum.sort_by(& &1.start)

    actual_starts =
      Repo.all(
        from p in Position,
          where:
            fragment(
              """
                EXISTS (
                  SELECT v.route_id, v.vehicle_id
                  FROM vehicles AS v
                  WHERE v.vehicle_id = ?
                  AND v.route_id = ?
                )
              """,
              p.vehicle_id,
              ^to_string(args.route_id)
            ),
          where:
            fragment(
              "extract(epoch from ? - ?) / 60",
              fragment("?::time", p.timestamp),
              ^stime
            ) > -10 and
              fragment(
                "extract(epoch from ? - ?) / 60",
                ^etime,
                fragment("?::time", p.timestamp)
              ) > -10
      )
      |> Enum.group_by(
        & &1.vehicle_id,
        &%{time: &1.timestamp, direction: &1.direction_id}
      )
      |> Enum.map(fn {k, v} ->
        %{
          trip_id: k,
          timestamps:
            v
            |> Enum.sort_by(& &1.time)
            |> Enum.chunk_every(2, 1, :discard)
            |> Enum.filter(fn [x, y] ->
              MapSet.new([x.direction, y.direction]) == MapSet.new([true, false])
            end)
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
      |> Enum.filter(&(Enum.count(&1.timestamps) == 2))
      |> Enum.map(
        &%{
          trip_id: &1.trip_id,
          start: &1.timestamps[:start],
          finish: &1.timestamps[:finish]
        }
      )
      |> Enum.sort_by(& &1.start)

    %{
      # route: args.route_id,
      plan_trips: plan_trips,
      actual_trips: actual_starts
    }

    # Time.diff(Time.utc_now(), now, :millisecond)
  end

  @def_attrs2 %{
    trip_id: 64_883_593
  }

  @doc "Inspect trip stop list and actual stop appearance (400ms)"
  def inspect_trip(args \\ @def_attrs2) do
    # now = Time.utc_now()

    route =
      Repo.one(
        from t in Trip,
          select: t.route_id,
          where: t.id == ^args.trip_id
      )

    trip_stops =
      Repo.all(
        from s in StopTime,
          where: s.trip_id == ^args.trip_id,
          order_by: s.arrival_time,
          preload: :stop
      )
      |> Enum.map(fn each ->
        %{
          order: each.stop_sequence,
          plan_time: each.arrival_time,
          point: each.stop.coords
        }
      end)

    trip_stops =
      Repo.all(
        from s in StopTime,
          distinct: [s.trip_id, s.stop_sequence],
          where: s.trip_id == ^args.trip_id,
          order_by: s.arrival_time,
          preload: :stop
      )
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

  defp get_all_transport_types(model) do
    model
    |> select([m], m.transport)
    |> distinct([m], m.transport)
    |> Repo.all()
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
      where: c.end_date > ^dt
  end
end
