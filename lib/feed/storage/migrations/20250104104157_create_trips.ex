defmodule Feed.Storage.Migrations.CreateTrips do
  use Ecto.Migration

  def up do
    create_if_not_exists table(:routes, primary_key: false) do
      add :route_id, :integer, primary_key: true
      add :short_name, :string
      add :long_name, :string
      add :transport, :string
      add :circular, :boolean
      add :urban, :boolean
    end

    create_if_not_exists table(:tracks, primary_key: false) do
      add :track_id, :string, primary_key: true
      add :line, :geography
    end

    create_if_not_exists table(:trips, primary_key: false) do
      add :trip_id, :integer, primary_key: true
      add :route_id, :integer
      add :service_id, :integer
      add :track_id, :string
      add :direction_id, :boolean
    end

    create_if_not_exists unique_index(:trips, [
                           :route_id,
                           :trip_id,
                           :direction_id
                         ])

    create_if_not_exists table(:freqs) do
      add :trip_id, :integer, primary_key: true
      add :end_time, :time
      add :start_time, :time
      add :headway_secs, :integer
    end

    create_if_not_exists unique_index(:freqs, [:trip_id, :start_time])
  end

  def down do
    drop_if_exists table(:freqs)
    drop_if_exists table(:trips)
    drop_if_exists table(:routes)
    drop_if_exists table(:tracks)
  end
end
