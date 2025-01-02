defmodule Feed.Repo.Migrations.CreateWeek do
  use Ecto.Migration

  def change do
    create table(:week) do
      add :name, :string
      add :monday, :boolean
      add :tuesday, :boolean
      add :wednesday, :boolean
      add :thursday, :boolean
      add :friday, :boolean
      add :saturday, :boolean
      add :sunday, :boolean
    end
    create unique_index(:week, [:name])
  end

end
