defmodule Feed.Ecto.Calendar do
  import Ecto.Query, warn: false
  import Ecto.Changeset
  use Ecto.Schema

  alias Feed.Ecto.Trip

  @primary_key {:service_id, :integer, autogenerate: false}
  schema "calendar" do
    field :start_date, :date
    field :end_date, :date
    field :monday, :boolean
    field :tuesday, :boolean
    field :wednesday, :boolean
    field :thursday, :boolean
    field :friday, :boolean
    field :saturday, :boolean
    field :sunday, :boolean
    field :name, :string

    has_many :trips, Trip,
      foreign_key: :service_id,
      references: :service_id
  end

  def changeset(calendar, attrs) do
    calendar
    |> cast(attrs, [
      :service_id,
      :start_date,
      :end_date,
      :monday,
      :tuesday,
      :wednesday,
      :thursday,
      :friday,
      :saturday,
      :sunday,
      :name
    ])
    |> validate_required([
      :service_id,
      :start_date,
      :end_date,
      :monday,
      :tuesday,
      :wednesday,
      :thursday,
      :friday,
      :saturday,
      :sunday,
      :name
    ])
  end
end
