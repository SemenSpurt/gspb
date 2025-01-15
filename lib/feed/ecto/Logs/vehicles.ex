defmodule Feed.Ecto.Logs.Vehicles do
  import Geo
  import Ecto.Query, warn: false

  defmodule Vehicle do
    alias Feed.Ecto.Logs.Positions.Position
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key false
    schema "vehicles" do
      field :route_id, :string
      field :direction_id, :boolean
      field :order_number, :integer
      field :vehicle_id, :integer, primary_key: true
      field :vehicle_label, :string
      field :license_plate, :string

      has_many :positions, Position,
      foreign_key: :vehicle_id,
      references: :vehicle_id
    end

    def changeset(vehicle, attrs) do
      vehicle
      |> cast(
        attrs,
        [
          :route_id,
          :direction_id,
          :order_number,
          :vehicle_id,
          :vehicle_label,
          :license_plate
        ]
      )
      |> validate_required([
        :route_id,
        :direction_id,
        :order_number,
        :vehicle_id,
        :vehicle_label,
        :license_plate
      ])
    end
  end
end
