defmodule Feed.Repo.Migrations.CreateCalendar do
  use Ecto.Migration

  def change do
    create table(:calendar, primary_key: false) do
      add :service_id, :integer, primary_key: true
      add :start_date, :date
      add :end_date, :date
      add :name, :string
    end

    create table(:week) do
      add :name, :string, primary_key: true
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
