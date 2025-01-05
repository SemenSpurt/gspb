defmodule Feed.Repo.Migrations.CreateShapes do
  use Ecto.Migration

  def change do
    create table(:stages) do
      add :stage_id, :string, primary_key: true
      add :line, :geography
    end

    create table(:tracks) do
      add :track_id, :string, primary_key: true
      add :line, :geography
    end
  end
end
