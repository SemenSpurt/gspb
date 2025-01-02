defmodule Feed.Ecto.Stops do
  import Ecto.Query, warn: false
  import Geo.PostGIS

  alias Feed.Repo

  defmodule Stop do
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key {:id, :integer, autogenerate: false}
    schema "stops" do
      field :name, :string
      field :coords, Geo.PostGIS.Geometry
      field :transport, :string
    end

    @doc false
    def changeset(stop, attrs) do
      stop
      |> cast(attrs,
        [
          :id,
          :name,
          :coords,
          :transport
        ]
      )
      |> validate_required(
        [
          :id,
          :name,
          :coords,
          :transport
        ]
      )
    end
  end

  def list_stops do
    Repo.all(Stop)
  end


  @handle1_attrs %{
    types: [:bus, :tram],
    search: "",
    radius: 5750,
    coords: [30.336146, 59.934243]
  }
  @doc ""
  def stops_within_radius(args \\ @handle1_attrs) do
    types =
      if args.types == [] do
        Route
        |> select([r], r.transport)
        |> distinct([r], r.transport)
        |> Repo.all()
      else
        args.types #|> Enum.map(&Atom.to_string(&1))
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
end
