defmodule Feed.Repo.Migrations.CreateTrips do
  use Ecto.Migration

  def change do
    create table(:trips) do
      add :route_id, :integer
      add :service_id, :integer
      add :direction_id, :boolean
      add :shape_id, :string

      timestamps(type: :utc_datetime)
    end
  end
end
