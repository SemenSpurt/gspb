defmodule CalendarParser do

  alias Toolkit

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

  def calendar(file_path \\ "C:/Users/SamJa/Desktop/Notebooks/feed/calendar.txt") do
    file_path
    |> File.stream!()
    |> FileParser.parse_stream()
    |> Enum.map(
      fn [
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
        service_name
      ] -> %{
        service_id:   String.to_integer(service_id),
        monday:       String.to_integer(monday),
        tuesday:      String.to_integer(tuesday),
        wednesday:    String.to_integer(wednesday),
        thursday:     String.to_integer(thursday),
        friday:       String.to_integer(friday),
        saturday:     String.to_integer(saturday),
        sunday:       String.to_integer(sunday),
        start_date:   Toolkit.date_from_reverse_string(end_date),
        end_date:     Toolkit.date_from_reverse_string(start_date),
        service_name: service_name
      }
    end)
  end


  @doc "0) Как много записей в таблице calendar?"
  def count_table_records, do: calendar() |> Enum.count()
  # 977


  @doc "1) Какие значения принимает столбец monday?"
  def monday_frequencies, do: calendar() |> Toolkit.frequencies_in(:monday)
  # %{0 => 430, 1 => 547}


  @doc "2) Какие значения принимает столбец tuesday?"
  def tuesday_frequencies, do: calendar() |> Toolkit.frequencies_in(:tuesday)
  # %{0 => 430, 1 => 547}


  @doc "3) Какие значения принимает столбец wednesday?"
  def wednesday_frequencies, do: calendar() |> Toolkit.frequencies_in(:wednesday)
  # %{0 => 430, 1 => 547}


  @doc "4) Какие значения принимает столбец thursday?"
  def thursday_frequencies, do: calendar() |> Toolkit.frequencies_in(:thursday)
  # %{0 => 430, 1 => 547}


  @doc "5) Какие значения принимает столбец friday?"
  def friday_frequencies, do: calendar() |> Toolkit.frequencies_in(:friday)
  # %{0 => 430, 1 => 547}


  @doc "6) Какие значения принимает столбец saturday?"
  def saturday_frequencies, do: calendar() |> Toolkit.frequencies_in(:saturday)
  # %{0 => 444, 1 => 533}


  @doc "7) Какие значения принимает столбец sunday?"
  def sunday_frequencies, do: calendar() |> Toolkit.frequencies_in(:sunday)
  # %{0 => 447, 1 => 530}


  @doc "8) Какие значения принимает столбец service_name?"
  def service_name_frequencies, do: calendar() |> Toolkit.frequencies_in(:service_name)
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

end
