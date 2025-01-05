defmodule Feed.Services.Research.Shapes do
  # """
  # shape_id:             string
  # shape_pt_lat:         float
  # shape_pt_lon:         float
  # shape_pt_sequence:    integer
  # shape_dist_traveled:  float
  # """

  alias Feed.Utils.Toolkit

  @file_path "C:/Users/SamJa/Desktop/Notebooks/feed/"

  def records(file_path \\ @file_path) do
    Path.expand("shapes.txt", file_path)
    |> File.stream!()
    |> FileParser.parse_stream()
    |> Enum.map(fn [
                     id,
                     pt_lat,
                     pt_lon,
                     pt_sequence,
                     dist_traveled
                   ] ->
      %{
        shape_id: String.trim(id),
        coords: {
          String.to_float(pt_lon),
          String.to_float(pt_lat)
        },
        pt_sequence: String.to_integer(pt_sequence),
        dist_traveled: String.to_float(dist_traveled)
      }
    end)
  end

  @doc "0) Как много записей в таблице shapes?"
  def count_table_records, do: records() |> Enum.count()
  # 933327

  @doc "1) Сколько всего уникальных shape_id?"
  def count_uniq_id, do: records() |> Toolkit.count_uniq_in(:id)
  # 28403

  @doc "1) Сколько всего уникальных shape_id + stop_id + pt_sequence?"
  def count_uniq_records do
    records()
    |> Enum.uniq_by(&[&1.id, &1.coords, &1.dist_traveled])
  end

  # 786992

  @doc "1.1) Какие различные префиксы вcтречаются среди значений shape_id?"
  def shape_id_prefixies do
    records()
    |> Enum.frequencies_by(
      &(&1.id
        |> String.split("-")
        |> Enum.at(0))
    )
  end

  # %{"stage" => 479806, "track" => 453521}

  @doc "2) Сколько всего уникальных координат?"
  def count_uniq_coords, do: records() |> Toolkit.count_uniq_in(:coords)
  # 182459

  @doc "3) Нет ли пропущенных или лишних pt_sequence?"
  def check_pt_sequence do
    freqs =
      records()
      |> Enum.frequencies_by(& &1.pt_sequence)
      |> Enum.sort_by(&elem(&1, 1), :desc)
      |> Enum.map(&elem(&1, 1))

    len = Enum.count(freqs)

    [
      Enum.slice(freqs, 0, len - 1),
      Enum.slice(freqs, -len + 1, len)
    ]
    |> Enum.zip_with(fn [a, b] -> b > a end)
    |> Enum.any?()
  end

  def check_pt_order do
    records()
    |> Enum.group_by(& &1.id, & &1.pt_sequence)
    |> Enum.map(fn {k, v} ->
      {k,
       v
       |> Enum.chunk_every(2, 1, :discard)
       |> Enum.map(fn [a, b] -> b - a == 1 end)
       |> Enum.all?()}
    end)
    |> Enum.map(&elem(&1, 1))
    |> Enum.all?()
  end

  # false

  @doc "3.1) Получить координаты маршрута по shape_id"
  def shape_id_coords(shape_id) do
    records()
    |> Enum.filter(fn row -> row.id == shape_id end)
    |> Enum.map(& &1.coords)
    |> Toolkit.geojson_string()
    |> IO.puts()
  end

  # @doc "3.1) Нет ли такого, что частоты pt_sequence не располагаются в порядке возрастания?"
  # def check_pt_sequence_order do
  #   shapes()
  #   |> Enum.group_by(& &1.id, & &1.pt_sequence)
  #   |> Enum.map_reduce(false, fn {x, false} -> x and false end)
  # end
end
