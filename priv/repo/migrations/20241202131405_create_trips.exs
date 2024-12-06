defmodule Feed.Repo.Migrations.CreateTrips do
  use Ecto.Migration

  def change do
    create table(:trips) do
      add :route_id, :integer #references(:routes)
      add :service_id, :integer #references(:dates)
      add :trip_id, :integer
      add :direction_id, :boolean, default: false, null: false
      add :shape_id, :string

      timestamps(type: :utc_datetime)
    end
  end
end
