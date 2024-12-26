defmodule Feed.Repo.Migrations.CreateShapes do
  use Ecto.Migration

  def change do
    create table(:shapes) do
      add :shape_id, :string, primary_key: true
      add :coords,        {:array, :float}
      add :pt_sequence,   :integer
      add :dist_traveled, :float

      timestamps(type: :utc_datetime)
    end
  end
end
