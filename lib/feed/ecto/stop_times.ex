defmodule Feed.Ecto.StopTimes do
  import Ecto.Query, warn: false

  alias Feed.{
    Repo,
    Ecto.Stops.Stop,
    Ecto.Shapes.Stage
  }

  # defmodule CheckPoint do
  #   use Ecto.Schema

  #   embedded_schema do
  #   belongs_to :stop, Stop,
  #     foreign_key: :stop_id,
  #     references: :id

  #   field :stage_id, :string
  #   field :arrival_time, :time
  #   field :departure_time, :time
  #   field :stop_sequence, :integer

  #   has_many :stages, Stage,
  #     foreign_key: :stage_id,
  #     references: :stage_id,
  #     preload_order: [asc: :shape_pt_sequence]
  #   end
  # end

  defmodule StopTime do
    use Ecto.Schema
    import Ecto.Changeset

    schema "stop_times" do
      field :trip_id, :integer
      # embeds_many :check_points, CheckPoint

      belongs_to :stop, Stop,
        foreign_key: :stop_id,
        references: :id

      field :arrival_time, :time
      field :departure_time, :time
      field :stop_sequence, :integer
      field :stage_id, :string, defaults: nil
      field :shape_dist_traveled, :float

      has_many :stages, Stage,
        foreign_key: :stage_id,
        references: :stage_id,
        preload_order: [asc: :shape_pt_sequence]
    end

    def changeset(time, attrs) do
      time
      |> cast(
        attrs,
        [
          :trip_id,
          # :check_points
          :arrival_time,
          :departure_time,
          :stop_id,
          :stop_sequence,
          :stage_id,
          :shape_dist_traveled
        ]
      )
      |> validate_required([
        :trip_id,
        # :check_points,
        :arrival_time,
        :departure_time,
        :stop_id,
        :stop_sequence,
        :stage_id,
        :shape_dist_traveled
      ])
    end
  end

  def list_times do
    Repo.all(StopTime)
  end
end
