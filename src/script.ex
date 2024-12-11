alias Feed.Routes.Route
alias Feed.Trips.Trip
alias Feed.Stops.Stop
alias Feed.Shapes.Shape
alias Feed.Dates.Date
alias Feed.Freqs.Freq
alias Feed.Times.Time
alias Feed.Week.Days

defmodule LoadDatabase do
  alias CSV
  def get_Records(filepath) do
    File.stream!(filepath, read_ahead: 0)
    |> CSV.decode!(headers: true)
    # |> Enum.fetch!(0)
    # |> Map.keys()
  end

  tables = %{
    Route => "./routes.txt"
  }
end

unzipped = File.ls!
|> Enum.map(&String.ends_with?(&1, ".txt"))
|> Enum.any?

if not unzipped do
  :zip.unzip(~c"./feed.zip", [{:cwd, ~c"./"}])
end

File.ls!
|> Enum.filter(&String.ends_with?(&1, ".txt"))
|> Enum.map(&Path.expand(&1, __DIR__))
|> Enum.map(&LoadDatabase.get_headers(&1))
|> Enum.map(&Enum.join(&1, " "))
|> Enum.map(&IO.puts(&1))


File.ls!
|> Enum.filter(&String.ends_with?(&1, ".txt"))
|> Enum.map(&Path.expand(&1, __DIR__))
|> Enum.map(&File.rm!(&1))
