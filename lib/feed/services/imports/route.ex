defmodule Feed.Services.Imports.Route do
  alias Feed.{
    Repo,
    Ecto,
    Services.Research
  }

  def import do
    Research.Routes.records()
    |> Enum.chunk_every(1000)
    |> Enum.map(
      &Repo.insert_all(
        Ecto.Routes.Route,
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
