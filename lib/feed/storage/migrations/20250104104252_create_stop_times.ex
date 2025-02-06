defmodule Feed.Storage.Migrations.CreateStopTimes do
  use Ecto.Migration

  def up do
    create_if_not_exists table(:stops, primary_key: false) do
      add :stop_id, :integer, primary_key: true
      add :name, :string
      add :coords, :geography
      add :transport, :string
    end

    create_if_not_exists table(:stages, primary_key: false) do
      add :stage_id, :string, primary_key: true
      add :line, :geography
    end

    create_if_not_exists table(:stop_times, primary_key: false) do
      add :trip_id, :integer, primary_key: true
      add :stop_sequence, :integer, primary_key: true
      add :stop_id, :integer
      add :stage_id, :string
      add :arrival_time, :time
      add :departure_time, :time

      add :shape_dist_traveled, :float
    end

    create_if_not_exists unique_index(:stop_times, [:trip_id, :stop_sequence])
  end

  def down do
    drop_if_exists table(:stop_times)
    drop_if_exists table(:stages)
    drop_if_exists table(:stops)
  end
end
