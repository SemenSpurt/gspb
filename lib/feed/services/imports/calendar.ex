defmodule Feed.Services.Imports.Calendar do
  alias Feed.{
    Repo,
    Ecto,
    Services.Research.Calendar
  }

  def import(calendar_names) do
    Calendar.records()
    |> Enum.map(
      &Map.take(&1, [
        :service_id,
        :start_date,
        :end_date,
        :name
      ])
    )
    |> Enum.filter(& &1.name in calendar_names)
    |> Enum.chunk_every(1000)
    |> Enum.map(
      &Repo.insert_all(
        Ecto.Calendar.Calendar,
        &1,
        on_conflict: :replace_all,
        conflict_target: :service_id,
        returning: true
      )
    )
    |> Enum.flat_map(&elem(&1, 1))
    |> Enum.map(& &1.service_id)
  end
end
