defmodule Feed.Repo.Migrations.CreateStopTimes do
  use Ecto.Migration

  def up do
    create_if_not_exists table(:stops) do
      add :name, :string
      add :coords, :geography
      add :transport, :string
    end

    create_if_not_exists table(:stages, primary_key: false) do
      add :stage_id, :string, primary_key: true
      add :line, :geography
    end

    create_if_not_exists table(:stop_times) do
      add :trip_id,
          references(:trips,
            type: :integer,
            on_delete: :delete_all
          )

      add :stage_id, :string
      # add :stage_id,
      #     references(:stages,
      #       type: :string,
      #       column: :stage_id,
      #       on_delete: :delete_all
      #     )

      add :stop_id,
          references(:stops,
            type: :integer,
            on_delete: :delete_all
          )

      add :arrival_time, :time
      add :departure_time, :time
      add :stop_sequence, :integer
      add :shape_dist_traveled, :float
    end

    create_if_not_exists index(:stop_times, [:stop_id])
    create_if_not_exists index(:stop_times, [:trip_id, :stop_sequence])
  end

  def down do
    drop_if_exists table(:stop_times)
    drop_if_exists table(:stages)
    drop_if_exists table(:stops)
  end
end
