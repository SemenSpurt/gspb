defmodule Feed.Services.Import.Stops do
  # """
  #   stop_id:              integer,
  #   stop_code:            integer, # drop
  #   stop_name:            string,
  #   stop_lat:             float,
  #   stop_lon:             float,
  #   location_type:        integer, # drop
  #   wheelchair_boarding:  integer, # drop
  #   transport_type:       string
  # """

  alias Feed.{
    Repo,
    Ecto.Stops.Stop
  }

  @path_file "C:/Users/SamJa/Desktop/Notebooks/feed/"

  def import_records(file_path \\ @path_file) do
    file_path <> "stops.txt"
    |> File.stream!()
    |> FileParser.parse_stream()
    |> Stream.map(fn [id, _, name, lat, lon, _, _, transport] ->
      %{
        id: String.to_integer(id),
        name: String.trim(name),
        coords: %Geo.Point{
          coordinates: {
            String.to_float(lon),
            String.to_float(lat)
          }
        },
        transport: String.trim(transport)
      }
    end)
    |> Stream.chunk_every(1000)
    |> Enum.each(&Repo.insert_all(Stop, &1))
  end
end
