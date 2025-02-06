defmodule Feed.Storage.Migrations.CreateCalendar do
  use Ecto.Migration

  def up do
    execute("CREATE EXTENSION IF NOT EXISTS postgis;")

    create_if_not_exists table(:calendar, primary_key: false) do
      add :service_id, :integer, primary_key: true
      add :start_date, :date
      add :end_date, :date
      add :monday, :boolean
      add :tuesday, :boolean
      add :wednesday, :boolean
      add :thursday, :boolean
      add :friday, :boolean
      add :saturday, :boolean
      add :sunday, :boolean
      add :name, :string
    end

    create_if_not_exists table(:calendar_dates) do
      add :service_id,
          references(:calendar,
            type: :integer,
            column: :service_id
          )

      add :date, :date
      add :exception, :integer
    end
  end

  def down do
    drop_if_exists table(:calendar_dates)
    drop_if_exists table(:calendar)
  end
end
