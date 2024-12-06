defmodule Feed.Stops.Stop do
  use Ecto.Schema
  import Ecto.Changeset
  # alias Feed.Times.Time

  schema "stops" do
    field :stop_id, :integer
    field :stop_code, :integer
    field :stop_name, :string
    field :stop_lat, :float
    field :stop_lon, :float
    field :location_type, :integer
    field :wheelchair_boarding, :integer
    field :transport_type, :string

    # has_many :times, Time, foreign_key: :stop_id, references: :stop_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(stop, attrs) do
    stop
    |> cast(attrs, [:stop_id, :stop_code, :stop_name, :stop_lat, :stop_lon, :location_type, :wheelchair_boarding, :transport_type])
    |> validate_required([:stop_id, :stop_code, :stop_name, :stop_lat, :stop_lon, :location_type, :wheelchair_boarding, :transport_type])
  end
end
