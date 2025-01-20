defmodule Feed.Services.Imports.Week do
  alias Feed.{
    Repo,
    Ecto,
    Services.Toolkit,
    Services.Research
  }

  def import(date) do
    weekday =
      Toolkit.weekday_atom_from_date(date)

    Research.Calendar.records()
    |> Enum.map(
      &Map.take(&1, [
        :monday,
        :tuesday,
        :wednesday,
        :thursday,
        :friday,
        :saturday,
        :sunday,
        :name
      ])
    )
    |> Enum.uniq_by(& &1.name)
    |> Enum.filter(& &1[weekday])
    |> Enum.chunk_every(1)
    |> Enum.map(
      &Repo.insert_all(
        Ecto.Calendar.Week,
        &1,
        on_conflict: :replace_all,
        conflict_target: :name,
        returning: true
      )
    )
    |> Enum.flat_map(&elem(&1, 1))
    |> Enum.map(& &1.name)
  end
end
