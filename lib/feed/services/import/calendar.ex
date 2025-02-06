defmodule Feed.Services.Import.Calendar do
  alias Feed.Services.Toolkit

  alias Feed.{
    Repo,
    Ecto.Calendar,
    Services.Research
  }

  def import(file_path, prefix) do
    weekday = Toolkit.str_to_weekday(prefix)

    Research.Calendar.records(file_path)
    |> Stream.filter(& &1[weekday])
    |> Stream.chunk_every(1000)
    |> Enum.map(
      &Repo.insert_all(Calendar, &1,
        returning: true,
        on_conflict: :replace_all,
        conflict_target: :service_id
      )
    )
    |> Enum.flat_map(&elem(&1, 1))
    |> Enum.map(& &1.service_id)
  end
end
