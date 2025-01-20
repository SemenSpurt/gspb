defmodule Feed.Services.Imports.StopTime do
  alias Feed.{
    Repo,
    Ecto,
    Services.Research
  }

  def import(trip_ids, stop_ids) do
    Research.StopTimes.records()
    |> Enum.filter(
      &(&1.trip_id in trip_ids and
          &1.stop_id in stop_ids)
    )
    |> Enum.chunk_every(1000)
    |> Enum.map(
      &Repo.insert_all(
        Ecto.StopTimes.StopTime,
        &1,
        on_conflict: :nothing,
        returning: false
      )
    )

    # |> Enum.flat_map(&elem(&1, 1))
    # |> Enum.map(&[&1.stop_id, &1.stage_id])
    # |> Enum.zip_with(&Enum.uniq(&1))
  end
end
