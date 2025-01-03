defmodule Feed.Services.Import.StopTimes do
  # """
  # trip_id:              integer,
  # arrival_time:         time,
  # departure_time:       time,
  # stop_id:              integer,
  # stop_sequence:        integer,
  # shape_id:             string,
  # shape_dist_traveled:  float
  # """

  alias Feed.{
    Repo,
    Utils.Toolkit,
    Ecto.StopTimes.StopTime
  }

  @file_path "C:/Users/SamJa/Desktop/Notebooks/feed/stop_times.txt"

  def import_records(file_path \\ @file_path) do
    file_path
    |> File.stream!()
    |> FileParser.parse_stream()
    |> Stream.map(fn [
                       trip_id,
                       arrival_time,
                       departure_time,
                       stop_id,
                       stop_sequence,
                       shape_id,
                       shape_dist_traveled
                     ] ->
      %{
        trip_id: String.to_integer(trip_id),
        arrival_time: Toolkit.time_from_seconds_after_midnight(arrival_time),
        departure_time: Toolkit.time_from_seconds_after_midnight(departure_time),
        stop_id: String.to_integer(stop_id),
        stop_sequence: String.to_integer(stop_sequence),
        shape_id: String.trim(shape_id),
        shape_dist_traveled: String.to_float(shape_dist_traveled)
      }
    end)
    # |> Enum.group_by(
    #   & &1.trip_id,
    #   & %StopTime.CheckPoint{
    #     stop_id: &1.stop_id,
    #     stop_sequence: &1.stop_sequence,
    #     arrival_time: &1.arrival_time,
    #     departure_time: &1.departure_time,
    #     shape_id: &1.shape_id
    #   }
    # )
    # |> Enum.map(fn {k, v} ->
    #   %{
    #     trip_id: k,
    #     check_points: v
    #   }
    # end)
    |> Enum.chunk_every(1000)
    |> Enum.each(&Repo.insert_all(StopTime, &1))
  end
end
