defmodule Feed.Repo.Migrations.CreateShapes do
  use Ecto.Migration

  def change do
    create table(:stages, primary_key: false) do
      add :stage_id, :string, primary_key: true
      add :line, :geography
    end

    create unique_index(:stages, [:stage_id])

    create table(:tracks, primary_key: false) do
      add :track_id, :string, primary_key: true
      add :line, :geography
    end

    create unique_index(:tracks, [:track_id])
  end
end
