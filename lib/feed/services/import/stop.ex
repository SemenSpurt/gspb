defmodule Feed.Services.Import.Stop do
  alias Feed.{
    Repo,
    Ecto.Stop,
    Services.Research
  }

  def import(file_path) do
    Research.Stops.records(file_path)
    |> Stream.chunk_every(1000)
    |> Enum.map(
      &Repo.insert_all(Stop, &1,
        returning: true,
        on_conflict: :replace_all,
        conflict_target: :stop_id
      )
    )
    |> Enum.flat_map(&elem(&1, 1))
    |> Enum.map(& &1.stop_id)
  end
end
