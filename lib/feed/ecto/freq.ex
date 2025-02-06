defmodule Feed.Ecto.Freq do
  import Ecto.Query, warn: false
  import Ecto.Changeset
  use Ecto.Schema

  alias Feed.Ecto.Trip

  schema "freqs" do
    belongs_to :trips, Trip,
      foreign_key: :trip_id,
      references: :trip_id

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
