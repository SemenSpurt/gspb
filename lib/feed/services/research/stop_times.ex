defmodule StopTimesParser do
  # """
  # trip_id:              integer,
  # arrival_time:         time,
  # departure_time:       time,
  # stop_id:              integer,
  # stop_sequence:        integer,
  # shape_id:             string,
  # shape_dist_traveled:  float
  # """

  @file_path "C:/Users/SamJa/Desktop/Notebooks/feed/stop_times.txt"

  def stop_times(file_path \\ @file_path) do
    file_path
    |> File.stream!()
    |> FileParser.parse_stream()
    |> Enum.map(
      fn [
        trip_id,
        arrival_time,
        departure_time,
        stop_id,
        stop_sequence,
        shape_id,
        shape_dist_traveled
      ] -> %{
        trip_id:             String.to_integer(trip_id),
        arrival_time:        Toolkit.time_from_seconds_after_midnight(arrival_time),
        departure_time:      Toolkit.time_from_seconds_after_midnight(departure_time),
        stop_id:             String.to_integer(stop_id),
        stop_sequence:       String.to_integer(stop_sequence),
        shape_id:            String.trim(shape_id),
        shape_dist_traveled: String.to_float(shape_dist_traveled)
      } end
    )
  end


  @doc "0) Как много записей в таблице stop_times?"
  def count_table_records, do: stop_times() |> Enum.count()
  # 3387319


  @doc "1) Сколько всего уникальных stop_id?"
  def count_uniq_stop_id, do: stop_times() |> Toolkit.count_uniq_in(:stop_id)
  # 8557


  @doc "1.1) Есть ли в этой таблице stop_id, которых нет в таблице stops?"
  def are_there_stop_ids_missed_in_stops_table? do
    stops =
      StopParser.stops()
      |> Enum.map(& &1.id)

    stop_times()
    |> Enum.any?(& &1.stop_id not in stops)
  end
  # false
  # сделать лучше


  @doc "2) Есть ли записи, у которых arrival_time не совпадает с departure_time?"
  def different_arrival_departure_times do
    stop_times()
    |> Enum.filter(& &1.arrival_time != &1.departure_time)
  end
  # . . . yep


  @doc "2.1) Сколько таких записей?"
  def different_arrival_departure_times_count do
    different_arrival_departure_times() |> Enum.count()
  end
  # 54010


  @doc "3) Сколько всего уникальных trip_id?"
  def count_uniq_trip_id, do: stop_times() |> Toolkit.count_uniq_in(:trip_id)
  # 120300


  @doc "4) Сколько всего уникальных shape_id?"
  def count_uniq_shape_id, do: stop_times() |> Enum.uniq_by(& &1.shape_id) |> Enum.count()
  # 27339


end
