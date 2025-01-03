defmodule Feed.Ecto.Routes do
  import Ecto.Query, warn: false
  import Geo.PostGIS

  alias Feed.{
    Repo,
    Ecto.Trips.Trip
  }

  alias Feed.Ecto.{
    Trips.Trip,
    Stops.Stop,
    Routes.Route,
    Shapes.Track,
    StopTimes.StopTime,
    Week.Week,
    Calendar.Calendar
  }

  defmodule Route do
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key {:id, :integer, autogenerate: false}
    schema "routes" do
      field :short_name, :string
      field :long_name, :string
      field :transport, :string
      field :circular, :boolean
      field :urban, :boolean

      has_many :trips, Trip,
        foreign_key: :route_id,
        references: :id
    end

    def changeset(route, attrs) do
      route
      |> cast(
        attrs,
        [
          :id,
          :short_name,
          :long_name,
          :transport,
          :circular,
          :urban
        ]
      )
      |> validate_required([
        :id,
        :short_name,
        :long_name,
        :transport,
        :circular,
        :urban
      ])
    end
  end

  def list_routes do
    Repo.all(Route)
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

  @doc "Handler 3 ~ 220ms) List routes that visit the stop at day specified"
  def routes_over_stop(attrs) do
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
  end

  @doc "Handler 4 ~ 300ms) Routes to stop hourly mean arrival time"
  def hourly_mean_arrival(args) do
    names =
      from w in Week,
        select: w.name,
        where: field(w, ^args.day)

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
            ^args.route_id,
            subquery(names)
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
    names =
      from w in Week,
        select: w.name,
        where: field(w, ^args.day)

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
            ^args.stop_id1,
            subquery(names),
            ^args.stop_id2
          )

    Repo.all(query)
  end

  @doc "Handler 6 ~ 700 ms) List routes with percent of similarity"
  def route_substitutions(args) do
    names =
      from w in Week,
        select: w.name,
        where: field(w, ^args.day)

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
                  st_intersection(t1.line,(SELECT line FROM target))
                  ) > (SELECT dist FROM target) * ? * 0.01
              )
            """,
            ^args.route_id,
            ^args.route_id,
            r.id,
            subquery(names),
            ^args.percent
          )

    Repo.all(query)
  end
end
