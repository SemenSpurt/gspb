defmodule CalendarDatesParser do
  # """
  # service_id:     integer,
  # date:           date, : удалить избыточные
  # exception_type  integer
  # """

  def calendar_dates(file_path \\ "C:/Users/SamJa/Desktop/Notebooks/feed/calendar_dates.txt") do
    file_path
    |> File.stream!()
    |> FileParser.parse_stream()
    |> Enum.map(
      fn [
        service_id,
        date,
        exception_type
       ] -> %{
        service_id:     String.to_integer(service_id),
        exception_type: String.to_integer(exception_type),
        date:           Toolkit.date_from_reverse_string(date)
      }
    end)
  end


  @doc "0) Как много записей в таблице calendar_dates?"
  def count_table_records, do: calendar_dates() |> Enum.count()
  # 269379


  @doc "1) Сколько всего уникальных service_id?"
  def count_uniq_service_id, do: calendar_dates() |> Toolkit.count_uniq_in(:service_id)
  # 866


  @doc "1.1) Сколько из них встречается в таблице trips?"
  def calendar_dates_setvice_id_to_trips_service_id do

    trips_services =
      TripParser.trips()
      |> Enum.map(& &1.service_id)
      |> Enum.uniq()

    calendar_dates()
    |> Enum.map(& &1.service_id)
    |> Enum.uniq()
    |> Enum.filter(fn x -> x in trips_services end)
    |> Enum.count
  end
  # 866


  @doc "1.1) Каковы частоты встречаемости service_id?"
  def service_id_frequencies do
    freqs =
      calendar_dates()
        |> Enum.frequencies_by(& &1.service_id)
        |> Enum.sort_by(&elem(&1, 1),:desc)

    {
      Enum.slice(freqs, 0, 5),
      Enum.slice(freqs, -5, 5)
    }
  end
  # {
  #  [{137710, 363}, {138309, 363}, {137823, 363}, {137446, 363}, {136833, 363}],
  #  [{126205, 91}, {138577, 91}, {138576, 91}, {138674, 91}, {137158, 91}]
  # }


  @doc "2) Какие значения принимает столбец exception_type?"
  def exception_type_frequencies, do: calendar_dates() |> Enum.frequencies_by(& &1.exception_type)
  # %{1 => 132299, 2 => 137080}


  @doc "3) Какие минимальная и максимальная даты?"
  def min_and_max_date_records do
    dates =
      calendar_dates()
      |> Enum.sort_by(& &1.date)

    {Enum.at(dates, 0), Enum.at(dates, -1)}
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
    |> Enum.filter(
      fn row ->
        Date.compare(row.start_date, date) == :gt or
        Date.compare(date, row.end_date) == :gt
      end
    )
    |> Enum.map(& &1.service_id)

  end
  def filter_false_dates do
    calendar = CalendarParser.calendar()

    calendar_dates()
    |> Enum.filter(fn x -> x.service_id in check_services_by_date(calendar, x.date) end)
    |> Enum.count()
  end
  # 131387
end
