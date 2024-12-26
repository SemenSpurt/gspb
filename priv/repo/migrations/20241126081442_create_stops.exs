defmodule Feed.Repo.Migrations.CreateStops do
  use Ecto.Migration

  def change do
    create table(:stops) do
      add :name, :string
      add :coords, {:map, :float}
      add :transport, :string

      timestamps(type: :utc_datetime)
    end
  end
end
