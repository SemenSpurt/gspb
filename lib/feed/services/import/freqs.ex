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
    Ecto.Freqs.Freq,
    Services.Research.Frequencies
  }

  @file_path "C:/Users/SamJa/Desktop/Notebooks/feed/"

  def import_records(file_path \\ @file_path) do
    Frequencies.records(file_path)
    |> Stream.chunk_every(1000)
    |> Enum.each(&Repo.insert_all(Freq, &1))
  end
end
