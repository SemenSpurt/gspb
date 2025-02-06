defmodule Feed.Services.Import.Trip do
  alias Feed.{
    Repo,
    Ecto.Trip,
    Services.Research
  }

  def import(file_path, service_ids) do
    Research.Trips.records(file_path)
    |> Stream.filter(&(&1.service_id in service_ids))
    |> Stream.chunk_every(1000)
    |> Enum.map(
      &Repo.insert_all(Trip, &1,
        on_conflict: :replace_all,
        conflict_target: [
          :route_id,
          :trip_id,
          :direction_id
        ],
        returning: true
      )
    )
    |> Enum.flat_map(&elem(&1, 1))
    |> Enum.map(&[&1.route_id, &1.trip_id, &1.track_id])
    |> Enum.zip_with(&Enum.uniq(&1))
  end
end
