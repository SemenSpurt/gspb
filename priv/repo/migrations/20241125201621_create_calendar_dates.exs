defmodule Feed.Repo.Migrations.CreateCalendarDates do
  use Ecto.Migration

  def change do
    create table(:calendar_dates) do
      add :service_id, :integer
      add :date,       :date
      add :exception,  :integer
    end
  end
end
