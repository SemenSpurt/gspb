defmodule Feed.Ecto.Stop do
  import Geo
  import Ecto.Query, warn: false
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:stop_id, :integer, autogenerate: false}
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
        :stop_id,
        :name,
        :coords,
        :transport
      ]
    )
    |> validate_required([
      :stop_id,
      :name,
      :coords,
      :transport
    ])
  end
end
