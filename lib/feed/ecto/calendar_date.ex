defmodule Feed.Ecto.CalendarDate do
  import Ecto.Query, warn: false
  import Ecto.Changeset
  use Ecto.Schema

  alias Feed.Ecto.Trip


  schema "calendar_dates" do
    field :service_id, :integer
    field :date, :date
    field :exception, :integer
    field :feed_date, :date

    has_many :trips, Trip,
      foreign_key: :service_id,
      references: :service_id
  end

  @doc false
  def changeset(date, attrs) do
    date
    |> cast(attrs, [
      :service_id,
      :date,
      :exception,
      :feed_date
    ])
    |> validate_required([
      :service_id,
      :date,
      :exception,
      :feed_date
    ])
  end
end
