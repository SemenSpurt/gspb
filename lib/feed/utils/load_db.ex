defmodule Feed.Utils.LoadDb do

  alias Feed.Services.Import.{
    Routes,
    Trips,
    Stops,
    Freqs,
    Shapes,
    Calendar,
    StopTimes,
    CalendarDates
  }

  def load_db do
    [
      Routes,
      Trips,
      Stops,
      Freqs,
      StopTimes,
      CalendarDates
    ]
    |> Enum.map(& &1.import_records())

    Shapes.import_stages()
    Shapes.import_tracks()
    Calendar.import_calendar()
    Calendar.import_week
  end


  # unzipped = File.ls!("src")
  #   |> Enum.map(&String.ends_with?(&1, ".txt"))
  #   |> Enum.any?

  # if not unzipped do
  #   :zip.unzip(~c"src/feed.zip", [{:cwd, ~c"src/feed"}])
  # end

  # Enum.each(tables, fn {model, path} ->
  #   records = File.cwd! <> path
  #   |> File.stream!()
  #   |> Stream.chunk_every(1000)
  #   |> Enum.map(&Parser.parse_stream(&1) |> model.import())

  # end)

  # File.ls!("src/feed")
  # |> Enum.filter(&String.ends_with?(&1, ".txt"))
  # |> Enum.map(&Path.expand(&1, "src/feed"))
  # |> Enum.map(&File.rm!(&1))
end
