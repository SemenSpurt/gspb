defmodule Feed.Ecto.Stage do
  import Ecto.Query, warn: false
  import Ecto.Changeset
  use Ecto.Schema

  @primary_key {:stage_id, :string, autogenerate: false}
  schema "stages" do
    field :line, Geo.PostGIS.Geometry
  end

  def changeset(stage, attrs) do
    stage
    |> cast(
      attrs,
      [
        :stage_id,
        :line
      ]
    )
    |> validate_required([
      :stage_id,
      :line
    ])
  end
end
