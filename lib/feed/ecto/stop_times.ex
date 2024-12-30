defmodule Feed.Ecto.StopTimes do
  import Ecto.Query, warn: false

  alias Feed.{
    Repo,
    Ecto.Stops.Stop,
    Ecto.Shapes.Shape
  }

  defmodule StopTime do
    use Ecto.Schema
    import Ecto.Changeset

    schema "stop_times" do
      belongs_to :stop, Stop,
        foreign_key: :stop_id,
        references: :id

      field :trip_id, :integer
      # field :stop_times, Ecto.Enum,
      #   values: [
      #     arrival_time: :time,
      #     departure_time: :time,
      #     stop_sequence: :integer,
      #     shape_id: :string,
      #     shape_dist_traveled: :float
      #   ]

      field :arrival_time, :time
      field :departure_time, :time
      field :stop_sequence, :integer
      field :shape_id, :string, defaults: nil
      field :shape_dist_traveled, :float

      has_many :stages, Stage,
        foreign_key: :stage_id,
        references: :shape_id,
        preload_order: [asc: :shape_pt_sequence]
    end

    def changeset(time, attrs) do
      time
      |> cast(
        attrs,
        [
          :trip_id,
          :arrival_time,
          :departure_time,
          :stop_id,
          :stop_sequence,
          :shape_id,
          :shape_dist_traveled
        ]
      )
      |> validate_required([
        :trip_id,
        :arrival_time,
        :departure_time,
        :stop_id,
        :stop_sequence,
        :shape_id,
        :shape_dist_traveled
      ])
    end
  end

  def list_times do
    Repo.all(StopTime)
  end
end
