defmodule Feed.Ecto.Stops do
  import Geo
  import Ecto.Query, warn: false

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
      |> cast(
        attrs,
        [
          :id,
          :name,
          :coords,
          :transport
        ]
      )
      |> validate_required([
        :id,
        :name,
        :coords,
        :transport
      ])
    end
  end

  def list_stops do
    Repo.all(Stop)
  end
end
