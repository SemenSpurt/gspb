defmodule FrequenciesParser do
  alias FileParser
  alias Toolkit

  # """
  # trip_id:      integer,
  # start_time:   time,
  # end_time:     time,
  # headway_secs: integer,
  # exact_times:  integer
  # """

  def frequencies(file_path \\ "C:/Users/SamJa/Desktop/Notebooks/feed/frequencies.txt") do
    file_path
    |> File.stream!()
    |> FileParser.parse_stream()
    |> Enum.map(
      fn [
        trip_id,
        start_time,
        end_time,
        headway_secs,
        exact_times
      ] -> %{
        trip_id:      String.to_integer(trip_id),
        start_time:   Toolkit.time_from_seconds_after_midnight(start_time),
        end_time:     Toolkit.time_from_seconds_after_midnight(end_time),
        headway_secs: String.to_integer(headway_secs),
        exact_times:  String.to_integer(exact_times)
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
  def start_time_frequencies, do: frequencies() |> Toolkit.frequencies_in(:start_time)
  # %{
  #   ~T[06:00:00] => 25282,
  #   ~T[10:00:00] => 36859,
  #   ~T[16:00:00] => 25348,
  #   ~T[20:00:00] => 19017
  # }


  @doc "3) Какие значения принимает столбец end_time?"
  def end_time_frequencies, do: frequencies() |> Toolkit.frequencies_in(:end_time)
  # %{
  #   ~T[00:00:00] => 19017,
  #   ~T[10:00:00] => 25282,
  #   ~T[16:00:00] => 36859,
  #   ~T[20:00:00] => 25348
  # }


  @doc "4) Сколько уникальных значений headway_secs?"
  def count_uniq_headway_secs, do: frequencies() |> Toolkit.count_uniq_in(:headway_secs)
  # 1001


  @doc "4) Нет ли пропущенных или лишних pt_sequence?"
  def check_headway_secs_consistency do

    freqs =
      frequencies()
      |> Enum.frequencies_by(& &1.headway_secs)
      |> Enum.sort_by(&elem(&1, 1), :desc)

    len = Enum.count(freqs)

    [
      Enum.slice(freqs, 0, len - 1),
      Enum.slice(freqs, -len + 1, len),
    ]
    |> Enum.zip_with(fn [a, b] -> not (a >= b) end)
    |> Enum.any?()

  end


end
