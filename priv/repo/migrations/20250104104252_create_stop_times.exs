defmodule Feed.Repo.Migrations.CreateStopTimes do
  use Ecto.Migration

  def change do
    create table(:stop_times) do
      add :trip_id, :integer
      add :arrival_time, :time
      add :departure_time, :time
      add :stop_id, :integer
      add :stop_sequence, :integer
      add :stage_id, :string
      add :shape_dist_traveled, :float
    end
  end
end
