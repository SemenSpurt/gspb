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

  @doc "Handler 2 ~ 50ms"
  def routes_dist_gt(args) do
    now = Time.utc_now()

    types =
      if args.types == [] do
        Route
        |> select([r], r.transport)
        |> distinct([r], r.transport)
        |> Repo.all()
      else
        args.types
      end

    # Style pipe
    query =
      from r in Route,
        distinct: r.id,
        join: t in Trip,
        on: r.id == t.route_id,
        join: t1 in Track,
        on: t1.track_id == t.track_id,
        where: r.transport in ^types,
        where: st_length(t1.line) > (^args.dist_gt / 1000),
        where: ilike(r.long_name, ^"%#{args.search}%")

    Repo.all(query)
    # Time.diff(Time.utc_now(), now, :millisecond)
  end
end
