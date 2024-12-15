defmodule Feed.Place.Shapes do
  import Ecto.Query, warn: false
  alias Feed.Repo


  defmodule Shape do
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key false
    schema "shapes" do
      field :shape_pt_lat, :float
      field :shape_pt_lon, :float
      field :shape_pt_sequence, :integer
      field :shape_dist_traveled, :float
      field :shape_id, :string, primary_key: true
      timestamps(type: :utc_datetime)
    end

    def changeset(shape, attrs) do
      shape
      |> cast(attrs, [
        :shape_id,
        :shape_pt_lat,
        :shape_pt_lon,
        :shape_pt_sequence,
        :shape_dist_traveled
      ])
      |> validate_required([
        :shape_id,
        :shape_pt_lat,
        :shape_pt_lon,
        :shape_pt_sequence,
        :shape_dist_traveled
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

  def import(records \\ %{}) do
    Shape
    |> Repo.insert_all(
      Enum.map(records, fn [shape_id, shape_pt_lat, shape_pt_lon,
      shape_pt_sequence, shape_dist_traveled] ->
        %{
          :shape_id            => shape_id,
          :shape_pt_lat        => String.to_float(shape_pt_lat),
          :shape_pt_lon        => String.to_float(shape_pt_lon),
          :shape_pt_sequence   => String.to_integer(shape_pt_sequence),
          :shape_dist_traveled => String.to_float(shape_dist_traveled),

          :inserted_at         => DateTime.utc_now(:second),
          :updated_at          => DateTime.utc_now(:second)
        }
      end)
    )
  end
end
