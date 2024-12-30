defmodule Feed.Services.Import.CalendarDates do
  # """
  # service_id:     integer,
  # date:           date, : удалить избыточные
  # exception_type: integer
  # """

  alias Feed.{
    Repo,
    Utils.Toolkit,
    Ecto.CalendarDates.CalendarDate
  }

  @file_path "C:/Users/SamJa/Desktop/Notebooks/feed/calendar_dates.txt"

  def import_records(file_path \\ @file_path) do
    file_path
    |> File.stream!()
    |> FileParser.parse_stream()
    |> Stream.map(fn [service_id, date, exception] ->
      %{
        service_id: String.to_integer(service_id),
        exception: String.to_integer(exception),
        date: Toolkit.date_from_reverse_string(date)
      }
    end)
    |> Stream.chunk_every(1000)
    |> Enum.each(&Repo.insert_all(CalendarDate, &1))
  end
end
