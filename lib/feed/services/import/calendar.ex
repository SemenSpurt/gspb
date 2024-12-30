defmodule Feed.Services.Import.Calendar do
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

  alias Feed.{
    Repo,
    Utils.Toolkit,
    Ecto.Calendar.Calendar,
    Ecto.Calendar.Week
  }

  @file_path "C:/Users/SamJa/Desktop/Notebooks/feed/calendar.txt"

  def import_calendar(file_path \\ @file_path) do
    file_path
    |> File.stream!()
    |> FileParser.parse_stream()
    |> Stream.map(fn [service_id, _, _, _, _, _, _, _, start_date, end_date, name] ->
      %{
        service_id: String.to_integer(service_id),
        start_date: Toolkit.date_from_reverse_string(end_date),
        end_date: Toolkit.date_from_reverse_string(start_date),
        name: String.trim(name)
      }
    end)
    |> Stream.chunk_every(1000)
    |> Enum.each(&Repo.insert_all(Calendar, &1))
  end

  def import_week(file_path \\ @file_path) do
    file_path
    |> File.stream!()
    |> FileParser.parse_stream()
    |> Stream.map(fn [
                       _,
                       monday,
                       tuesday,
                       wednesday,
                       thursday,
                       friday,
                       saturday,
                       sunday,
                       _,
                       _,
                       name
                     ] ->
      %{
        monday: String.to_integer(monday) == 1,
        tuesday: String.to_integer(tuesday) == 1,
        wednesday: String.to_integer(wednesday) == 1,
        thursday: String.to_integer(thursday) == 1,
        friday: String.to_integer(friday) == 1,
        saturday: String.to_integer(saturday) == 1,
        sunday: String.to_integer(sunday) == 1,
        name: String.trim(name)
      }
    end)
    |> Enum.uniq_by(& &1.name)
    |> Enum.chunk_every(1)
    |> Enum.each(&Repo.insert_all(Week, &1))
  end
end
