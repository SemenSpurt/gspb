defmodule Feed.Dates.Date do
  use Ecto.Schema
  import Ecto.Changeset
  alias Feed.Trips.Trip
  # alias Feed.Routes.Route

  schema "dates" do
    field :service_id, :integer
    field :date, :string # should be integer?
    field :exception_type, :integer

    has_many :trips, Trip, foreign_key: :service_id, references: :service_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(date, attrs) do
    date
    |> cast(attrs, [:service_id, :date, :exception_type])
    |> validate_required([:service_id, :date, :exception_type])
  end
end
