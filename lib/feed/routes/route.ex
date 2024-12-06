defmodule Feed.Routes.Route do
  use Ecto.Schema
  import Ecto.Changeset

  alias Feed.Trips.Trip
  alias Feed.Dates.Date

  schema "routes" do
    field :route_id, :integer
    field :agency_id, :string
    field :route_short_name, :string
    field :route_long_name, :string
    field :route_type, :integer
    field :transport_type, :string
    field :circular, :boolean, default: false
    field :urban, :boolean, default: false
    field :night, :boolean, default: false

    has_many :trips, Trip, foreign_key: :route_id, references: :route_id

    # has_many :dates, through: [:trips, :service_id]
    many_to_many :dates, Date, join_through: Trip, join_keys: [route_id: :route_id, service_id: :service_id], unique: true, preload_order: [asc: :date]

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(route, attrs) do
    route
    |> cast(attrs, [:route_id, :agency_id, :route_short_name, :route_long_name, :route_type, :transport_type, :circular, :urban, :night])
    |> validate_required([:route_id, :agency_id, :route_short_name, :route_long_name, :route_type, :transport_type, :circular, :urban, :night])
  end
end
