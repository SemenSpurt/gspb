defmodule Feed.Ecto.Freqs do
  import Ecto.Query, warn: false

  alias Feed.{
    Repo,
    Ecto.Trips.Trip
  }

  defmodule Freq do
    use Ecto.Schema
    import Ecto.Changeset

    schema "freqs" do
      belongs_to :trips, Trip,
        foreign_key: :trip_id,
        references: :id

      field :start_time, :time
      field :end_time, :time
      field :headway_secs, :integer
    end

    def changeset(freq, attrs) do
      freq
      |> cast(
        attrs,
        [
          :trip_id,
          :start_time,
          :end_time,
          :headway_secs
        ]
      )
      |> validate_required([
        :trip_id,
        :start_time,
        :end_time,
        :headway_secs
      ])
    end
  end

  def list_freqs do
    Repo.all(Freq)
  end
end
