defmodule Feed.Ecto.Shapes do
  import Ecto.Query, warn: false
  alias Feed.Repo

  defmodule Stage do
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key {:stage_id, :string, autogenerate: false}
    schema "stages" do
      field :line, Geo.PostGIS.Geometry
    end

    def changeset(stage, attrs) do
      stage
      |> cast(
        attrs,
        [
          :stage_id,
          :line
        ]
      )
      |> validate_required([
        :stage_id,
        :line
      ])
    end
  end

  def list_stages do
    Repo.all(Stage)
  end

  defmodule Track do
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key {:track_id, :string, autogenerate: false}
    schema "tracks" do
      field :line, Geo.PostGIS.Geometry
    end

    def changeset(track, attrs) do
      track
      |> cast(
        attrs,
        [
          :track_id,
          :line
        ]
      )
      |> validate_required([
        :track_id,
        :line
      ])
    end
  end

  def list_tracks do
    Repo.all(Track)
  end
end
