defmodule Feed.Repo.Migrations.CrateTracks do
  use Ecto.Migration

  def change do
    create table(:tracks) do
      add :track_id, :string, primary_key: true
      add :line, :geography
    end
  end
end
