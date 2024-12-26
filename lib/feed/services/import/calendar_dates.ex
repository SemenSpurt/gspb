defmodule Feed.Services.Import.CalendarDates do
  # """
  # service_id:     integer,
  # date:           date, : удалить избыточные
  # exception_type: integer
  # """

  alias Feed.Ecto.CalendarDates

  @file_path "C:/Users/SamJa/Desktop/Notebooks/feed/calendar_dates.txt"

  def import_records(file_path \\ @file_path) do
    file_path
    |> File.stream!()
    |> Stream.chunk_every(1000)
    |> Stream.map(
      &FileParser.parse_stream(&1)
      |> Enum.map(
        fn [
          service_id,
          date,
          exception
        ] -> %{
          service_id:  String.to_integer(service_id),
          exception:   String.to_integer(exception),
          date:        Toolkit.date_from_reverse_string(date),

          inserted_at: DateTime.utc_now(:second),
          updated_at:  DateTime.utc_now(:second)
        } end
      )
      |> CalendarDates.import_records()
    )
    |> Stream.run()
  end
end
