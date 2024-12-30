defmodule Feed.Repo.Migrations.CreateCalendar do
  use Ecto.Migration

  def change do
    create table(:calendar) do
      add :service_id, :integer
      add :start_date, :date
      add :end_date, :date
      add :name, :string
    end
  end
end
