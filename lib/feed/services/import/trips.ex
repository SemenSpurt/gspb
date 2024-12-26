defmodule Feed.Services.Import.Trips do
  # """
  #   route_id:       integer
  #   service_id:     integer
  #   trip_id:        integer
  #   direction_id:   boolean
  #   shape_id:       string : может быть это поле доджно быть в routes?
  # """

  alias Feed.Ecto.Trips

  def import_records(file_path \\ "C:/Users/SamJa/Desktop/Notebooks/feed/trips.txt") do
    file_path
    |> File.stream!()
    |> Stream.chunk_every(1000)
    |> Stream.map(
      &FileParser.parse_stream(&1)
      |> Enum.map(fn [
        route_id,
        service_id,
        id,
        direction_id,
        shape_id
        ] -> %{
          id:           String.to_integer(id),
          route_id:     String.to_integer(route_id),
          service_id:   String.to_integer(service_id),
          direction_id: String.to_integer(direction_id) == 1,
          shape_id:     String.trim(shape_id),

          inserted_at:  DateTime.utc_now(:second),
          updated_at:   DateTime.utc_now(:second)
        } end
      )
      |> Trips.import_records()
    )
    |> Stream.run()
  end

end
