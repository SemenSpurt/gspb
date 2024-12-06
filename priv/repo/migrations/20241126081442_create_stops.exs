defmodule Feed.Repo.Migrations.CreateStops do
  use Ecto.Migration

  def change do
    create table(:stops) do
      add :stop_id, :integer
      add :stop_code, :integer
      add :stop_name, :string
      add :stop_lat, :float
      add :stop_lon, :float
      add :location_type, :integer
      add :wheelchair_boarding, :integer
      add :transport_type, :string

      timestamps(type: :utc_datetime)
    end
  end
end
