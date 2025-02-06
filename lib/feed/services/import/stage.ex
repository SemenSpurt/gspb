defmodule Feed.Services.Import.Stage do
  alias Feed.{
    Repo,
    Ecto.Stage,
    Services.Research
  }

  def import(file_path) do
    Research.Shapes.records(file_path)
    |> Enum.filter(&String.starts_with?(&1.shape_id, "stage-"))
    |> Enum.group_by(& &1.shape_id, & &1.coords)
    |> Enum.map(fn {k, v} ->
      %{
        stage_id: k,
        line: %Geo.LineString{coordinates: v}
      }
    end)
    |> Enum.chunk_every(1000)
    |> Enum.map(
      &Repo.insert_all(Stage, &1,
        returning: true,
        on_conflict: :replace_all,
        conflict_target: :stage_id
      )
    )
    |> Enum.flat_map(&elem(&1, 1))
    |> Enum.map(& &1.stage_id)
  end
end
