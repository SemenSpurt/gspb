defmodule Feed.Repo.Migrations.CreateTrips do
  use Ecto.Migration

  def up do
    create_if_not_exists table(:tracks, primary_key: false) do
      add :line, :geography
      add :track_id, :string, primary_key: true
    end

    create_if_not_exists index(:tracks, [:track_id], unique: true)

    create_if_not_exists table(:trips) do
      add :route_id, :integer
      add :service_id, :integer
      add :direction_id, :boolean

      add :track_id,
          references(:tracks,
            on_delete: :delete_all,
            type: :string,
            column: :track_id
          )
    end

    create_if_not_exists index(:trips, [:track_id])
    # create_if_not_exists index(:trips, [:route_id, :id])
  end

  def down do
    drop_if_exists table(:trips)
    drop_if_exists table(:tracks)

  end
end
