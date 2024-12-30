defmodule Feed.Services.Import.Shapes do
  # """
  # shape_id:             string
  # shape_pt_lat:         float
  # shape_pt_lon:         float
  # shape_pt_sequence:    integer
  # shape_dist_traveled:  float
  # """

  alias Feed.{
    Repo,
    Ecto.Shapes.Stage,
    Ecto.Shapes.Track
  }

  @file_path "C:/Users/SamJa/Desktop/Notebooks/feed/shapes.txt"

  def import_stages(file_path \\ @file_path) do
    file_path
    |> File.stream!()
    |> FileParser.parse_stream()
    |> Stream.map(fn [stage_id, pt_lat, pt_lon, _, _] ->
      %{
        stage_id: String.trim(stage_id),
        coords: {
          String.to_float(pt_lon),
          String.to_float(pt_lat)
        }
        # pt_sequence: String.to_integer(pt_sequence),
        # dist_traveled: String.to_float(dist_traveled)
      }
    end)
    |> Stream.filter(&(&1.stage_id |> String.starts_with?("stage")))
    |> Enum.group_by(& &1.stage_id, & &1.coords)
    |> Enum.map(fn {k, v} ->
      %{
        stage_id: k,
        line: %Geo.LineString{coordinates: v}
      }
    end)
    |> Enum.chunk_every(1000)
    |> Enum.each(&Repo.insert_all(Stage, &1))
  end

  def import_tracks(file_path \\ @file_path) do
    file_path
    |> File.stream!()
    |> FileParser.parse_stream()
    |> Stream.map(fn [track_id, pt_lat, pt_lon, _, _] ->
      %{
        track_id: String.trim(track_id),
        coords: {
          String.to_float(pt_lon),
          String.to_float(pt_lat)
        }
        # pt_sequence: String.to_integer(pt_sequence),
        # dist_traveled: String.to_float(dist_traveled)
      }
    end)
    |> Stream.filter(&(&1.track_id |> String.starts_with?("track")))
    |> Enum.group_by(& &1.track_id, & &1.coords)
    |> Enum.map(fn {k, v} ->
      %{
        track_id: k,
        line: %Geo.LineString{coordinates: v}
      }
    end)
    |> Enum.chunk_every(1000)
    |> Enum.each(&Repo.insert_all(Track, &1))
  end
end
