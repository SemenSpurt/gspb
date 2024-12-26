defmodule Feed.Ecto.Trips do
  import Ecto.Query, warn: false

  alias Date, as: Dt
  alias Calendar.Date, as: CalenDate

  alias Feed.{
    Repo,
    Ecto.Calendar.Calendar,
    Ecto.StopTimes.Time,
    Ecto.CalendarDates.Date,
    Ecto.Freqs.Freq,
    Ecto.Shapes.Shape,
    Ecto.Routes.Route
  }


  defmodule Trip do
    use Ecto.Schema
    import Ecto.Changeset

    schema "trips" do
      belongs_to :route, Route,
        foreign_key: :route_id,
        references: :id

      belongs_to :calendar, Calendar,
        foreign_key: :service_id,
        references: :id

      field :direction_id, :boolean, default: false
      field :shape_id, :string

      has_many :freqs, Freq,
        foreign_key: :trip_id,
        references: :id,
        preload_order: [asc: :start_time]

      has_many :times, Time,
        foreign_key: :trip_id,
        references: :id,
        preload_order: [asc: :stop_sequence]

      has_many :shapes, Shape,
        foreign_key: :shape_id,
        references: :shape_id,
        preload_order: [asc: :shape_pt_sequence]

      timestamps(type: :utc_datetime)
    end

    @doc false
    def changeset(trip, attrs) do
      trip
      |> cast(attrs, [
        :route_id,
        :service_id,
        :trip_id,
        :direction_id,
        :shape_id
      ])
      |> validate_required([
        :route_id,
        :service_id,
        :trip_id,
        :direction_id,
        :shape_id
      ])
    end
  end


  def list_trips do
    Repo.all(Trip)
  end


  def get_trip!(id), do: Repo.get!(Trip, id)


  def trip_stops(trip_id) do
    query =
      from tr in Trip,
        where: tr.trip_id == ^trip_id,
        preload: [times: [:stop, :shapes]]

    Feed.Repo.all(query)
  end


  def route_trips(route_id, date) do
  weekday =
      date
      |> Dt.from_iso8601!
      |> CalenDate.day_of_week_name
      |> String.downcase
      |> String.to_atom

  schedule =
    from service in Calendar,
      where: field(service, ^weekday) == true,
      where: service.end_date >= ^date,
      where: service.start_date <= ^date,
      select: service.service_id

  exceptions =
    from dt in Date,
      where: dt.date == ^date

  query =
    from trip in Trip,
      where: trip.route_id == ^route_id,
      left_join: s in subquery(schedule),
      on: s.service_id == trip.service_id,
      left_join: e in subquery(exceptions),
      on: e.service_id == trip.service_id,
      where: e.exception_type != 2,
      preload: [times: [:stop]]
  Repo.all(query)
  end


  def create_trip(attrs \\ %{}) do
    %Trip{}
    |> Trip.changeset(attrs)
    |> Repo.insert()
  end


  def update_trip(%Trip{} = trip, attrs) do
    trip
    |> Trip.changeset(attrs)
    |> Repo.update()
  end


  def delete_trip(%Trip{} = trip) do
    Repo.delete(trip)
  end


  def change_trip(%Trip{} = trip, attrs \\ %{}) do
    Trip.changeset(trip, attrs)
  end


  def import_records(records \\ %{}) do
    Repo.insert_all(Trip, records)
  end
end
