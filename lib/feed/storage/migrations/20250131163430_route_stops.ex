defmodule Feed.Storage.Migrations.RouteStops do
  use Ecto.Migration

  def up do
    create_if_not_exists table(:route_stops) do
      add :route_id, :integer
      add :direction, :boolean
      add :stop_num, :integer
      add :stop, :geography
    end

    create_if_not_exists unique_index(:route_stops, [:route_id, :direction, :stop_num])
  end
end
