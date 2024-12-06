defmodule Feed.Repo.Migrations.CreateRoutes do
  use Ecto.Migration

  def change do
    create table(:routes) do
      add :route_id, :integer
      add :agency_id, :string
      add :route_short_name, :string
      add :route_long_name, :string
      add :route_type, :integer
      add :transport_type, :string
      add :circular, :boolean, default: false, null: false
      add :urban, :boolean, default: false, null: false
      add :night, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
