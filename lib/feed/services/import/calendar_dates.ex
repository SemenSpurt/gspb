defmodule Feed.Services.Import.CalendarDates do
  # """
  # service_id:     integer,
  # date:           date, : удалить избыточные
  # exception_type: integer
  # """

  alias Feed.Services.Research.CalendarDates
  alias Feed.{
    Repo,
    Ecto.CalendarDates.CalendarDate
  }


  @file_path "C:/Users/SamJa/Desktop/Notebooks/feed/"

  def import_records(file_path \\ @file_path) do

    CalendarDates.records(file_path)
    |> Stream.chunk_every(1000)
    |> Enum.each(&Repo.insert_all(CalendarDate, &1))
  end
end
