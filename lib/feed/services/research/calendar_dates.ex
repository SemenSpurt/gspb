defmodule Feed.Services.Research.CalendarDates do
  # """
  # service_id:     integer,
  # date:           date, : удалить избыточные
  # exception_type: integer
  # """

  alias Feed.Services.{
    Toolkit,
    Research.Trips,
    Research.Calendar
  }

  @file_path "src/feed"

  def records(file_path \\ @file_path) do
    Path.expand("calendar_dates.txt", file_path)
    |> File.stream!()
    |> FileParser.parse_stream()
    |> Stream.map(fn [
                       id,
                       date,
                       type
                     ] ->
      %{
        id: String.to_integer(id),
        type: String.to_integer(type),
        date: Toolkit.date_from_reverse_string(date)
      }
    end)
  end

  @doc "0) Как много записей в таблице calendar_dates?"
  def count_table_records, do: records() |> Enum.count()
  # 269379

  @doc "1) Сколько всего уникальных service_id?"
  def count_uniq_id, do: records() |> Toolkit.count_uniq_in(:id)
  # 866

  @doc "1.1) Сколько из них встречается в таблице trips?"
  def calendar_dates_service_id_to_trips_service_id do
    trips_services =
      Trips.records()
      |> MapSet.new(& &1.service_id)

    records()
    |> MapSet.new(& &1.id)
    |> MapSet.intersection(trips_services)
  end

  # 866

  @doc "1.1) Каковы частоты встречаемости service_id?"
  def service_id_frequencies do
    freqs =
      records()
      |> Enum.frequencies_by(& &1.id)
      |> Enum.sort_by(&elem(&1, 1), :desc)

    [
      Enum.slice(freqs, 0, 5),
      Enum.slice(freqs, -5, 5)
    ]
  end

  # {
  #  [{137710, 363}, {138309, 363}, {137823, 363}, {137446, 363}, {136833, 363}],
  #  [{126205, 91}, {138577, 91}, {138576, 91}, {138674, 91}, {137158, 91}]
  # }

  @doc "2) Какие значения принимает столбец exception_type?"
  def exception_type_frequencies do
    records()
    |> Enum.frequencies_by(& &1.type)
  end

  # %{1 => 132299, 2 => 137080}

  @doc "3) Какие минимальная и максимальная даты?"
  def min_and_max_date_records do
    now = DateTime.utc_now()

    dates =
      records()
      |> Enum.sort_by(& &1.date)

    [
      Enum.at(dates, 0),
      Enum.at(dates, -1)
    ]

    DateTime.diff(DateTime.utc_now(), now, :millisecond)
  end

  # {
  #   %{date: ~D[2011-01-01], service_id: 137829, exception_type: 2},
  #   %{date: ~D[2021-12-31], service_id: 138647, exception_type: 1}
  # }

  @doc """
    3.1) Сколько записей у которых date находится
    вне интервала [start_date, end_date] из calendar?
  """
  def check_services_by_date(records, date) do
    records
    |> Enum.filter(fn row ->
      Date.compare(row.start_date, date) == :gt or
        Date.compare(date, row.end_date) == :gt
    end)
    |> Enum.map(& &1.service_id)
  end

  # def filter_false_dates do
  #   now = DateTime.utc_now()

  #   calendar =
  #     CalendarParser.calendar()

  #   calendar_dates()
  #   |> Enum.zip_with()
  #   |> Enum.filter(fn x -> x.id in check_services_by_date(calendar, x.date) end)
  #   |> Enum.count()

  #   DateTime.diff(DateTime.utc_now(), now, :millisecond)
  # end
  # 131387

  def filter_false_dates do
    [min, max] =
      Calendar.date_outer_range()

    records()
    |> Enum.filter(fn x ->
      Date.compare(x.date, min) == :gt and
        Date.compare(x.date, max) == :lt
    end)
    |> Enum.group_by(& &1.id, & &1.date)
    |> Enum.map(fn {k, v} -> {k, Enum.sort(v, Date)} end)
  end
end
