defmodule Feed.Storage.Migrations.CreateLog do
  use Ecto.Migration

  def up do
    create_if_not_exists table(:positions, primary_key: false) do
      add :vehicle_id, :integer, primary_key: true
      add :timestamp, :utc_datetime, primary_key: true
      add :position, :geography
      add :direction_id, :boolean
      add :order, :integer
      add :plate, :string
      add :label, :string
    end

    create_if_not_exists index(:positions, [
                           :vehicle_id,
                           :timestamp
                         ])
  end

  def down do
    # drop_if_exists table(:positions)
  end
end
