defmodule Feed.Repo.Migrations.CreateStops do
  use Ecto.Migration

  def change do
    create table(:stops) do
      add :name, :string
      add :coords, :geography
      add :transport, :string
    end
  end
end
