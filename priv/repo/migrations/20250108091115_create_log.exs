defmodule Feed.Repo.Migrations.CreateLog do
  use Ecto.Migration

  def up do
    create_if_not_exists table(:vehicles, primary_key: false) do
      add :route_id, :string, primary_key: true
      add :vehicle_id, :integer
      add :order_number, :integer
      add :direction_id, :boolean
      add :vehicle_label, :string
      add :license_plate, :string
    end

    create_if_not_exists table(:positions, primary_key: false) do
      add :vehicle_id,
          references(:vehicles,
            type: :string,
            column: :route_id
          )

      add :timestamp, :naive_datetime
      add :order_number, :integer
      add :direction_id, :boolean
      add :position, :geography
      add :direction, :integer
      add :velocity, :integer
    end

    create_if_not_exists index(:vehicles, [:route_id, :vehicle_id, :order_number])
    create_if_not_exists index(:positions, [:vehicle_id, :timestamp, :position])
  end

  def down do
    # drop_if_exists table(:vehicles)
    # drop_if_exists table(:positions)
  end
end
