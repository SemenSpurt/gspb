defmodule Feed.Repo.Migrations.CreateTrips do
  use Ecto.Migration

  def up do
    create_if_not_exists table(:routes) do
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

    create_if_not_exists table(:trips) do
      add :route_id,
          references(:routes,
            type: :integer,
            on_delete: :delete_all
          )

      add :service_id,
          references(:calendar,
            type: :integer,
            column: :service_id,
            on_delete: :delete_all
          )

      add :track_id,
          references(:tracks,
            type: :string,
            column: :track_id,
            on_delete: :delete_all
          )

      add :date, :date
      add :direction_id, :boolean
    end

    create_if_not_exists table(:freqs, primary_key: false) do
      add :trip_id,
          references(:trips,
            type: :integer,
            on_delete: :delete_all
          )

      add :end_time, :time
      add :start_time, :time
      add :headway_secs, :integer
    end

    create_if_not_exists index(:trips, [:track_id])
    create_if_not_exists index(:trips, [:service_id])
    create_if_not_exists index(:trips, [:route_id, :id])
  end

  def down do
    drop_if_exists table(:freqs)
    drop_if_exists table(:trips)
    drop_if_exists table(:routes)
    drop_if_exists table(:tracks)

  end
end
