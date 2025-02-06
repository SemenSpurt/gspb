defmodule Feed.Services.Import.Route do
  alias Feed.{
    Repo,
    Ecto.Route,
    Services.Research
  }

  def import(file_path, route_ids) do
    Research.Routes.records(file_path)
    |> Stream.filter(&(&1.route_id in route_ids))
    |> Stream.chunk_every(1000)
    |> Enum.map(
      &Repo.insert_all(Route, &1,
        returning: true,
        on_conflict: :replace_all,
        conflict_target: :route_id
      )
    )
    |> Enum.flat_map(&elem(&1, 1))
    |> Enum.map(& &1.route_id)
  end
end
