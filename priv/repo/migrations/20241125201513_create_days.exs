defmodule Feed.Repo.Migrations.CreateDays do
  use Ecto.Migration

  def change do
    create table(:days) do
      add :service_id, :integer
      add :monday, :boolean, default: false, null: false
      add :tuesday, :boolean, default: false, null: false
      add :wednesday, :boolean, default: false, null: false
      add :thursday, :boolean, default: false, null: false
      add :friday, :boolean, default: false, null: false
      add :saturday, :boolean, default: false, null: false
      add :sunday, :boolean, default: false, null: false
      add :start_date, :date
      add :end_date, :date
      add :service_name, :string

      timestamps(type: :utc_datetime)
    end
  end
end
