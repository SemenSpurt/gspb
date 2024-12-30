defmodule Feed.Ecto.Trips do
  import Ecto.Query, warn: false

  alias Feed.{
    Repo,
    Ecto.Calendar.Calendar,
    Ecto.StopTimes.StopTime,
    Ecto.Freqs.Freq,
    Ecto.Shapes.Track,
    Ecto.Routes.Route
  }


  defmodule Trip do
    use Ecto.Schema
    import Ecto.Changeset

    schema "trips" do
      belongs_to :route, Route,
        foreign_key: :route_id,
        references: :id

      belongs_to :calendar, Calendar,
        foreign_key: :service_id,
        references: :service_id

      field :direction_id, :boolean, default: false
      field :track_id, :string

      has_many :freqs, Freq,
        foreign_key: :trip_id,
        references: :id,
        preload_order: [asc: :start_time]

      has_many :times, StopTime,
        foreign_key: :trip_id,
        references: :id,
        preload_order: [asc: :stop_sequence]

      has_many :tracks, Track,
        foreign_key: :track_id,
        references: :track_id,
        preload_order: [asc: :shape_pt_sequence]
    end


    def changeset(trip, attrs) do
      trip
      |> cast(attrs,
        [
          :route_id,
          :service_id,
          :trip_id,
          :direction_id,
          :shape_id
        ]
      )
      |> validate_required(
        [
          :route_id,
          :service_id,
          :trip_id,
          :direction_id,
          :shape_id
        ]
      )
    end
  end


  def list_trips do
    Repo.all(Trip)
  end
end
