defmodule Feed.Utils.Toolkit do

  @doc "Steam file, parse it and map types"
  def uniparse(file_path, parse_func) do
    file_path
    |> File.stream!()
    |> FileParser.parse_stream()
    |> Enum.map(parse_func)
  end

  @doc "Count unique values in table column"
  def count_uniq_in(table, column) do
    table
    |> Enum.uniq_by(& &1[column])
    |> Enum.count()
  end

  @doc "Get time from values greater then 24 hours"
  def time_from_seconds_after_midnight(time_str) do
    [hr, min, sec] =
      time_str
      |> String.split(":")
      |> Enum.map(&String.to_integer/1)

    Time.from_seconds_after_midnight(hr * 3600 + min * 60 + sec)
  end

  @doc "Parse date from string in 'YYYYMMDD' format"
  def date_from_reverse_string(date_string) do
    Enum.at(
      for(
        <<
          y::binary-size(4),
          m::binary-size(2),
          d::binary-size(2) <- date_string
        >>,
        do: "#{y}-#{m}-#{d}"
      ),
      0
    )
    |> Date.from_iso8601!()
  end

  @doc "Goejson.io string tamplete"
  def geojson_string(coords \\ []) do
    %{
      type: "FeatureCollection",
      features: [
        %{
          type: "Feature",
          geometry: %{
            type: "MultiPoint",
            coordinates: coords
          },
          properties: %{}
        }
      ]
    }
    |> Jason.encode!()
  end

  def dist_between_points(coords) do
    earth_radius = 6_371_210
    uno_degree = Math.pi() / 180

    [
      [lat1, lon1],
      [lat2, lon2]
    ] =
      coords
      |> Enum.map(&Enum.map(&1, fn x -> x * uno_degree end))

    dlat = lat2 - lat1
    dlon = lon2 - lon1

    a =
      Math.sin(dlat / 2) ** 2 +
        Math.cos(lat1) *
          Math.cos(lat2) *
          Math.sin(dlon / 2) ** 2

    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))

    earth_radius * c
  end

  def remove_tables(zip_file_path \\ "src/feed") do
    File.ls!(zip_file_path)
    |> Enum.filter(&String.ends_with?(&1, ".txt"))
    |> Enum.map(&Path.expand(&1, zip_file_path))
    |> Enum.map(&File.rm!(&1))
  end

  @doc "unzip feed.zip file by filepath"
  def unpack_feed(zip_file_path \\ "src/feed") do
    remove_tables(zip_file_path)

    :zip.unzip(
      ~c"src/feed.zip",
      [{:cwd, ~c"src/feed"}]
    )

    remove_tables(zip_file_path)
  end
end
