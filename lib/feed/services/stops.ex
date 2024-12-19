defmodule StopParser do
  alias FileParser
  alias Toolkit

  # """
  #   stop_id:              integer,
  #   stop_code:            integer,
  #   stop_name:            string,
  #   stop_lat:             float,
  #   stop_lon:             float,
  #   location_type:        integer, # drop
  #   wheelchair_boarding:  integer, # drop
  #   transport_type:       string
  # """


  def stops(file_path \\ "C:/Users/SamJa/Desktop/Notebooks/feed/stops.txt") do
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
        id: String.to_integer(id),
        code: String.to_integer(code),
        name: name,
        coords: [
          String.to_float(lon),
          String.to_float(lat)
        ],
        loc_type: String.to_integer(loc_type),
        chair_board: String.to_integer(chair_board),
        transport_type: transport_type
      }
    end)
  end


  @doc "0) Как много записей в таблице stops?"
  def count_table_records, do: stops() |> Enum.count()
  # 8557


  @doc "1) Есть ли нецелочисленные значения в столбце stop_id?"
  def nonintegers_in_id?, do: stops() |> Toolkit.check_nonintegers_in(:id)
  # false


  @doc "1.1) Сколько всего уникальных stop_id?"
  def count_uniq_id, do: stops() |> Toolkit.count_uniq_in(:id)
  # 8557


  @doc "2) Есть ли нецелочисленные значения в столбце stop_code?"
  def nonintegers_in_code?, do: stops() |> Toolkit.check_nonintegers_in(:code)
  # false


  @doc "2.1) Сколько всего уникальных stop_code?"
  def count_uniq_code, do: stops() |> Toolkit.count_uniq_in(:code)
  # 8557


  @doc "2.1) Есть ли записи, у которых stop_id != stop_code?"
  def id_to_code_missmatches?, do: stops() |> Enum.any?(& &1.id != &1.code)
  # false


  @doc "2.2) В каких записях stop_id != stop_code?"
  def id_to_code_missmatches, do: stops() |> Enum.filter(& &1.id != &1.code)
  # . . .


  @doc "3) Сколько уникальных stop_name?"
  def count_uniq_name, do: stops() |> Toolkit.count_uniq_in(:name)
  # 4288


  @doc "3.1) Изменится ли N уникальных stop_name после replace & upcase?"
  def name_uniq_counts do
    stops()
    |> Enum.uniq_by(
      & &1.name
      |> String.replace([" ", "\"", ".", ","], "")
      |> String.upcase
    )
    |> Enum.count
  end
  # 3546


  @doc "4) Сколько уникальных [stop_lat, stop_lon]?"
  def coords_uniq_counts, do: stops() |> Toolkit.count_uniq_in(:coords)
  # 8542


  @doc "4.1) Сколько дублей [stop_lat, stop_lon]?"
  def coords_frequencies do
    stops()
    |> Toolkit.frequencies_in(:coords)
    |> Enum.filter(fn {_, x} -> x > 1 end)
    |> Enum.count()
  end
  # . . .


  @doc "5) Есть ли нецелочисленные значения в столбце location_type?"
  def nonintegers_in_loc_type?, do: stops() |> Toolkit.check_nonintegers_in(:loc_type)
  # false


  @doc "Есть ли нецелочисленные значения в столбце wheelchair_boarding?"
  def nonintegers_in_chair_board?, do: stops() |> Toolkit.check_nonintegers_in(:chair_board)
  # false


  @doc "5.1) Что такое location_type и какие значения принимает?"
  def loc_type_frequencies, do: stops() |> Toolkit.frequencies_in(:loc_type)
  # %{0 => 8557}
  # наземная остановка ?


  @doc "6.1) Что такое wheelchair_boarding и какие значения принимает?"
  def chair_board_frequencies, do: stops() |> Toolkit.frequencies_in(:chair_board)
  # %{1 => 1, 2 => 8556}
  # остановка для ограниченно мобильных пассажиров?


  @doc "6.2) Проверить, какая записть содержит единственный :chair_board => 1?"
  def chair_board_equal_one, do: stops() |> Enum.filter(& &1.chair_board == 1)

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
  def transport_type_frequencies, do: stops() |> Toolkit.frequencies_in(:transport_type)
  # %{"bus" => 6316, "tram" => 897, "trolley" => 1344}


end


# doc """
#     4.2) Посмотреть на карте повторяющиеся координаты
# """

# def
#   StopParser.records()
#   |> Enum.frequencies_by(& &1[:coords])
#   |> Enum.filter(fn {_, x} -> x > 1 end)
#   |> Enum.map(&elem(&1, 0)) |> inspect()
