defmodule Feed.Services.Research.StopTimes do
  # """
  # trip_id:              integer,
  # arrival_time:         time,
  # departure_time:       time,
  # stop_id:              integer,
  # stop_sequence:        integer,
  # shape_id:             string,
  # shape_dist_traveled:  float :drop
  # """

  alias Feed.Services.{
    Toolkit,
    Research.Stops
  }

  @file_path "src/feed"

  def records(file_path \\ @file_path) do
    Path.expand("stop_times.txt", file_path)
    |> File.stream!()
    |> FileParser.parse_stream()
    |> Enum.map(fn [
                     trip_id,
                     arrival_time,
                     departure_time,
                     stop_id,
                     stop_sequence,
                     stage_id,
                     shape_dist_traveled
                   ] ->
      %{
        trip_id: String.to_integer(trip_id),
        arrival_time: Toolkit.time_from_seconds_after_midnight(arrival_time),
        departure_time: Toolkit.time_from_seconds_after_midnight(departure_time),
        stop_id: String.to_integer(stop_id),
        stop_sequence: String.to_integer(stop_sequence),
        stage_id: String.trim(stage_id),
        shape_dist_traveled: String.to_float(shape_dist_traveled)
      }
    end)
  end

  @doc "0) Как много записей в таблице stop_times?"
  def count_table_records, do: records() |> Enum.count()
  # 3387319

  @doc "1) Сколько всего уникальных stop_id?"
  def count_uniq_stop_id, do: records() |> Toolkit.count_uniq_in(:stop_id)
  # 8557

  @doc "1.1) Есть ли в этой таблице stop_id, которых нет в таблице stops?"
  def are_there_stop_ids_missed_in_stops_table? do
    stops =
      Stops.records()
      |> MapSet.new(& &1.stop_id)

    records()
    |> Enum.any?(&(&1.stop_id not in stops))
  end

  # false

  @doc "2) Есть ли записи, у которых arrival_time не совпадает с departure_time?"
  def different_arrival_departure_times do
    records()
    |> Enum.filter(&(&1.arrival_time > &1.departure_time))
  end

  # . . . yep

  @doc "2.1) Сколько таких записей?"
  def different_arrival_departure_times_count do
    different_arrival_departure_times() |> Enum.count()
  end

  # 54010

  @doc "3) Сколько всего уникальных trip_id?"
  def count_uniq_trip_id, do: records() |> Toolkit.count_uniq_in(:trip_id)
  # 120300

  @doc "4) Сколько всего уникальных shape_id?"
  def count_uniq_shape_id, do: records() |> Enum.uniq_by(& &1.shape_id) |> Enum.count()
  # 27339

  def check_stop_sequence_order do
    records()
    |> Enum.group_by(& &1.trip_id, & &1.stop_sequence)
    |> Enum.map(fn {k, v} ->
      {k,
       v
       |> Enum.chunk_every(2, 1, :discard)
       |> Enum.map(fn [a, b] -> b - a == 1 end)
       |> Enum.all?()}
    end)
    |> Enum.map(&elem(&1, 1))
    |> Enum.all?()
  end

  # true

  def groupby_trips_stops do
    records()
    |> Enum.group_by(
      & &1.trip_id,
      &%{
        stop_id: &1.stop_id,
        arrival: &1.arrival_time,
        departure: &1.departure_time,
        index: &1.stop_sequence
      }
    )
  end

  def groupby_trips_stops1 do
    records()
    |> Enum.group_by(
      & &1.stop_id,
      &%{
        trip_id: &1.trip_id,
        arrival: &1.arrival_time,
        departure: &1.departure_time,
        index: &1.stop_sequence
      }
    )
  end

  @doc "Check arrival : departure time"
  def arrival_to_departure do
    records()
    |> Enum.filter(&(Time.diff(&1.departure_time, &1.arrival_time) >= 0))
  end
end
