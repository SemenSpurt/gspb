defmodule StopParser do

  alias FileParser

  # """
  #   stop_id:             integer,
  #   stop_code:           integer,
  #   stop_name:           string,
  #   stop_lat:            float,
  #   stop_lon:            float,
  #   location_type:       integer,
  #   wheelchair_boarding: integer,
  #   transport_type:      string
  # """


  def records(file_path \\ "C:/Users/SamJa/Desktop/Notebooks/feed/stops.txt") do
    file_path
    |> File.stream!()
    |> FileParser.parse_stream()
    |> Enum.map(
      fn [
        id,
        code,
        name,
        lat,
        lon,
        loc_type,
        chair_board,
        transport_type
      ] -> %{
        :id => String.to_integer(id),
        :code => String.to_integer(code),
        :name => name,
        :coords => [
          String.to_float(lon),
          String.to_float(lat)
        ],
        :loc_type => String.to_integer(loc_type),
        :chair_board => String.to_integer(chair_board),
        :transport_type => transport_type
      }
    end)
  end
end

"""
0) Как много записей в таблице stops?

  StopParser.records()
  |> Enum.count

  # 8557


1) Действительно ли во всех записях столбца "id"
  содержатся только целочисленные значения?

  StopParser.records()
  |> Enum.all?(& &1[:id] |> is_integer())

  # true


1.1) Сколько всего уникальных id?

  StopParser.records()
  |> Enum.map(& &1[:id])
  |> Enum.uniq
  |> Enum.count

  # 8557


2) Действительно ли во всех записях столбца "code"
  содержатся только целочисленные значения?

  StopParser.records()
  |> Enum.all?(& &1[:code] |> is_integer())

  # true

2.1) Сколько всего уникальных code?

  StopParser.records()
  |> Enum.map(& &1[:code])
  |> Enum.uniq
  |> Enum.count

  # 8557

2.1) Есть ли такие записи, что id != code?

  StopParser.records()
  |> Enum.map(& &1[:id] != &1[:code])
  |> Enum.any?

  # true

2.2) В каких записях id != code?

  StopParser.records()
  |> Enum.filter(& &1[:id] != &1[:code])

  . . .

  # {
  #   "type": "FeatureCollection",
  #   "features": [
  #   {
  #     "type": "Feature",
  #     "geometry": {
  #         "type": "MultiPoint",
  #         "coordinates": []
  #       },
  #     "properties": {}
  #   }]
  # }


3) Сколько уникальных "name"?

  StopParser.records()
  |> Enum.map(& &1[:name])
  |> Enum.uniq
  |> Enum.count

  # 4288


3.1) Изменится ли количество уникальных значений
  в столбце "name" если сделать replace & upcase?

  StopParser.records()
  |> Enum.map(& &1[:name] |> String.replace([" ", "\"", ".", ","], "") |> String.upcase)
  |> Enum.uniq
  |> Enum.count

  # 3546

4) Сколько уникальных координат?

  StopParser.records()
  |> Enum.map(& &1[:coords])
  |> Enum.uniq
  |> Enum.count

  # 8542

4.1) Сколько повторяющихся координат?

  StopParser.records()
  |> Enum.frequencies_by(& &1[:coords])
  |> Enum.filter(fn {_, x} -> x > 1 end)

  # . . .


4.2) Посмотреть на карте повторяющиеся координаты

  StopParser.records()
  |> Enum.frequencies_by(& &1[:coords])
  |> Enum.filter(fn {_, x} -> x > 1 end)
  |> Enum.map(&elem(&1, 0)) |> inspect()

  # {
  #   "type": "FeatureCollection",
  #   "features": [
  #   {
  #     "type": "Feature",
  #     "geometry": {
  #         "type": "MultiPoint",
  #         "coordinates":  []
  #       },
  #     "properties": {}
  #   }]
  # }


4.2) Посмотреть все координаты

  coords = StopParser.records()
  |> Enum.map(& &1[:coords])
  |> inspect(limit: :infinity)

  File.write("coords.txt", coords)


5) Действительно ли во всех записях столбца "location_type"
  содержатся только целочисленные значения?

    StopParser.records()
    |> Enum.all?(& &1[:loc_type] |> is_integer())

  # true


5.1) Что такое location_type и какие значения принимает?

  StopParser.records()
  |> Enum.frequencies_by(& &1[:loc_type])

  # %{0 => 8557}
  # наземная остановка ?


6) Действительно ли во всех записях столбца "wheelchair_boarding"
  содержатся только целочисленные значения?

  StopParser.records()
  |> Enum.all?(& &1[:chair_board] |> is_integer())

  # true


6.1) Что такое wheelchair_boarding и какие значения принимает?

  StopParser.records()
  |> Enum.frequencies_by(& &1[:chair_board])

  # %{1 => 1, 2 => 8556}
  # остановка для ограниченно мобильных пассажиров?


6.2) Проверить, какая записть содержит единственный :chair_board => 1?

  StopParser.records()
  |> Enum.filter(& &1[:chair_board] == 1)

  # [
  # %{
  #   code: 27567,
  #   id: 27567,
  #   name: "ШКОЛА № 478",
  #   loc_type: 0,
  #   chair_board: 1,
  #   transport_type: "bus",
  #   coords: [30.45556, 60.033546]
  # }
  # ]


7) Что такое transport_type и какие значения принимает?

  StopParser.records()
  |> Enum.frequencies_by(& &1[:transport_type])

    # %{"bus" => 6316, "tram" => 897, "trolley" => 1344}

"""
