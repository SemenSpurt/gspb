defmodule Feed.Repo.Migrations.CreateStopTimes do
  use Ecto.Migration

  def up do
    create_if_not_exists table(:stop_times) do
      add :trip_id, :integer
      add :arrival_time, :time
      add :departure_time, :time
      add :stop_id, :integer
      add :stop_sequence, :integer
      add :stage_id, :string
      add :shape_dist_traveled, :float
    end

    create_if_not_exists index(:stop_times, [:trip_id, :stop_id])

    create_if_not_exists table(:stages, primary_key: false) do
      add :stage_id, :string, primary_key: true
      add :line, :geography
    end
  end

  def down do
    drop_if_exists table(:stop_times)
    drop_if_exists table(:stages)
  end
end
