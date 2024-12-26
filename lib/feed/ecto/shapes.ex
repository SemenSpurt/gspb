defmodule Feed.Ecto.Shapes do
  import Ecto.Query, warn: false
  alias Feed.Repo

  defmodule Shape do
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key {:shape_id, :string, autogenerate: false}
    schema "shapes" do
      field :coords, {:array, :float}
      field :pt_sequence, :integer
      field :dist_traveled, :float
      timestamps(type: :utc_datetime)
    end

    def changeset(shape, attrs) do
      shape
      |> cast(attrs, [
        :shape_id,
        :coords,
        :pt_sequence,
        :dist_traveled
      ])
      |> validate_required([
        :shape_id,
        :coords,
        :pt_sequence,
        :dist_traveled
      ])
    end
  end

  def list_shapes do
    Repo.all(Shape)
  end


  def get_shape!(id), do: Repo.get!(Shape, id)


  def create_shape(attrs \\ %{}) do
    %Shape{}
    |> Shape.changeset(attrs)
    |> Repo.insert()
  end

  def update_shape(%Shape{} = shape, attrs) do
    shape
    |> Shape.changeset(attrs)
    |> Repo.update()
  end

  def delete_shape(%Shape{} = shape) do
    Repo.delete(shape)
  end

  def change_shape(%Shape{} = shape, attrs \\ %{}) do
    Shape.changeset(shape, attrs)
  end

  def import_records(records \\ %{}) do
    Repo.insert_all(Shape, records)
  end
end
