defmodule Feed.Services.Import.Trips do
  # """
  #   route_id:       integer
  #   service_id:     integer
  #   trip_id:        integer
  #   direction_id:   boolean
  #   shape_id:       string : может быть это поле доджно быть в routes?
  # """

  alias Feed.{
    Repo,
    Ecto.Trips.Trip
  }

  @file_path "C:/Users/SamJa/Desktop/Notebooks/feed/"

  def import_records(file_path \\ @file_path) do
    file_path <> "trips.txt"
    |> File.stream!()
    |> FileParser.parse_stream()
    |> Stream.map(fn [
                       route_id,
                       service_id,
                       id,
                       direction_id,
                       track_id
                     ] ->
      %{
        id: String.to_integer(id),
        route_id: String.to_integer(route_id),
        service_id: String.to_integer(service_id),
        direction_id: String.to_integer(direction_id) == 1,
        track_id: String.trim(track_id)
      }
    end)
    |> Stream.chunk_every(1000)
    |> Enum.each(&Repo.insert_all(Trip, &1))
  end
end
