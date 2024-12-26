defmodule RouteParser do
  # """
  #   route_id:           integer
  #   agency_id:          string  : drop
  #   route_short_name:   string
  #   route_long_name:    string
  #   route_type:         integer : drop
  #   transport_type:     string
  #   circular:           boolean
  #   urban:              boolean
  #   night:              boolean : drop
  # """

  @file_path "C:/Users/SamJa/Desktop/Notebooks/feed/routes.txt"

  def routes(file_path \\ @file_path) do
    file_path
    |> File.stream!()
    |> FileParser.parse_stream()
    |> Enum.map(
      fn [
        id,
        agency,
        short_name,
        long_name,
        route_type,
        transport,
        circular,
        urban,
        night
      ] -> %{
        id:             String.to_integer(id),
        agency:         String.trim(agency),
        short_name:     String.trim(short_name),
        long_name:      String.trim(long_name),
        route_type:     String.to_integer(route_type),
        transport:      String.trim(transport),
        circular:       String.to_integer(circular),
        urban:          String.to_integer(urban),
        night:          String.to_integer(night)
      }
    end)
  end


  @doc "0) Как много записей в таблице routes?"
  def count_table_records, do: RouteParser.routes() |> Enum.count()
  # 554


  @doc "1.1) Сколько всего уникальных route_id?"
  def count_uniq_id, do: RouteParser.routes() |> Toolkit.count_uniq_in(:id)
  # 554


  @doc "2) Сколько всего уникальных agency_id?"
  def count_uniq_agency, do: RouteParser.routes() |> Toolkit.count_uniq_in(:agency)
  # 1


  @doc "2.1) Есть ли отличные от 'orgp' значения в столбце agency_id?"
  def values_of_agency, do: RouteParser.routes() |> Enum.frequencies_by(& &1.agency)
  # %{"orgp" => 554}


  @doc "3) Сколько всего уникальных short_name?"
  def count_uniq_short_name, do: RouteParser.routes() |> Toolkit.count_uniq_in(:short_name)
  # 469
  # other differs in transport type

  @doc "3.2) Какие значения short_name повторяются?"
  def short_names_duplicated do
    RouteParser.routes()
    |> Enum.frequencies_by(& &1.short_name)
    |> Enum.filter(fn {_, x} -> x > 1 end)
  end
  # . . .
  # they differs in transport type

  @doc "3.1) Вывести short_name, у которых более 1 long_name"
  def count_uniq_short_names_after_correction do
    RouteParser.routes()
    |> Enum.group_by(& &1.short_name, & &1.long_name)
    |> Enum.filter(fn {_, x} -> Enum.count(x) > 1 end)
  end
  # . . .
  # they differs in transport type


  @doc "4) Сколько всего уникальных long_name?"
  def count_uniq_long_name, do: RouteParser.routes() |> Toolkit.count_uniq_in(:long_name)
  # 529
  # Other differs in short_name

  @doc "4.2) Какие значения long_names повторяются?"
  def long_names_duplicated do
    RouteParser.routes()
    |> Enum.frequencies_by(& &1.long_name)
    |> Enum.filter(fn {_, x} -> x > 1 end)
  end
  # . . .
  # They differs in short_name

  @doc "4.1) Вывести long_name, у которых более 1 short_name"
  def count_uniq_long_names_after_correction do
    RouteParser.routes()
    |> Enum.group_by(& &1.long_name, & &1.short_name)
    |> Enum.filter(fn {_, x} -> Enum.count(x) > 1 end)
  end
  # . . .
  # They differs in short_name


  @doc "5.1) Какие значения принимает поле route_type?"
  def route_type_frequencies, do: RouteParser.routes() |> Enum.frequencies_by(& &1.route_type)
  # %{0 => 43, 3 => 511}


  @doc "6) Какие значения принимает поле transport_type?"
  def transport_frequencies, do: RouteParser.routes() |> Enum.frequencies_by(& &1.transport)
  # %{"bus" => 464, "tram" => 43, "trolley" => 47}


  @doc "6.1) Действительно ли route_type[0] == transport_type['tram']"
  def check_zero_route_type_transports do
    RouteParser.routes()
    |> Enum.filter(& &1.route_type == 0)
    |> Enum.frequencies_by(& &1.transport_type)
  end
  # %{"tram" => 43}


  @doc "7) Какие значения принимает поле circular?"
  def circular_frequencies, do: RouteParser.routes() |> Enum.frequencies_by(& &1.circular)
  # %{"0" => 524, "1" => 30}


  @doc "7.1) Какие маршруты имеют circular == 1?"
  def circular_routes, do: RouteParser.routes() |> Enum.filter(& &1.circular == 1)
  # . . .


  @doc "7.2) Какие transport_type имеют circular == 1?"
  def circular_transport_types do
    circular_routes()
    |> Enum.frequencies_by(& &1.transport)
  end
  # %{"bus" => 30}

  @doc "7.3) Какие shape_id у цикличных маршрутов?"

  def circular_shape_id do
    circles =
      circular_routes()
      |> Enum.map(& &1.id)

    TripParser.trips()
    |> Enum.filter(& &1.route_id in circles)
    |> Enum.frequencies_by(& &1.shape_id)
  end


  @doc "8) Какие значения принимает столбец urban?"
  def urban_frequencies, do: RouteParser.routes() |> Enum.frequencies_by(& &1.urban)
  # %{"0" => 56, "1" => 498}


  @doc "9) Какие значения принимает столбец night?"
  def night_frequencies, do: RouteParser.routes() |> Enum.frequencies_by(& &1.night)
  # %{"0" => 554}


  @doc "10) Какие route_id не имеют записей в таблице trips?"
  def find_extra_routes do
    routes_tb =
      RouteParser.routes()

    trip_routes =
      TripParser.trips()
      |> MapSet.new(& &1.route_id)

    routes_id =
      routes_tb
      |> MapSet.new(& &1.id)
      |> MapSet.difference(trip_routes)

    routes_tb
    |> Enum.filter(fn row -> row.id in routes_id end)
  end
end
