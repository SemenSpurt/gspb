defmodule Feed.Repo.Migrations.CreateShapes do
  use Ecto.Migration

  def change do
    create table(:shapes) do
      add :shape_id, :string
      add :shape_pt_lat, :float
      add :shape_pt_lon, :float
      add :shape_pt_sequence, :integer
      add :shape_dist_traveled, :float

      timestamps(type: :utc_datetime)
    end
  end
end
