defmodule Feed.Ecto.StopTime do
  import Ecto.Query, warn: false
  use Ecto.Schema
  import Ecto.Changeset

  alias Feed.{
    Ecto.Trip,
    Ecto.Stop,
    Ecto.Stage
  }

  @primary_key false
  schema "stop_times" do
    belongs_to :trip, Trip,
      foreign_key: :trip_id,
      references: :trip_id,
      primary_key: true

    belongs_to :stop, Stop,
      foreign_key: :stop_id,
      references: :stop_id

    field :arrival_time, :time
    field :departure_time, :time
    field :stop_sequence, :integer, primary_key: true
    field :stage_id, :string, defaults: nil
    field :shape_dist_traveled, :float

    has_one :stage, Stage,
      foreign_key: :stage_id,
      references: :stage_id
  end

  def changeset(time, attrs) do
    time
    |> cast(
      attrs,
      [
        :trip_id,
        :arrival_time,
        :departure_time,
        :stop_id,
        :stop_sequence,
        :stage_id,
        :shape_dist_traveled
      ]
    )
    |> validate_required([
      :trip_id,
      :arrival_time,
      :departure_time,
      :stop_id,
      :stop_sequence,
      :stage_id,
      :shape_dist_traveled
    ])
  end
end
