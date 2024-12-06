defmodule Feed.Times.Time do
  use Ecto.Schema
  import Ecto.Changeset

  alias Feed.{
    Stops.Stop,
    # Trips.Trip,
    Shapes.Shape,
  }

  schema "times" do
    field :trip_id, :integer
    # belongs_to :trips, Trip, foreign_key: :trip_id, references: :trip_id, define_field: true
    field :arrival_time, :time
    field :departure_time, :time
    belongs_to :stop, Stop, foreign_key: :stop_id, references: :stop_id, define_field: true
    field :stop_sequence, :integer
    field :shape_id, :string, defaults: nil
    field :shape_dist_traveled, :float

    has_many :shapes, Shape, foreign_key: :shape_id, references: :shape_id, preload_order: [asc: :shape_pt_sequence]

    # belongs_to :shapes, Shape, foreign_key: :shape_id, references: :shape_id, define_field: true, type: :string, primary_key: true

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(time, attrs) do
    time
    |> cast(attrs, [:trip_id, :arrival_time, :departure_time, :stop_id, :stop_sequence, :shape_id, :shape_dist_traveled])
    |> validate_required([:trip_id, :arrival_time, :departure_time, :stop_id, :stop_sequence, :shape_id, :shape_dist_traveled])
  end
end
