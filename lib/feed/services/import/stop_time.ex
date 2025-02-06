defmodule Feed.Services.Import.StopTime do
  alias Feed.{
    Repo,
    Ecto.StopTime,
    Services.Research
  }

  def import(file_path, trip_ids, stop_ids) do
    Research.StopTimes.records(file_path)
    |> Stream.filter(&(&1.trip_id in trip_ids and &1.stop_id in stop_ids))
    |> Stream.chunk_every(1000)
    |> Enum.map(
      &Repo.insert_all(StopTime, &1,
        on_conflict: :nothing,
        conflict_target: [
          :trip_id,
          :stop_sequence
        ]
      )
    )
  end
end
