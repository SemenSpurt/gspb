defmodule Feed.Route.Trips do

  import Ecto.Query, warn: false
  alias Feed.Repo
  alias Date, as: Dt
  alias Calendar.Date, as: CalenDate

  alias Feed.{
    Time.Times.Time,
    Time.Week.Days,
    Time.Dates.Date,
    Place.Shapes.Shape,
    Route.Routes.Route

  }

  defmodule Trip do
    use Ecto.Schema
    import Ecto.Changeset

    schema "trips" do
      belongs_to :route, Route, foreign_key: :route_id, references: :route_id
      belongs_to :days, Days, foreign_key: :service_id, references: :service_id
      field :trip_id, :integer
      field :direction_id, :boolean, default: false
      field :shape_id, :string

      has_many :times, Time, foreign_key: :trip_id, references: :trip_id, preload_order: [asc: :stop_sequence]
      has_many :shapes, Shape, foreign_key: :shape_id, references: :shape_id, preload_order: [asc: :shape_pt_sequence]

      timestamps(type: :utc_datetime)
    end

    @doc false
    def changeset(trip, attrs) do
      trip
      |> cast(attrs, [:route_id, :service_id, :trip_id, :direction_id, :shape_id])
      |> validate_required([:route_id, :service_id, :trip_id, :direction_id, :shape_id])
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

    dayOfWeek = date |> Dt.from_iso8601! |> CalenDate.day_of_week_name |> String.downcase |> String.to_atom

    subquery =
      from service in Days,
        where: field(service, ^dayOfWeek) == true,
        select: service.service_name,
        distinct: [service.service_name]

    query =
      from trip in Trip,
        where: trip.route_id == ^route_id,
        join: d in Days,
        on: d.service_id == trip.service_id,
        where: d.service_name in subquery(subquery),
        where: d.start_date >= ^date and d.end_date <= ^date,
        join: dt in Date,
        on: dt.service_id == d.service_id,
        where: dt.exception_type != 2

        # preload: [:times]

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

  def import(records \\ %{}) do

    Trip
    |> Repo.insert_all(
      Enum.map(records, fn [route_id, service_id, trip_id, direction_id, shape_id] ->
        %{

          :route_id     => String.to_integer(route_id),
          :service_id   => String.to_integer(service_id),
          :trip_id      => String.to_integer(trip_id),
          :direction_id => direction_id == "1",
          :shape_id     => shape_id,

          :inserted_at  => DateTime.utc_now(:second),
          :updated_at   => DateTime.utc_now(:second)
        }
      end)
    )
  end
end
