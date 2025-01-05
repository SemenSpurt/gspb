defmodule Feed.Repo.Migrations.ExtendPostgis do
  use Ecto.Migration

  def change do
    execute("CREATE EXTENSION IF NOT EXISTS postgis;")
    execute("ALTER EXTENSION postgis UPDATE;")
  end
end
