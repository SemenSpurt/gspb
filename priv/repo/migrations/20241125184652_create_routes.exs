defmodule Feed.Repo.Migrations.CreateRoutes do
  use Ecto.Migration

  def change do
    create table(:routes) do
      add :short_name, :string
      add :long_name, :string
      add :transport, :string
      add :circular, :boolean
      add :urban, :boolean
    end
    execute("CREATE EXTENSION IF NOT EXISTS postgis")
  end
end
