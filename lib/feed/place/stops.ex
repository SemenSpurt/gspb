defmodule Feed.Place.Stops do
  import Ecto.Query, warn: false
  alias Feed.Repo


  defmodule Stop do
    use Ecto.Schema
    import Ecto.Changeset

    schema "stops" do
      field :stop_id, :integer
      field :stop_code, :integer
      field :stop_name, :string
      field :stop_lat, :float
      field :stop_lon, :float
      field :location_type, :integer
      field :wheelchair_boarding, :integer
      field :transport_type, :string

      timestamps(type: :utc_datetime)
    end

    @doc false
    def changeset(stop, attrs) do
      stop
      |> cast(
        attrs,
        [
          :stop_id,
          :stop_code,
          :stop_name,
          :stop_lat,
          :stop_lon,
          :location_type,
          :wheelchair_boarding,
          :transport_type
        ]
      )
      |> validate_required([
        :stop_id,
        :stop_code,
        :stop_name,
        :stop_lat,
        :stop_lon,
        :location_type,
        :wheelchair_boarding,
        :transport_type
      ])
    end
  end

  def list_stops do
    Repo.all(Stop)
  end

  def get_stop!(id), do: Repo.get!(Stop, id)

  def create_stop(attrs \\ %{}) do
    %Stop{}
    |> Stop.changeset(attrs)
    |> Repo.insert()
  end

  def update_stop(%Stop{} = stop, attrs) do
    stop
    |> Stop.changeset(attrs)
    |> Repo.update()
  end

  def delete_stop(%Stop{} = stop) do
    Repo.delete(stop)
  end


  def change_stop(%Stop{} = stop, attrs \\ %{}) do
    Stop.changeset(stop, attrs)
  end

  def import(records \\ %{}) do
    Stop
    |> Repo.insert_all(
      Enum.map(records, fn [stop_id, stop_code, stop_name, stop_lat,
      stop_lon, location_type, wheelchair_boarding, transport_type] ->
        %{

          :stop_id             => String.to_integer(stop_id),
          :stop_code           => String.to_integer(stop_code),
          :stop_name           => stop_name,
          :stop_lat            => String.to_float(stop_lat),
          :stop_lon            => String.to_float(stop_lon),
          :location_type       => String.to_integer(location_type),
          :wheelchair_boarding => String.to_integer(wheelchair_boarding),
          :transport_type      => transport_type,

          :inserted_at  => DateTime.utc_now(:second),
          :updated_at   => DateTime.utc_now(:second)
        }
      end)
    )
  end
end
