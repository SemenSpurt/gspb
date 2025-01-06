defmodule Feed.Repo.Migrations.ExtendPostgis do
  use Ecto.Migration

  def up do
    execute("CREATE EXTENSION IF NOT EXISTS postgis;")
  end

  def down do
  end
end
