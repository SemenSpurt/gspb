defmodule Feed.Shapes.Shape do
  use Ecto.Schema
  import Ecto.Changeset
  alias Feed.{
    # Times.Time,
    # Trips.Trip
  }
  @primary_key false
  schema "shapes" do


    field :shape_pt_lat, :float
    field :shape_pt_lon, :float
    field :shape_pt_sequence, :integer
    field :shape_dist_traveled, :float
    field :shape_id, :string, primary_key: true

    # belongs_to :times, Time, foreign_key: :shape_id, references: :shape_id, define_field: true, type: :string, primary_key: true
    # belongs_to :trips, Trip, foreign_key: :shape_id, references: :shape_id, define_field: true, type: :string, primary_key: true



    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(shape, attrs) do
    shape
    |> cast(attrs, [:shape_id, :shape_pt_lat, :shape_pt_lon, :shape_pt_sequence, :shape_dist_traveled])
    |> validate_required([:shape_id, :shape_pt_lat, :shape_pt_lon, :shape_pt_sequence, :shape_dist_traveled])
  end
end
