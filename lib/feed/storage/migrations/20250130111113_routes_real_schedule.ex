defmodule Feed.Storage.Migrations.RoutesRealSchedule do
  use Ecto.Migration

  def up do
    create_if_not_exists table(:real_schedule, primary_key: false) do
      add :route_id, :string, primary_key: true
      add :trip_id, :integer, primary_key: true
      add :direction, :boolean, primary_key: true
      add :stime, :utc_datetime, primary_key: true
      add :etime, :utc_datetime
      add :sstop, :geography
      add :estop, :geography
    end

    create_if_not_exists unique_index(:real_schedule, [:route_id, :trip_id, :direction, :stime])
  end

  def down do
    drop_if_exists table(:real_schedule)
  end
end
