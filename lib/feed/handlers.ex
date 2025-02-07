defmodule Feed.Handlers do
  import Ecto.Query, warn: false
  import Geo.PostGIS

  alias Feed.{
    Repo,
    Services.Toolkit
  }

  alias Feed.Ecto.{
    Trip,
    Stop,
    Track,
    Route,
    Calendar,
    StopTime
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
    day: "2024-06-14"
  }

  ## V
  @doc "Handler 2 ~ 400ms) List routes with total distance gt ^dist_gt"
  def routes_dist_gt(args \\ @args2) do
    # now = Time.utc_now()

    Repo.all(
      from r in Route,
        distinct: r.route_id,
        join: t in Trip,
        on: t.route_id == r.route_id,
        join: tr in Track,
        on: tr.track_id == t.track_id,
        join: c in Calendar,
        on: c.service_id == t.service_id,
        where: field(c, ^Toolkit.str_to_weekday(args.day)),
        where: r.transport in ^process_transport_types(args.types, Route),
        where: ilike(r.long_name, ^"%#{args.search}%"),
        where: st_length(tr.line) > ^args.dist_gt
    )
    |> Enum.sort_by(& &1.short_name)

    # Time.diff(Time.utc_now(), now, :millisecond)
  end

  @args3 %{
    stop_id: 18103,
    day: "2024-12-17"
  }

  ## V
  @doc "Handler 3 ~ 120ms) List routes that visit the stop at day specified"
  def routes_over_stop(args \\ @args3) do
    # now = Time.utc_now()

    Repo.all(
      from r in Route,
        distinct: r.route_id,
        join: t in Trip,
        on: t.route_id == r.route_id,
        join: c in Calendar,
        on: c.service_id == t.service_id,
        join: st in StopTime,
        on: st.trip_id == t.trip_id,
        where: field(c, ^Toolkit.str_to_weekday(args.day)),
        where: st.stop_id == ^args.stop_id
    )

    # Time.diff(Time.utc_now(), now, :millisecond)
  end

  @args4 %{
    route_id: 1504,
    stop_id: 17915,
    day: "2025-01-20"
  }

  ## TODO: add absent hours
  @doc "Handler 4 ~ 300ms) Routes on stop hourly average arrival"
  def route_average_interval(args \\ @args4) do
    # now = Time.utc_now()

    Repo.all(
      from st in StopTime,
        select: st.arrival_time,
        join: t in Trip,
        on: t.trip_id == st.trip_id,
        join: c in Calendar,
        on: c.service_id == t.service_id,
        where: field(c, ^Toolkit.str_to_weekday(args.day)),
        where: st.stop_id == ^args.stop_id,
        where: t.route_id == ^args.route_id,
        order_by: st.arrival_time
    )
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
    day: "2024-11-09"
  }

  ## V
  @doc "Handler 5 ~ 650ms) List routes between two subsequent stops"
  def routes_between_two_stops(args \\ @args5) do
    # now = Time.utc_now()

    Repo.all(
      from r in Route,
        distinct: r.route_id,
        join: t in Trip,
        on: t.route_id == r.route_id,
        join: st in StopTime,
        on: st.trip_id == t.trip_id,
        join: c in Calendar,
        on: c.service_id == t.service_id,
        where: field(c, ^Toolkit.str_to_weekday(args.day)),
        where: st.stop_id == ^args.stop_id1,
        where:
          fragment(
            """
              EXISTS (
                SELECT * FROM ? AS st1
                WHERE st1.trip_id = ?
                AND st1.stop_sequence - ? = 1
              )
            """,
            subquery(
              from st in StopTime,
                select: [st.trip_id, st.stop_sequence, st.stop_id],
                where: st.stop_id == ^args.stop_id2
            ),
            st.trip_id,
            st.stop_sequence
          )
    )
    |> Enum.sort_by(fn x -> String.to_integer(x.short_name) end)

    # Time.diff(Time.utc_now(), now, :millisecond)
  end

  @args6 %{
    route_id: 9286,
    percent: 50,
    day: "2024-06-19"
  }

  def route_substitutions(args \\ @args6) do
    # now = Time.utc_now()

    filter_routes =
      from r in Route,
        distinct: r.route_id,
        join: t in Trip,
        on: t.route_id == r.route_id,
        join: tr in Track,
        on: tr.track_id == t.track_id,
        join: c in Calendar,
        on: c.service_id == t.service_id,
        where: r.route_id != ^args.route_id,
        where: field(c, ^Toolkit.str_to_weekday(args.day)),
        where:
          fragment(
            """
              EXISTS (
                SELECT * FROM ? AS target_route
                WHERE st_length(
                        st_intersection(?, target_route.line)
                      ) > target_route.len
              )
            """,
            subquery(
              from t in Track,
                select:
                  fragment(
                    """
                      ? as line, ? as len
                    """,
                    st_buffer(t.line, 10),
                    st_length(t.line) * ^args.percent * 0.01
                  ),
                distinct: t.track_id,
                join: t1 in Trip,
                on: t1.track_id == t.track_id,
                where: t1.route_id == ^args.route_id,
                where: t1.direction_id
            ),
            tr.line
          )

    # where: st_length(st_intersection(tr.line, ^target_route.line)) > ^dist

    Repo.all(filter_routes)
    # Time.diff(Time.utc_now(), now, :millisecond)
  end

  def trip(args \\ %{}) do
    conditions =
      if args.stime == nil do
        dynamic([p], true)
      else
        dynamic([p], p.timestamp > ^args.stime)
      end

    direction = true in route_directions(args.route)
    route_line = route_line(args.route, direction)

    lagging =
      from p in "route_#{args.route}",
        select: %{
          id: p.vehicle_id,
          time: p.timestamp,
          position: p.position,
          projection:
            fragment(
              """
                ST_LineLocatePoint(?, ?)
              """,
              ^route_line,
              p.position
            ),
          lag_position:
            fragment(
              """
                ? = ? AND ? != ?
              """,
              p.position,
              lag(p.position, 1, p.position) |> over(:w),
              p.timestamp,
              lag(p.timestamp, 1, p.timestamp) |> over(:w)
            )
        },
        where: ^conditions,
        where:
          fragment(
            """
              st_distance(
                ST_LineInterpolatePoint(?::geography, 0),
                ?::geography
              ) < 500
               OR
              st_distance(
                ST_LineInterpolatePoint(?::geography, 1),
                ?::geography
              ) < 500
            """,
            ^route_line,
            p.position,
            ^route_line,
            p.position
          ),
        windows: [
          w: [
            partition_by: p.vehicle_id,
            order_by: p.timestamp
          ]
        ]

    uniq_positions =
      from t in subquery(lagging),
        select: %{
          id: t.id,
          time: t.time,
          position: t.position,
          projection: t.projection,
          start:
            fragment(
              """
                ? < ? AND ? < 0.05
              """,
              t.projection,
              lead(t.projection, 3, t.projection) |> over(:w),
              t.projection
            ),
          finish:
            fragment(
              """
                ? > ? AND ? > 0.95
              """,
              t.projection,
              lag(t.projection, 3, t.projection) |> over(:w),
              t.projection
            )
        },
        windows: [
          w: [
            partition_by: t.id,
            order_by: t.time
          ]
        ],
        where: not t.lag_position,
        # where: t.projection < 1 and t.projection > 0,
        where: t.projection > 0.95 or t.projection < 0.05

    # Repo.all(uniq_positions)

    edges =
      from t in subquery(uniq_positions),
        select: %{
          id: t.id,
          time: t.time,
          start: t.start,
          finish: t.finish,
          position: t.position,
          projection: t.projection,
          direction:
            fragment(
              """
              CASE
                WHEN ? AND ? >= ? THEN TRUE
                WHEN ? AND ? <= ? THEN FALSE
                WHEN ? AND ? >= ? THEN TRUE
                WHEN ? AND ? <= ? THEN FALSE
              END
              """,
              t.start,
              t.projection,
              lag(t.projection, 1, t.projection) |> over(:w),
              t.start,
              t.projection,
              lag(t.projection, 1, t.projection) |> over(:w),
              t.finish,
              t.projection,
              lag(t.projection, 1, t.projection) |> over(:w),
              t.finish,
              t.projection,
              lag(t.projection, 1, t.projection) |> over(:w)
            ),
          redundant:
            fragment(
              """
                EXTRACT(epoch FROM ?::time - ?::time) / 60 < 3
                AND ? != ?
              """,
              lead(t.time, 1, t.time) |> over(:w),
              t.time,
              lead(t.time, 1, t.time) |> over(:w),
              t.time
            )
        },
        where: t.start or t.finish,
        windows: [
          w: [
            partition_by: t.id,
            order_by: t.time
          ]
        ]

    Repo.all(
      from t in subquery(edges),
        where: not t.redundant
    )
    |> Enum.group_by(& &1.id)
    |> Enum.map(fn {k, v} ->
      v
      |> Enum.sort_by(& &1.time)
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.filter(fn [x, y] ->
        x.start != y.start and
          x.finish != y.finish
      end)
      |> Enum.map(
        &Enum.map(&1, fn x ->
          if x.start do
            %{stime: x.time, sstop: x.position}
          else
            %{etime: x.time, estop: x.position}
          end
        end)
      )
      |> Enum.map(fn [x, y] -> Map.merge(x, y) end)
      |> Enum.map(fn x ->
        if x.stime < x.etime do
          %{
            trip_id: k,
            route_id: args.route,
            direction: true,
            stime: x.stime,
            etime: x.etime,
            sstop: x.sstop,
            estop: x.estop
          }
        else
          %{
            trip_id: k,
            route_id: args.route,
            direction: false,
            stime: x.etime,
            etime: x.stime,
            sstop: x.estop,
            estop: x.sstop
          }
        end
      end)
    end)
    |> List.flatten()
    |> Enum.filter(&(&1.direction or direction))
  end

  # route: 4095,
  @def_attrs1 %{
    route: 1829,
    stime: "10:00:00",
    etime: "12:00:00"
  }

  @doc "Inspect route schedule and actual trips appearance"
  def inspect_route(args \\ @def_attrs1) do
    # now = Time.utc_now()

    stime = Time.from_iso8601!(args.stime)
    etime = Time.from_iso8601!(args.etime)

    %{
      plan_trips:
        Repo.all(
          from st in StopTime,
            join: t in Trip,
            on: t.trip_id == st.trip_id,
            join: c in Calendar,
            on: t.service_id == c.service_id,
            where: t.route_id == ^args.route,
            where:
              fragment(
                """
                  EXISTS (
                    SELECT * FROM ? AS st
                    WHERE st.trip_id = ?
                  )
                """,
                subquery(
                  from st in StopTime,
                    select: st.trip_id,
                    where: st.arrival_time > ^stime,
                    where: st.arrival_time < ^etime,
                    where: st.stop_sequence == 0,
                    group_by: st.trip_id
                ),
                st.trip_id
              ),
            preload: [:trip, :stop]
        )
        |> Enum.group_by(
          &%{
            trip_id: &1.trip_id,
            direction: &1.trip.direction_id
          }
        )
        |> Enum.map(fn {k, v} ->
          %{
            trip_id: k.trip_id,
            direction: k.direction,
            start: v |> Enum.min_by(& &1.stop_sequence),
            finish: v |> Enum.max_by(& &1.stop_sequence)
          }
        end)
        |> Enum.map(
          &%{
            trip_id: &1.trip_id,
            direction: &1.direction,
            stime: &1.start.arrival_time,
            etime: &1.finish.arrival_time
            # sstop: &1.start.stop.coords,
            # estop: &1.finish.stop.coords
          }
        )
        |> Enum.sort_by(& &1.stime),
      #

      #
      real_trips:
        Repo.all(
          from(t in "real_schedule",
            select: %{
              trip_id: t.trip_id,
              direction: t.direction,
              stime: t.stime,
              etime: t.etime
              # sstop: t.sstop,
              # estop: t.estop
            },
            where: t.route_id == ^to_string(args.route),
            where:
              fragment(
                """
                  EXTRACT(epoch FROM ?::time - ?::time) / 60 < 10
                """,
                ^stime,
                t.stime
              ),
            where:
              fragment(
                """
                  EXTRACT(epoch FROM ?::time - ?::time) / 60 > -10
                """,
                ^etime,
                t.etime
              )
          )
        )
        |> Enum.sort_by(& &1.stime)
    }

    # Time.diff(Time.utc_now(), now, :millisecond)
  end

  def inspect_trip(args \\ %{trip_id: 65_021_202}) do
    [trip_route, direction] =
      Repo.one(
        from t in Trip,
          select: [t.route_id, t.direction_id],
          where: t.trip_id == ^args.trip_id
      )

    trip_stops =
      from st in StopTime,
        where: st.trip_id == ^args.trip_id,
        join: s in Stop,
        on: s.stop_id == st.stop_id,
        select: %{
          trip_id: st.trip_id,
          arrival_time: st.arrival_time,
          stop: s.coords,
          order: st.stop_sequence
        }

    sstop =
      Repo.all(trip_stops)
      |> Enum.min_by(& &1.order)

    realtime_trip =
      from t in "real_schedule",
        select: %{
          route_id: t.route_id,
          trip_id: t.trip_id,
          direction: t.direction,
          stime: t.stime,
          etime: t.etime,
          sstop: t.sstop,
          estop: t.estop
        },
        where: t.route_id == ^to_string(trip_route),
        where: t.direction == ^direction,
        order_by:
          fragment(
            """
              ABS(EXTRACT(epoch FROM ?::time - ?::time) / 60)
            """,
            ^sstop.arrival_time,
            t.stime
          ),
        limit: 1

    real_trip = Repo.one(realtime_trip)

    duplicated_positions =
      from p in "route_#{trip_route}",
        select: %{
          id: p.vehicle_id,
          time: p.timestamp,
          position: p.position,
          drop:
            fragment(
              """
                ? = ? AND ? != ?
              """,
              p.position,
              lag(p.position, 1, p.position) |> over(:w),
              p.timestamp,
              lag(p.timestamp, 1, p.timestamp) |> over(:w)
            )
        },
        windows: [
          w: [
            partition_by: p.vehicle_id,
            order_by: p.timestamp
          ]
        ],
        where: p.vehicle_id == ^real_trip.trip_id,
        where: p.timestamp >= ^real_trip.stime,
        where: p.timestamp <= ^real_trip.etime

    unduplicated_positions =
      from p in subquery(duplicated_positions),
        where: not p.drop,
        order_by: [p.id, p.time]

    # Repo.all(unduplicated_positions)

    realtime_to_plan =
      from st in subquery(trip_stops),
        cross_join: p in subquery(unduplicated_positions),
        select: %{
          trip_id: st.trip_id,
          arrival_time: st.arrival_time,
          stop: st.stop,
          order: st.order,
          vehicle_id: p.id,
          position: p.position,
          time: p.time,
          density:
            row_number()
            |> over(
              partition_by: st.order,
              order_by:
                fragment(
                  "st_distance(?, ?)",
                  st.stop,
                  p.position
                )
            )
        },
        windows: [w: [order_by: p.time]]

    final_query =
      from e in subquery(realtime_to_plan),
        select: %{
          order: e.order,
          plan_time: e.arrival_time,
          real_time: e.time
        },
        where: e.density == 1

    Repo.all(final_query)
  end

  def route_directions(route) do
    Repo.all(
      from t in Trip,
        select: t.direction_id,
        distinct: [
          t.route_id,
          t.direction_id
        ],
        where: t.route_id == ^route
    )
  end

  def route_positions(route) do
    sub =
      from p in "route_#{route}",
        select: %{
          id: p.vehicle_id,
          time: p.timestamp,
          position: p.position,
          drop: p.position == lag(p.position, 1) |> over(:w)
        },
        windows: [
          w: [
            partition_by: p.vehicle_id,
            order_by: p.timestamp
          ]
        ]

    Repo.all(
      from p in subquery(sub),
        select: %{
          id: p.id,
          time: p.time,
          position: p.position
        },
        where: not p.drop
    )
  end

  def route_line(route, direction \\ true) do
    Repo.one(
      from t in Trip,
        distinct: t.route_id,
        join: tr in Track,
        on: tr.track_id == t.track_id,
        where: t.route_id == ^route,
        where: t.direction_id == ^direction,
        select: tr.line
    )
  end

  def coords_of_trip(trip \\ 65_021_185) do
    target_trip_info =
      Repo.all(
        from t in Trip,
          where: t.trip_id == ^trip,
          preload: :track
      )
      |> Enum.map(
        &%{
          route: &1.route_id,
          line: &1.track.line
        }
      )
      |> Enum.at(0)

    target_trip_info.line.coordinates
    |> Enum.map(fn {x, y} -> [y, x] end)
    |> Toolkit.geojson_string()
  end

  def coords_of_norm_trip(trip) do
    target_trip_info =
      Repo.one(
        from tr in Track,
          select:
            fragment(
              """
                ST_ChaikinSmoothing(?::geometry, 3)
              """,
              tr.line
            ),
          join: t in Trip,
          on: t.track_id == tr.track_id,
          where: t.trip_id == ^trip
      )

    target_trip_info.coordinates
    |> Enum.map(fn {x, y} -> [y, x] end)
  end

  def norm_time(time) do
    NaiveDateTime.from_iso8601!((Date.utc_today() |> to_string) <> " " <> (time |> to_string))
    |> DateTime.from_naive!("Etc/UTC")
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
end
