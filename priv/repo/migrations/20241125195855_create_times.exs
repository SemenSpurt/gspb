defmodule Feed.Repo.Migrations.CreateTimes do
  use Ecto.Migration

  def change do
    create table(:times) do
      add :trip_id, :integer
      add :arrival_time, :time
      add :departure_time, :time
      add :stop_id, :integer
      add :stop_sequence, :integer
      add :shape_id, :string
      add :shape_dist_traveled, :float

      timestamps(type: :utc_datetime)
    end
  end
end
