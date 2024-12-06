defmodule Feed.Week.Days do
  use Ecto.Schema
  import Ecto.Changeset
  alias Feed.Trips.Trip

  schema "days" do
    field :service_id, :integer
    field :monday, :boolean, default: false
    field :tuesday, :boolean, default: false
    field :wednesday, :boolean, default: false
    field :thursday, :boolean, default: false
    field :friday, :boolean, default: false
    field :saturday, :boolean, default: false
    field :sunday, :boolean, default: false
    field :start_date, :date
    field :end_date, :date
    field :service_name, :string

    has_many :trips, Trip, foreign_key: :service_id, references: :service_id



    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(days, attrs) do
    days
    |> cast(attrs, [:service_id, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday, :start_date, :end_date, :service_name])
    |> validate_required([:service_id, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday, :start_date, :end_date, :service_name])
  end
end
