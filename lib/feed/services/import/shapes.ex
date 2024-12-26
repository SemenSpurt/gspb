defmodule Feed.Services.Import.Shapes do
  # """
  # shape_id:             string
  # shape_pt_lat:         float
  # shape_pt_lon:         float
  # shape_pt_sequence:    integer
  # shape_dist_traveled:  float
  # """

  alias Feed.Ecto.Shapes

  def import_records(file_path \\ "C:/Users/SamJa/Desktop/Notebooks/feed/shapes.txt") do
    file_path
    |> File.stream!()
    |> Stream.chunk_every(1000)
    |> Stream.map(
      &FileParser.parse_stream(&1)
      |> Enum.map(
      fn [
          shape_id,
          pt_lat,
          pt_lon,
          pt_sequence,
          dist_traveled
        ] -> %{
          shape_id: String.trim(shape_id),
          coords: [
            String.to_float(pt_lon),
            String.to_float(pt_lat)
          ],
          pt_sequence: String.to_integer(pt_sequence),
          dist_traveled: String.to_float(dist_traveled),

          inserted_at: DateTime.utc_now(:second),
          updated_at:  DateTime.utc_now(:second)
        } end
      )
      |> Shapes.import_records()
    )
    |> Stream.run()
  end
end
