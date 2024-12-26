defmodule Feed.Services.Import.Freqs do
  # """
  # trip_id:      integer,
  # start_time:   time,
  # end_time:     time,
  # headway_secs: integer,
  # exact_times:  integer  : drop
  # """

  alias Feed.Ecto.Freqs

  def import_records(file_path \\ "C:/Users/SamJa/Desktop/Notebooks/feed/frequencies.txt") do
    file_path
    |> File.stream!()
    |> Stream.chunk_every(1000)
    |> Stream.map(
      &FileParser.parse_stream(&1)
      |> Enum.map(
        fn [
          trip_id,
          start_time,
          end_time,
          headway_secs,
          _
        ] -> %{
          trip_id:      String.to_integer(trip_id),
          start_time:   Toolkit.time_from_seconds_after_midnight(start_time),
          end_time:     Toolkit.time_from_seconds_after_midnight(end_time),
          headway_secs: String.to_integer(headway_secs),

          inserted_at: DateTime.utc_now(:second),
          updated_at:  DateTime.utc_now(:second)
        } end )
      |> Freqs.import_records()
    )
    |> Stream.run()
  end

end
