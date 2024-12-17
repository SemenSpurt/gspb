defmodule RouteParser do

  alias FileParser

  # """
  #   route_id:         integer
  #   agency_id:        string
  #   route_short_name: string
  #   route_long_name:  string
  #   route_type:       integer
  #   transport_type:   string
  #   circular:         boolean
  #   urban:            boolean
  #   night:            boolean
  # """

  def records(file_path \\ "C:/Users/SamJa/Desktop/Notebooks/feed/routes.txt") do
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
        :id               => String.to_integer(route),
        :agency           => agency,
        :short_name       => short_name,
        :long_name        => long_name,
        :route_type       => String.to_integer(route_type),
        :transport_type   => transport_type,
        :circular         => circular,
        :urban            => urban,
        :night            => night,
      }
    end)
  end
end


"""
0) Как много записей в таблице stops?

  RouteParser.records()
  |> Enum.count

  # 554


1) Действительно ли во всех записях столбцов ["id", "route_type"]
  содержатся только целочисленные значения?

  [:id, :route_type]
  |> Enum.map(
  fn col -> RouteParser.records()
    |> Enum.map(& &1[col] |> is_integer())
    |> Enum.all?
  end)

  # [true, true]


1.1) Как много уникальных значений в столбце "id"?

  RouteParser.records()
  |> Enum.map(& &1[:id])
  |> Enum.uniq
  |> Enum.count

  # 554


2) Как много уникальных значений в столбце "agency_id"?

  RouteParser.records()
  |> Enum.map(& &1[:agency])
  |> Enum.uniq
  |> Enum.count

  #  1


2.1) Есть ли записи в стоблце "agency_id"
   которые не соответствуют "orgp"

  RouteParser.records()
  |> Enum.map(& &1[:agency] != "orgp")
  |> Enum.any?()

  # false


3) Как много уникальных значений в столбце "short_name"?

  RouteParser.records()
  |> Enum.map(& &1[:short_name])
  |> Enum.uniq
  |> Enum.count

  # 469


3.1) Изменится ли количество уникальных значений
  в столбце "short_name" если потримить строки?

  RouteParser.records()
  |> Enum.map(& &1[:short_name] |> String.trim)
  |> Enum.uniq
  |> Enum.count

  # 469


3.2) Изменится ли количество уникальных значений
  в столбце "short_name" если сделать upcase?

  RouteParser.records()
  |> Enum.map(& &1[:short_name] |> String.trim |> String.upcase)
  |> Enum.uniq
  |> Enum.count

  # 469


3.3) Какие значения "short_name" повторяются?

RouteParser.records()
|> Enum.frequencies_by(& &1[:short_name])
|> Enum.sort_by(fn {_, x} -> x end, :desc)
|> Enum.filter(fn {_, x} -> x > 1 end)

# . . .


4) Как много уникальных значений в столбце "long_name"?

  RouteParser.records()
  |> Enum.map(& &1[:long_name])
  |> Enum.uniq
  |> Enum.count

  # 529


4.1) Изменится ли количество уникальных значений
  в столбце "long_name" если сделать trim & upcase?

  RouteParser.records()
  |> Enum.map(& &1[:long_name] |> String.trim |> String.upcase)
  |> Enum.uniq
  |> Enum.count

  # 528


4.2) Какие значения "long_name" повторяются?

RouteParser.records
|> Enum.frequencies_by(& &1[:long_name])
|> Enum.sort_by(fn {_, x} -> x end, :desc)
|> Enum.filter(fn {_, x} -> x > 1 end)

# . . .


5) Какие значения принимает поле "route_type"?

  RouteParser.records()
  |> Enum.frequencies_by(& &1[:route_type])

  # %{0 => 43, 3 => 511}


6) Какие значения принимает поле "transport_type"?

  RouteParser.records()
  |> Enum.frequencies_by(& &1[:transport_type])

  # %{"bus" => 464, "tram" => 43, "trolley" => 47}


6.1) Действительно ли route_type[0] == transport_type["tram"]

  RouteParser.records()
  |> Enum.filter(& &1[:route_type] == 0)
  |> Enum.frequencies_by(& &1[:transport_type])

  # %{"tram" => 43}


7) Какие значения принимает столбец "circular"?

  RouteParser.records()
  |> Enum.frequencies_by(& &1[:circular])

  # %{"0" => 524, "1" => 30}


8) Какие значения принимает столбец "urban"?

  RouteParser.records()
  |> Enum.frequencies_by(& &1[:urban])

  # %{"0" => 56, "1" => 498}


9) Какие значения принимает столбец "night"?

  RouteParser.records()
  |> Enum.frequencies_by(& &1[:night])

  # %{"0" => 56, "1" => 498}

"""
