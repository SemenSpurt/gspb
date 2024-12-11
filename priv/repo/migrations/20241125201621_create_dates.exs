defmodule Feed.Repo.Migrations.CreateDates do
  use Ecto.Migration

  def change do
    create table(:dates) do
      add :service_id, :integer
      add :date, :date
      add :exception_type, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
