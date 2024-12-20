defmodule RouteParser do
  # """
  #   route_id:           integer
  #   agency_id:          string  :drop
  #   route_short_name:   string
  #   route_long_name:    string
  #   route_type:         integer : drop
  #   transport_type:     string
  #   circular:           boolean
  #   urban:              boolean
  #   night:              boolean : drop
  # """

  def routes(file_path \\ "C:/Users/SamJa/Desktop/Notebooks/feed/routes.txt") do
    file_path
    |> File.stream!()
    |> FileParser.parse_stream()
    |> Enum.map(
      fn [
        route,
        agency,
        short_name,
        long_name,
        route_type,
        transport_type,
        circular,
        urban,
        night
      ] -> %{
        id:             String.to_integer(route),
        agency:         agency,
        short_name:     short_name,
        long_name:      long_name,
        route_type:     String.to_integer(route_type),
        transport_type: transport_type,
        circular:       circular,
        urban:          urban,
        night:          night
      }
    end)
  end


  @doc "0) Как много записей в таблице routes?"
  def count_table_records, do: routes() |> Enum.count()
  # 554


  @doc "1) Есть ли нецелочисленные значения в столбце route_id?"
  def nonintegers_in_id?, do: routes() |> Toolkit.check_nonintegers_in(:id)
  # false


  @doc "1.1) Сколько всего уникальных route_id?"
  def count_uniq_id, do: routes() |> Toolkit.count_uniq_in(:id)
  # 554


  @doc "2) Сколько всего уникальных agency_id?"
  def count_uniq_agency, do: routes() |> Toolkit.count_uniq_in(:agency)
  # 1


  @doc "2.1) Есть ли отличные от 'orgp' значения в столбце agency_id?"
  def values_of_agency, do: routes() |> Enum.frequencies_by(& &1.agency)
  # %{"orgp" => 554}


  @doc "3) Сколько всего уникальных short_name?"
  def count_uniq_short_name, do: routes() |> Toolkit.count_uniq_in(:short_name)
  # 469


  @doc "3.1) Количество уникальных short_name после коррекции"
  def count_uniq_short_names_after_correction do
    routes()
    |> Enum.uniq_by(
      & &1.short_name
      |> String.replace([" ", "\"", ".", ","], "")
      |> String.upcase
    )
    |> Enum.count()
  end
  # 469?


  @doc "3.2) Какие значения short_name повторяются?"
  def short_names_duplicated do
    routes()
    |> Enum.frequencies_by(& &1[:short_name])
    |> Enum.filter(fn {_, x} -> x > 1 end)
  end
  # . . .


  @doc "4) Как много уникальных значений в столбце long_name?"
  def count_uniq_long_name, do: routes() |> Toolkit.count_uniq_in(:long_name)
  # 529


  @doc "4.1) Количество уникальных long_name после коррекции"
  def count_uniq_long_names_after_correction do
    routes()
    |> Enum.uniq_by(
      & &1.long_name
      |> String.replace([" ", "\"", ".", ","], "")
      |> String.upcase
    )
    |> Enum.count()
  end
  # 528?


  @doc "4.2) Какие значения short_name повторяются?"
  # ????
  def long_names_duplicated do
    routes()
    |> Enum.frequencies_by(& &1[:long_name])
    |> Enum.filter(fn {_, x} -> x > 1 end)
  end
  # . . .


  @doc "5) Есть ли нецелочисленные значения в столбце route_type?"
  def nonintegers_in_route_type?, do: routes() |> Toolkit.check_nonintegers_in(:route_type)
  # false


  @doc "5.1) Какие значения принимает поле route_type?"
  def route_type_frequencies, do: routes() |> Enum.frequencies_by(& &1.route_type)
  # %{0 => 43, 3 => 511}


  @doc "6) Какие значения принимает поле transport_type?"
  def transport_type_frequencies, do: routes() |> Enum.frequencies_by(& &1.transport_type)
  # %{"bus" => 464, "tram" => 43, "trolley" => 47}


  @doc "6.1) Действительно ли route_type[0] == transport_type['tram']"
  def check_zero_route_type_transports do
    routes()
    |> Enum.filter(& &1[:route_type] == 0)
    |> Enum.frequencies_by(& &1[:transport_type])
  end
  # %{"tram" => 43}


  @doc "7) Какие значения принимает поле circular?"
  def circular_frequencies, do: routes() |> Enum.frequencies_by(& &1.circular)
  # %{"0" => 524, "1" => 30}


  @doc "7.1) Какие маршруты имеют circular == 1?"
  def circular_routes, do: routes() |> Enum.filter(& &1.circular == "1")
  # . . .


  @doc "7.2 Какие transport_type имеют circular == 1?"
  def circular_transport_types do
    circular_routes()
    |> Enum.frequencies_by(& &1.transport_type)
  end
  # %{"bus" => 30}


  @doc "8) Какие значения принимает столбец urban?"
  def urban_frequencies, do: routes() |> Enum.frequencies_by(& &1.urban)
  # %{"0" => 56, "1" => 498}


  @doc "9) Какие значения принимает столбец night?"
  def night_frequencies, do: routes() |> Enum.frequencies_by(& &1.night)
  # %{"0" => 554}


  @doc "10) Сколько route_id не имеют записей в таблице trips?"
  def find_extra_routes do
    trip_routes =
      TripParser.trips()
      |> Enum.uniq_by(& &1.route_id)
      |> Enum.map(& &1.route_id)

    routes()
    |> Enum.filter(fn row -> row.id not in trip_routes end)
    |> Enum.count()
  end
  # 5

end
