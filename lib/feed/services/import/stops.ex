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

  alias Feed.Ecto.Stops

  def import_records(file_path \\ "C:/Users/SamJa/Desktop/Notebooks/feed/stops.txt") do
    file_path
    |> File.stream!()
    |> Stream.chunk_every(1000)
    |> Stream.map(
      &FileParser.parse_stream(&1)
      |> Enum.map(
        fn [
          id,
          _, # code
          name,
          lat,
          lon,
          _, # loc_type
          _, # chair_board
          transport
        ] -> %{
          id: String.to_integer(id),
          name: String.trim(name),
          coords: [
            String.to_float(lon),
            String.to_float(lat)
          ],
          transport: String.trim(transport),

          inserted_at: DateTime.utc_now(:second),
          updated_at:  DateTime.utc_now(:second)
        } end
      )
      |> Stops.import_records()
    )
    |> Stream.run()
  end



end
