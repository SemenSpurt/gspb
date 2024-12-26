defmodule Feed.Repo.Migrations.CreateCalendar do
  use Ecto.Migration

  def change do
    create table(:calendar) do
      add :monday, :boolean
      add :tuesday, :boolean
      add :wednesday, :boolean
      add :thursday, :boolean
      add :friday, :boolean
      add :saturday, :boolean
      add :sunday, :boolean
      add :start_date, :date
      add :end_date, :date
      add :name, :string

      timestamps(type: :utc_datetime)
    end
  end
end
