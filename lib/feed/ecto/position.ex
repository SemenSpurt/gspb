defmodule Feed.Ecto.Position do
  import Geo
  import Ecto.Query, warn: false

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "positions" do
    field :vehicle_id, :integer, primary_key: true
    field :timestamp, :utc_datetime, primary_key: true
    field :position, Geo.PostGIS.Geometry
    field :direction_id, :boolean
    field :order_num, :integer
    field :plate, :string
    field :label, :string
  end

  def changeset(position, attrs) do
    position
    |> cast(
      attrs,
      [
        :vehicle_id,
        :timestamp,
        :position,
        :direction_id,
        :order,
        :plate,
        :label
      ]
    )
    |> validate_required([
      :vehicle_id,
      :timestamp,
      :position,
      :direction_id,
      :order,
      :plate,
      :label
    ])
  end
end
