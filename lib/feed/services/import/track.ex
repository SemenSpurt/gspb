defmodule Feed.Services.Import.Track do
  alias Feed.{
    Repo,
    Ecto.Track,
    Services.Research
  }

  def import(file_path, track_ids) do
    Research.Shapes.records(file_path)
    |> Stream.filter(
      &(String.starts_with?(&1.shape_id, "track-") and
          &1.shape_id in track_ids)
    )
    |> Enum.group_by(& &1.shape_id, & &1.coords)
    |> Enum.map(fn {k, v} ->
      %{
        track_id: k,
        line: %Geo.LineString{coordinates: v}
      }
    end)
    |> Enum.chunk_every(1000)
    |> Enum.each(
      &Repo.insert_all(Track, &1,
        on_conflict: :nothing,
        conflict_target: :track_id
      )
    )
  end
end
