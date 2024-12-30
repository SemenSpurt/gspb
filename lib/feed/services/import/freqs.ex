defmodule Feed.Services.Import.Freqs do
  # """
  # trip_id:      integer,
  # start_time:   time,
  # end_time:     time,
  # headway_secs: integer,
  # exact_times:  integer  : drop
  # """

  alias Feed.{
    Repo,
    Utils.Toolkit,
    Ecto.Freqs.Freq
  }

  @file_path "C:/Users/SamJa/Desktop/Notebooks/feed/frequencies.txt"

  def import_records(file_path \\ @file_path) do
    file_path
    |> File.stream!()
    |> FileParser.parse_stream()
    |> Stream.map(fn [trip_id, start_time, end_time, headway_secs, _] ->
      %{
        trip_id: String.to_integer(trip_id),
        start_time: Toolkit.time_from_seconds_after_midnight(start_time),
        end_time: Toolkit.time_from_seconds_after_midnight(end_time),
        headway_secs: String.to_integer(headway_secs)
      }
    end)
    |> Stream.chunk_every(1000)
    |> Enum.each(&Repo.insert_all(Freq, &1))
  end
end
