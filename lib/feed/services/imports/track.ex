defmodule Feed.Services.Imports.Track do
  alias Feed.{
    Repo,
    Ecto,
    Services.Research
  }

  def import do
    Research.Shapes.records()
    |> Enum.filter(&String.starts_with?(&1.shape_id, "track-"))
    |> Enum.group_by(& &1.shape_id, & &1.coords)
    |> Enum.map(fn {k, v} ->
      %{
        track_id: k,
        line: %Geo.LineString{coordinates: v}
      }
    end)
    |> Enum.chunk_every(1000)
    |> Enum.map(
      &Repo.insert_all(
        Ecto.Shapes.Track,
        &1,
        on_conflict: :replace_all,
        conflict_target: :track_id,
        returning: true
      )
    )
    |> Enum.flat_map(&elem(&1, 1))
    |> Enum.map(& &1.track_id)
  end
end
