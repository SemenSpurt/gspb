defmodule Feed.Ecto.Trip do
  import Ecto.Query, warn: false
  use Ecto.Schema
  import Ecto.Changeset

  alias Feed.{
    Ecto.Route,
    Ecto.Track,
    Ecto.Calendar,
    Ecto.StopTime,
    Ecto.Freq
  }

  @primary_key {:trip_id, :integer, autogenerate: false}
  schema "trips" do
    field :direction_id, :boolean, default: false

    belongs_to :track, Track,
      foreign_key: :track_id,
      references: :track_id,
      type: :string

    belongs_to :route, Route,
      foreign_key: :route_id,
      references: :route_id

    belongs_to :calendar, Calendar,
      foreign_key: :service_id,
      references: :service_id

    has_many :freqs, Freq,
      foreign_key: :trip_id,
      references: :trip_id,
      preload_order: [asc: :start_time]

    has_many :stop_times, StopTime,
      foreign_key: :trip_id,
      references: :trip_id,
      preload_order: [asc: :stop_sequence]
  end

  def changeset(trip, attrs) do
    trip
    |> cast(
      attrs,
      [
        :route_id,
        :service_id,
        :trip_id,
        :direction_id,
        :track_id
      ]
    )
    |> validate_required([
      :route_id,
      :service_id,
      :trip_id,
      :direction_id,
      :track_id
    ])
  end
end
