defmodule Feed.Freqs.Freq do
  use Ecto.Schema
  import Ecto.Changeset
  alias Feed.Trips.Trip

  schema "freqs" do
    belongs_to :trips, Trip, foreign_key: :trip_id, references: :trip_id, define_field: true
    field :start_time, :time
    field :end_time, :time
    field :headway_secs, :integer
    field :exact_times, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(freq, attrs) do
    freq
    |> cast(attrs, [:trip_id, :start_time, :end_time, :headway_secs, :exact_times])
    |> validate_required([:trip_id, :start_time, :end_time, :headway_secs, :exact_times])
  end
end
