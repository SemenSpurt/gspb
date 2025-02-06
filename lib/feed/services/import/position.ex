defmodule Feed.Services.Import.Position do
  alias Feed.{
    Repo,
    Ecto.Position,
    Services.Research
  }

  def import(file_path) do
    Research.Positions.records(file_path)
    |> Stream.chunk_every(1000)
    |> Enum.each(
      &Repo.insert_all(Position, &1,
        on_conflict: :nothing,
        conflict_target: [
          :vehicle_id,
          :timestamp
        ]
      )
    )

    :ok
  end
end
