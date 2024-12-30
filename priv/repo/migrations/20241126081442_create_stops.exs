defmodule Feed.Repo.Migrations.CreateStops do
  use Ecto.Migration

  def change do
    create table(:stops) do
      add :name, :string
      add :coords, :geometry #{:map, :float}
      add :transport, :string
    end
  end
end
