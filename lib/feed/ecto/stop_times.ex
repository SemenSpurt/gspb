defmodule Feed.Ecto.StopTimes do
  import Ecto.Query, warn: false

  alias Feed.{
    Repo,
    Ecto.Stops.Stop,
    Ecto.Shapes.Shape,
  }


  defmodule Time do
    use Ecto.Schema
    import Ecto.Changeset

    schema "stop_times" do
      belongs_to :stop, Stop,
        foreign_key: :stop_id,
        references: :id

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


  def import_records(records \\ %{}) do
    Repo.insert_all(Time, records)
  end
end
