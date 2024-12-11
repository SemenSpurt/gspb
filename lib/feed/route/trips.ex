defmodule Feed.Route.Trips do

  import Ecto.Query, warn: false
  alias Feed.Repo

  alias Feed.{
    Time.Times.Time,
    Place.Shapes.Shape
  }

  defmodule Trip do
    use Ecto.Schema
    import Ecto.Changeset

    schema "trips" do
      field :route_id, :integer
      field :service_id, :integer
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
    # Repo.all(Trip)
    # |> Enum.find(fn(item) -> Map.get(item, :trip_id) === trip_id end)
    # |> Repo.preload([:shapes, times: [:stop, :shapes]])
    query =
      from tr in Trip,
        where: tr.trip_id == ^trip_id,
        preload: [times: [:stop, :shapes]]

      Feed.Repo.all(query)
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
