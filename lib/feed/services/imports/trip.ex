defmodule Feed.Services.Imports.Trips do
  alias Feed.{
    Repo,
    Ecto,
    Services.Research.Trips
  }

  def import(service_ids, route_ids, track_ids) do
    Trips.records()
    |> Enum.filter(& &1.service_id in service_ids)
    |> Enum.filter(& &1.route_id in route_ids)
    |> Enum.filter(& &1.track_id in track_ids)
    |> Enum.chunk_every(1000)
    |> Enum.map(
      &Repo.insert_all(
        Ecto.Trips.Trip,
        &1,
        on_conflict: :replace_all,
        conflict_target: :id,
        returning: true
      )
    )
    |> Enum.flat_map(&elem(&1, 1))
    |> Enum.map(& &1.id)
  end
end
