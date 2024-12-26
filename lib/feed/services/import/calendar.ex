defmodule Feed.Services.Import.Calendar do
  # """
  # service_id:   integer,
  # monday:       integer,
  # tuesday:      integer,
  # wednesday:    integer,
  # thursday:     integer,
  # friday:       integer,
  # saturday:     integer,
  # sunday:       integer,
  # start_date:   date,
  # end_date:     date,
  # service_name: string
  # """

  alias Feed.Ecto.{
    Calendar
  }

  @file_path "C:/Users/SamJa/Desktop/Notebooks/feed/calendar.txt"

  def import_records(file_path \\ @file_path) do
    file_path
    |> File.stream!()
    |> Stream.chunk_every(1000)
    |> Stream.map(
      &FileParser.parse_stream(&1)
      |> Enum.map(
        fn [
          id,
          monday,
          tuesday,
          wednesday,
          thursday,
          friday,
          saturday,
          sunday,
          start_date,
          end_date,
          name
        ] -> %{
          id:   String.to_integer(id),
          start_date:   Toolkit.date_from_reverse_string(end_date),
          end_date:     Toolkit.date_from_reverse_string(start_date),
          monday:       String.to_integer(monday) == 1,
          tuesday:      String.to_integer(tuesday) == 1,
          wednesday:    String.to_integer(wednesday) == 1,
          thursday:     String.to_integer(thursday) == 1,
          friday:       String.to_integer(friday) == 1,
          saturday:     String.to_integer(saturday) == 1,
          sunday:       String.to_integer(sunday) == 1,
          name: String.trim(name),

          inserted_at: DateTime.utc_now(:second),
          updated_at:  DateTime.utc_now(:second)
        } end
      )
      |> Calendar.import_records()
    )
    |> Stream.run()
  end

end
