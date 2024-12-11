
alias Feed.Route.{
  Routes,
  Trips
}
alias Feed.Place.{
  Stops,
  Shapes
}

alias Feed.Time.{
  Dates,
  Freqs,
  Week,
  Times
}


NimbleCSV.define(Parser, separator: ",", escape: "\"")


tables = [
  {Dates, "/src/feed/calendar_dates.txt"},
  {Freqs, "/src/feed/frequencies.txt"},
  {Times, "/src/feed/stop_times.txt"},
  {Routes, "/src/feed/routes.txt"},
  {Shapes, "/src/feed/shapes.txt"},
  {Week, "/src/feed/calendar.txt"},
  {Trips, "/src/feed/trips.txt"},
  {Stops, "/src/feed/stops.txt"},
]

unzipped = File.ls!("src")
  |> Enum.map(&String.ends_with?(&1, ".txt"))
  |> Enum.any?

if not unzipped do
  :zip.unzip(~c"src/feed.zip", [{:cwd, ~c"src/feed"}])
end

Enum.each(tables, fn {model, path} ->
  records = File.cwd! <> path
  |> File.stream!()
  |> Stream.chunk_every(1000)
  |> Enum.map(&Parser.parse_stream(&1) |> model.import())

end)

File.ls!("src/feed")
|> Enum.filter(&String.ends_with?(&1, ".txt"))
|> Enum.map(&Path.expand(&1, "src/feed"))
|> Enum.map(&File.rm!(&1))
