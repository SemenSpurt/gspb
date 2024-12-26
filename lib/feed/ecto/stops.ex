defmodule Feed.Ecto.Stops do
  import Ecto.Query, warn: false
  alias Feed.Repo


  defmodule Stop do
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key {:id, :integer, autogenerate: false}
    schema "stops" do
      field :name, :string
      field :coords, {:array, :float}
      field :transport, :string
      timestamps(type: :utc_datetime)
    end

    @doc false
    def changeset(stop, attrs) do
      stop
      |> cast(attrs,
        [
          :id,
          :name,
          :coords,
          :transport
        ]
      )
      |> validate_required(
        [
          :id,
          :name,
          :coords,
          :transport
        ]
      )
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

  def import_records(records \\ %{}) do
    Repo.insert_all(Stop, records)
  end
end
