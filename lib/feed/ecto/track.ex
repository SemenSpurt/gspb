defmodule Feed.Ecto.Track do
  import Ecto.Query, warn: false
  import Ecto.Changeset
  use Ecto.Schema

  @primary_key {:track_id, :string, autogenerate: false}
  schema "tracks" do
    field :line, Geo.PostGIS.Geometry
  end

  def changeset(track, attrs) do
    track
    |> cast(
      attrs,
      [
        :track_id,
        :line
      ]
    )
    |> validate_required([
      :track_id,
      :line
    ])
  end
end
