defmodule Feed.Repo.Migrations.CreateFreqs do
  use Ecto.Migration

  def change do
    create table(:freqs) do
      add :trip_id, :integer
      add :start_time, :time
      add :end_time, :time
      add :headway_secs, :integer
      add :exact_times, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
