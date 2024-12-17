defmodule TripParser do

  alias FileParser

  # """
  #   route_id:       integer
  #   service_id:     integer
  #   trip_id:        integer
  #   direction_id:   boolean
  #   shape_id:       string
  # """


  def records(file_path \\ "C:/Users/SamJa/Desktop/Notebooks/feed/trips.txt") do
    file_path
    |> File.stream!()
    |> FileParser.parse_stream()
    |> Enum.map(
      fn [
        route_id,
        service_id,
        trip_id,
        direction_id,
        shape_id
      ] -> %{
        :route_id => String.to_integer(route_id),
        :service_id => String.to_integer(service_id),
        :trip_id => String.to_integer(trip_id),
        :direction_id => direction_id,
        :shape_id => shape_id
      }
    end)
  end
end


"""
0) Как много записей в таблице trips?

  TripParser.records()
  |> Enum.count

  # 124157


1) Действительно ли во всех записях столбца "route_id"
  содержатся только целочисленные значения?

  TripParser.records()
  |> Enum.all?(& &1[:route_id] |> is_integer())

  # true


1) Сколько уникальных route_id?

  TripParser.records()
  |> Enum.map(& &1[:route_id])
  |> Enum.uniq()
  |> Enum.count()

  # 549


2) Действительно ли во всех записях столбца "service_id"
  содержатся только целочисленные значения?

  TripParser.records()
  |> Enum.all?(& &1[:service_id] |> is_integer())

  # true


2.1) Сколько уникальных service_id?

  TripParser.records()
  |> Enum.map(& &1[:service_id])
  |> Enum.uniq()
  |> Enum.count()

  # 977


3) Какие значения принемает столбец direction_id?

  TripParser.records()
  |> Enum.frequencies_by(& &1[:direction_id])

  # %{"0" => 62221, "1" => 61936}


4) Действительно ли во всех записях столбца "trip_id"
  содержатся только целочисленные значения?

  TripParser.records()
  |> Enum.all?(& &1[:trip_id] |> is_integer())

  # true

4.1) Сколько уникальных значений в столбце trip_id?

  TripParser.records()
  |> Enum.map(& &1[:trip_id])
  |> Enum.uniq()
  |> Enum.count()

  # 124157


5) Сколько уникальных значений в столбце shape_id?

  TripParser.records()
  |> Enum.map(& &1[:shape_id])
  |> Enum.uniq()
  |> Enum.count()

  # 1077

5.1) Универсален ли префикс "track-" для всех записей?

  TripParser.records()
  |> Enum.frequencies_by(& &1[:shape_id] |> String.split("-") |> Enum.at(0))

  # %{"" => 2251, "track" => 121906}
  # no

5.2) Суффиксов типа "track-XXXXXX" все целочисленные?

  TripParser.records()
  |> Enum.filter(& &1[:shape_id] != "")
  |> Enum.map(& &1[:shape_id] |> String.split("-") |> Enum.at(1) |> String.to_integer())

  # . . .
  #  yes

"""
