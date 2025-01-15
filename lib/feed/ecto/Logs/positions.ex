defmodule Feed.Ecto.Logs.Positions do
  import Geo
  import Ecto.Query, warn: false


  defmodule Position do
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key false
    schema "positions" do
      field :vehicle_id, :integer
      field :order_number, :integer
      field :timestamp, :naive_datetime
      field :position, Geo.PostGIS.Geometry
      field :direction, :integer
      field :direction_id, :boolean
      field :velocity, :integer
    end

    def changeset(position, attrs) do
      position
      |> cast(
        attrs,
        [
          :vehicle_id,
          :order_number,
          :timestamp,
          :position,
          :direction,
          :direction_id,
          :velocity
        ]
      )
      |> validate_required([
        :vehicle_id,
        :order_number,
        :timestamp,
        :position,
        :direction,
        :direction_id,
        :velocity
      ])
    end
  end
end
