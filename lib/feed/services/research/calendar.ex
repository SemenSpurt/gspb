defmodule Feed.Services.Research.Calendar do
  # """
  # service_id:   integer,
  # monday:       integer,
  # tuesday:      integer,
  # wednesday:    integer,
  # thursday:     integer,
  # friday:       integer,
  # saturday:     integer,
  # sunday:       integer,
  # start_date:   date,
  # end_date:     date,
  # service_name: string
  # """

  alias Feed.Services.{
    Toolkit
  }

  @file_path "src/feed"

  def records(file_path \\ @file_path) do
    Path.expand("calendar.txt", file_path)
    |> File.stream!()
    |> FileParser.parse_stream()
    |> Stream.map(fn [
                       service_id,
                       monday,
                       tuesday,
                       wednesday,
                       thursday,
                       friday,
                       saturday,
                       sunday,
                       start_date,
                       end_date,
                       name
                     ] ->
      %{
        service_id: String.to_integer(service_id),
        monday: String.to_integer(monday) == 1,
        tuesday: String.to_integer(tuesday) == 1,
        wednesday: String.to_integer(wednesday) == 1,
        thursday: String.to_integer(thursday) == 1,
        friday: String.to_integer(friday) == 1,
        saturday: String.to_integer(saturday) == 1,
        sunday: String.to_integer(sunday) == 1,
        start_date: Toolkit.date_from_reverse_string(end_date),
        end_date: Toolkit.date_from_reverse_string(start_date),
        name: String.trim(name)
      }
    end)
  end

  @doc "0) Как много записей в таблице calendar?"
  def count_table_records, do: records() |> Enum.count()
  # 977

  @doc "Как много уникальных service_id?"
  def count_uniq_service_id, do: records() |> Toolkit.count_uniq_in(:service_id)
  # 977

  @doc "1) Какие значения принимает столбец monday?"
  def monday_frequencies, do: records() |> Enum.frequencies_by(& &1.monday)
  # %{0 => 430, 1 => 547}

  @doc "2) Какие значения принимает столбец tuesday?"
  def tuesday_frequencies, do: records() |> Enum.frequencies_by(& &1.tuesday)
  # %{0 => 430, 1 => 547}

  @doc "3) Какие значения принимает столбец wednesday?"
  def wednesday_frequencies, do: records() |> Enum.frequencies_by(& &1.wednesday)
  # %{0 => 430, 1 => 547}

  @doc "4) Какие значения принимает столбец thursday?"
  def thursday_frequencies, do: records() |> Enum.frequencies_by(& &1.thursday)
  # %{0 => 430, 1 => 547}

  @doc "5) Какие значения принимает столбец friday?"
  def friday_frequencies, do: records() |> Enum.frequencies_by(& &1.friday)
  # %{0 => 430, 1 => 547}

  @doc "6) Какие значения принимает столбец saturday?"
  def saturday_frequencies, do: records() |> Enum.frequencies_by(& &1.saturday)
  # %{0 => 444, 1 => 533}

  @doc "7) Какие значения принимает столбец sunday?"
  def sunday_frequencies, do: records() |> Enum.frequencies_by(& &1.sunday)
  # %{0 => 447, 1 => 530}

  @doc "8) Какие значения принимает столбец service_name?"
  def service_name_frequencies, do: records() |> Enum.frequencies_by(& &1.service_name)
  # %{
  #   "Будние дни" => 421,
  #   "Будние дни кроме пятницы" => 2,
  #   "Будние и субботние дни" => 13,
  #   "Воскресенье" => 19,
  #   "Выходные дни" => 400,
  #   "Ежедневно" => 111,
  #   "Пятница" => 2,
  #   "Суббота" => 9
  # }

  @doc "9) Есть ли такие записи для которых start_date > end_date?"
  def check_date_inconsistency do
    records()
    |> Enum.filter(&(Date.compare(&1.start_date, &1.end_date) == :gt))
  end

  # []

  @doc "9.1) Какие min(start_date) and max(end_date)?"
  def date_outer_range do
    dates =
      records()
      |> Enum.map(&[&1.start_date, &1.end_date])
      |> List.flatten()
      |> Enum.sort(Date)

    [
      Enum.at(dates, 0),
      Enum.at(dates, -1)
    ]
  end

  # [~D[2019-12-30], ~D[2024-11-23]]

  @doc "10) Получить service_id's для даты"
  def service_id_by_date(date) do
    date =
      date
      |> Date.from_iso8601!()

    weekday =
      date
      |> Calendar.Date.day_of_week_name()
      |> String.downcase()
      |> String.to_atom()

    records()
    |> Enum.filter(
      &(&1[weekday] == 1 and
          Date.compare(&1.start_date, date) == :lt and
          Date.compare(date, &1.end_date) == :lt)
    )
  end
end
