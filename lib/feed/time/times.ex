defmodule Feed.Time.Times do
  import Ecto.Query, warn: false

  alias Feed.{
    Repo,
    Place.Stops.Stop,
    Place.Shapes.Shape,
  }

  alias Time, as: Tm

  defmodule Time do
    use Ecto.Schema
    import Ecto.Changeset

    schema "times" do
      belongs_to :stop, Stop,
        foreign_key: :stop_id,
        references: :stop_id

      field :trip_id, :integer
      field :arrival_time, :time
      field :departure_time, :time
      field :stop_sequence, :integer
      field :shape_id, :string, defaults: nil
      field :shape_dist_traveled, :float

      has_many :shapes, Shape,
        foreign_key: :shape_id,
        references: :shape_id,
        preload_order: [asc: :shape_pt_sequence]

      timestamps(type: :utc_datetime)
    end

    def changeset(time, attrs) do
      time
      |> cast(attrs, [
        :trip_id,
        :arrival_time,
        :departure_time,
        :stop_id,
        :stop_sequence,
        :shape_id,
        :shape_dist_traveled
      ])
      |> validate_required([
        :trip_id,
        :arrival_time,
        :departure_time,
        :stop_id,
        :stop_sequence,
        :shape_id,
        :shape_dist_traveled
      ])
    end
  end

  def list_times do
    Repo.all(Time)
  end


  def get_time!(id), do: Repo.get!(Time, id) |> Repo.preload(:shapes)


  def create_time(attrs \\ %{}) do
    %Time{}
    |> Time.changeset(attrs)
    |> Repo.insert()
  end


  def update_time(%Time{} = time, attrs) do
    time
    |> Time.changeset(attrs)
    |> Repo.update()
  end


  def delete_time(%Time{} = time) do
    Repo.delete(time)
  end


  def change_time(%Time{} = time, attrs \\ %{}) do
    Time.changeset(time, attrs)
  end


  defp parse_time(time_str) do
    [hr, min, sec] =
      time_str
      |> String.split(":")
      |> Enum.map(&String.to_integer/1)

    hr * 3600 + min * 60 + sec
  end

  def import(records \\ %{}) do
    Time
    |> Repo.insert_all(
      Enum.map(records, fn [
        trip_id,
        arrival_time,
        departure_time,
        stop_id,
        stop_sequence,
        shape_id,
        shape_dist_traveled
      ] ->
      %{
        :trip_id             => String.to_integer(trip_id),
        :arrival_time        => Tm.from_seconds_after_midnight(parse_time(arrival_time)),
        :departure_time      => Tm.from_seconds_after_midnight(parse_time(departure_time)),
        :stop_id             => String.to_integer(stop_id),
        :stop_sequence       => String.to_integer(stop_sequence),
        :shape_id            => shape_id,
        :shape_dist_traveled => String.to_float(shape_dist_traveled),

        :inserted_at         => DateTime.utc_now(:second),
        :updated_at          => DateTime.utc_now(:second)
      }
      end)
    )
  end
end
