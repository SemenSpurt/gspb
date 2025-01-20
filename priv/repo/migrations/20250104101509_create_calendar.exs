defmodule Feed.Repo.Migrations.CreateCalendar do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:week, primary_key: false) do
      add :name, :string, primary_key: true
      add :monday, :boolean
      add :tuesday, :boolean
      add :wednesday, :boolean
      add :thursday, :boolean
      add :friday, :boolean
      add :saturday, :boolean
      add :sunday, :boolean
    end

    create_if_not_exists table(:calendar, primary_key: false) do
      add :service_id, :integer, primary_key: true
      add :start_date, :date
      add :end_date, :date

      add :name,
          references(:week,
            type: :string,
            column: :name
          )
    end

    create_if_not_exists table(:calendar_dates, primary_key: false) do
      add :date, :date
      add :exception, :integer

      add :service_id,
          references(:calendar,
            type: :integer,
            column: :service_id
          )
    end
  end

  def down do
    drop_if_exists table(:calendar_dates)
    drop_if_exists table(:calendar)
    drop_if_exists table(:week)
  end
end
