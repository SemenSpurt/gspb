defmodule FrequenciesParser do
  # """
  # trip_id:      integer,
  # start_time:   time,
  # end_time:     time,
  # headway_secs: integer,
  # exact_times:  integer  : drop
  # """

  @file_path "C:/Users/SamJa/Desktop/Notebooks/feed/frequencies.txt"

  def frequencies(file_path \\ @file_path) do
    file_path
    |> File.stream!()
    |> FileParser.parse_stream()
    |> Enum.map(
      fn [
        trip_id,
        start_time,
        end_time,
        headway_secs,
        _
      ] -> %{
        trip_id:      String.to_integer(trip_id),
        start_time:   Toolkit.time_from_seconds_after_midnight(start_time),
        end_time:     Toolkit.time_from_seconds_after_midnight(end_time),
        headway_secs: String.to_integer(headway_secs),
        # exact_times:  String.to_integer(exact_times)
      }
    end)
  end


  @doc "0) Как много записей в таблице frequencies?"
  def count_table_records, do: frequencies() |> Enum.count()
  # 106506


  @doc "1) Сколько уникальных значений trip_id?"
  def count_uniq_trip_id, do: frequencies() |> Toolkit.count_uniq_in(:trip_id)
  # 106506


  @doc "2) Какие значения принимает столбец start_time?"
  def start_time_frequencies, do: frequencies() |> Enum.frequencies_by(& &1.start_time)
  # %{
  #   ~T[06:00:00] => 25282,
  #   ~T[10:00:00] => 36859,
  #   ~T[16:00:00] => 25348,
  #   ~T[20:00:00] => 19017
  # }


  @doc "3) Какие значения принимает столбец end_time?"
  def end_time_frequencies, do: frequencies() |> Enum.frequencies_by(& &1.end_time)
  # %{
  #   ~T[00:00:00] => 19017,
  #   ~T[10:00:00] => 25282,
  #   ~T[16:00:00] => 36859,
  #   ~T[20:00:00] => 25348
  # }


  @doc "3.1) Есть ли такие строки для которых start_time > end_time?"
  def check_time_inconsistensy do
    frequencies()
    |> Enum.filter(& Time.compare(&1.start_time, &1.end_time) == :gt)
    |> Enum.count()
  end
  # 19017


  @doc "4) Сколько уникальных значений headway_secs?"
  def count_uniq_headway_secs, do: frequencies() |> Toolkit.count_uniq_in(:headway_secs)
  # 1001


  @doc "5) Какие значения принимает столбец exact_times?"
  def exact_time_frequencies, do: frequencies() |> Enum.frequencies_by(& &1.exact_times)
  # %{0 => 106506}


  @doc "6) Есть ли в таблице такие рейсы, которых нет в таблице trips?"
  def extra_records? do
    trips =
      TripParser.trips()
      |> MapSet.new(& &1.trip_id)

    frequencies()
    |> MapSet.new(& &1.trip_id)
    |> MapSet.difference(trips)
  end
  # MapSet.new([])

end
