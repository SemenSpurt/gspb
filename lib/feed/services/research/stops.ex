defmodule StopParser do
  # """
  #   stop_id:              integer,
  #   stop_code:            integer, # drop
  #   stop_name:            string,
  #   stop_lat:             float,
  #   stop_lon:             float,
  #   location_type:        integer, # drop
  #   wheelchair_boarding:  integer, # drop
  #   transport_type:       string
  # """

  alias Feed.Utils.Toolkit

  @file_path "C:/Users/SamJa/Desktop/Notebooks/feed/stops.txt"

  def records(file_path \\ @file_path) do
    file_path
    |> File.stream!()
    |> FileParser.parse_stream()
    |> Enum.map(
      fn [
        id,
        _, # code
        name,
        lat,
        lon,
        _, # loc_type
        _, # chair_board
        transport
      ] -> %{
        id: String.to_integer(id),
        # code: String.to_integer(code),
        name: String.trim(name),
        coords: [
          String.to_float(lon),
          String.to_float(lat)
        ],
        # loc_type: String.to_integer(loc_type),
        # chair_board: String.to_integer(chair_board),
        transport: String.trim(transport)
      }
    end)
  end


  @doc "0) Как много записей в таблице stops?"
  def count_table_records, do: records() |> Enum.count()
  # 8557


  @doc "1.1) Сколько всего уникальных stop_id?"
  def count_uniq_id, do: records() |> Toolkit.count_uniq_in(:id)
  # 8557


  @doc "2.1) Сколько всего уникальных stop_code?"
  def count_uniq_code, do: records() |> Toolkit.count_uniq_in(:code)
  # 8557


  @doc "2.2) В каких записях stop_id != stop_code?"
  def id_to_code_missmatches, do: records() |> Enum.filter(& &1.id != &1.code)
  # [
  #   %{
  #     code: 41870,
  #     id: 41884,
  #     name: "МАЛЫЙ ПР. В.О.",
  #     coords: [30.23253, 59.93826],
  #     loc_type: 0,
  #     chair_board: 2,
  #     transport_type: "bus"
  #   },
  #   %{
  #     code: 41871,
  #     id: 41885,
  #     name: "УЛ. ТКАЧЕЙ",
  #     coords: [30.427847, 59.893068],
  #     loc_type: 0,
  #     chair_board: 2,
  #     transport_type: "bus"
  #   },
  #   %{
  #     code: 41869,
  #     id: 41883,
  #     name: "МАЛЫЙ ПР. В.О.",
  #     coords: [30.22499, 59.94078],
  #     loc_type: 0,
  #     chair_board: 2,
  #     transport_type: "bus"
  #   }
  # ]


  @doc "Посмотреть эти записи на карте"
  def geojson_id_to_code_missmatches do
    records()
    |> Enum.filter(& &1.id != &1.code)
    |> Enum.map(& &1.coords)
    |> Toolkit.geojson_string()
    |> IO.puts()
  end


  @doc "3) Сколько уникальных stop_name?"
  def count_uniq_name, do: records() |> Toolkit.count_uniq_in(:name)
  # 4288


  @doc "3.1) Изменится ли N уникальных stop_name после replace & upcase?"
  def name_uniq_counts do
    records()
    |> Enum.uniq_by(
      & &1.name
      |> String.upcase
      |> String.replace(["ПЕРЕУЛОК ", "ПЕР ", "ПЕР. ", "ПЕР., "], "ПЕР. ")
      |> String.replace(["УЛИЦА ", "УЛ ", "УЛ. ", "УЛ., "], "УЛ. ")
      |> String.replace(["\"", ".", ","], "")
    )
    |> Enum.count
  end
  # 3590

  def parse_stop_name(name) do
    name
    |> String.upcase
    |> String.replace(["ПЕРЕУЛОК ", "ПЕР ", "ПЕР. ", "ПЕР., "], "ПЕР. ")
    |> String.replace(["УЛИЦА ", "УЛ ", "УЛ. ", "УЛ., "], "УЛ. ")
    |> String.replace(["\""], "")
  end


  @doc "4) Сколько уникальных [stop_lat, stop_lon]?"
  def coords_uniq_counts, do: records() |> Toolkit.count_uniq_in(:coords)
  # 8542


  @doc "4.1) Проверить дуюли координат [stop_lat, stop_lon]?"
  def coords_dubles do
    all_stops =
      records()

    coords =
      all_stops
      |> Enum.frequencies_by(& &1.coords)
      |> Enum.filter(fn {_, x} -> x > 1 end)
      |> Enum.map(&elem(&1, 0))

    all_stops
    |> Enum.filter(fn row -> row.coords in coords end)
    |> Enum.group_by(& &1.coords, & &1.name)
  end
  # . . .


  @doc "4.2) Посмотреть на карте дубли координат"
  def geojson_duplicates_coords do
    records()
    |> Enum.frequencies_by(& &1.coords)
    |> Enum.filter(fn {_, x} -> x > 1 end)
    |> Enum.map(&elem(&1, 0))
    |> Toolkit.geojson_string()
    |> IO.puts()
  end
  #


  @doc "5.1) Что такое location_type и какие значения принимает?"
  def loc_type_frequencies, do: records() |> Enum.frequencies_by(& &1.loc_type)
  # %{0 => 8557}
  # наземная остановка ?


  @doc "6.1) Что такое wheelchair_boarding и какие значения принимает?"
  def chair_board_frequencies, do: records() |> Enum.frequencies_by(& &1.chair_board)
  # %{1 => 1, 2 => 8556}
  # остановка для ограниченно мобильных пассажиров?


  @doc "6.2) Проверить, какая записть содержит единственный :chair_board => 1?"
  def chair_board_equal_one, do: records() |> Enum.filter(& &1.chair_board == 1)

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


  @doc "7) Что такое transport_type и какие значения принимает?"
  def transport_frequencies, do: records() |> Enum.frequencies_by(& &1.transport)
  # %{"bus" => 6316, "tram" => 897, "trolley" => 1344}



  @doc "Есть ли такие stop_id, которых нет в stop_times?"
  def stop_id_to_stop_times_stop_id do
    records()
    |> MapSet.new(& &1.id)
    |> MapSet.difference(
      StopTimesParser.records()
      |> MapSet.new(& &1.stop_id)
      )
  end

end
