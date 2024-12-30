defmodule Feed.Ecto.CalendarDates do
  import Ecto.Query, warn: false

  alias Feed.{
    Repo,
    Ecto.Trips.Trip
  }

  defmodule CalendarDate do
    use Ecto.Schema
    import Ecto.Changeset

    schema "calendar_dates" do
      field :service_id, :integer
      field :date, :date
      field :exception, :integer

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
        :exception
      ])
      |> validate_required([
        :service_id,
        :date,
        :exception
      ])
    end
  end

  def list_dates do
    Repo.all(CalendarDate)
  end
end
