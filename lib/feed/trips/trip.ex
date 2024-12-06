defmodule Feed.Trips.Trip do
  use Ecto.Schema
  import Ecto.Changeset
  alias Feed.{
    # Routes.Route,
    # Dates.Date,
    Times.Time,
    Shapes.Shape
  }

  schema "trips" do
    field :route_id, :integer
    field :service_id, :integer
    field :trip_id, :integer
    field :direction_id, :boolean, default: false
    field :shape_id, :string

    has_many :times, Time, foreign_key: :trip_id, references: :trip_id, preload_order: [asc: :stop_sequence]

    has_many :shapes, Shape, foreign_key: :shape_id, references: :shape_id, preload_order: [asc: :shape_pt_sequence]

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(trip, attrs) do
    trip
    |> cast(attrs, [:route_id, :service_id, :trip_id, :direction_id, :shape_id])
    |> validate_required([:route_id, :service_id, :trip_id, :direction_id, :shape_id])
  end
end
