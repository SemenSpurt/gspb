defmodule ShapeParser do

  alias FileParser
  alias Toolkit

  # """
  # shape_id:             string
  # shape_pt_lat:         float
  # shape_pt_lon:         float
  # shape_pt_sequence:    integer
  # shape_dist_traveled:  float
  # """


  def shapes(file_path \\ "C:/Users/SamJa/Desktop/Notebooks/feed/shapes.txt") do
    file_path
    |> File.stream!()
    |> FileParser.parse_stream()
    |> Enum.map(
      fn [
        id,
        pt_lat,
        pt_lon,
        pt_sequence,
        dist_traveled
      ] -> %{
        id: id,
        coords: [
          String.to_float(pt_lon),
          String.to_float(pt_lat)
        ],
        pt_sequence: String.to_integer(pt_sequence),
        dist_traveled: String.to_float(dist_traveled)
      }
    end)
  end


  @doc "0) Как много записей в таблице shapes?"
  def count_table_records, do: shapes() |> Enum.count()
  # 933327


  @doc "1) Сколько всего уникальных shape_id?"
  def count_uniq_id, do: shapes() |> Toolkit.count_uniq_in(:id)
  # 28403


  @doc "1.1) Какие различные префиксы вcтречаются среди значений shape_id?"
  def shape_id_prefixies do
    shapes()
    |> Enum.frequencies_by(
      & &1.id
      |> String.split("-")
      |> Enum.at(0)
    )
  end
  # %{"stage" => 479806, "track" => 453521}


  @doc "2) Сколько всего уникальных координат?"
  def count_uniq_coords, do: shapes() |> Toolkit.count_uniq_in(:coords)
  # 182459


  @doc "3) Нет ли пропущенных или лишних pt_sequence?"
  def check_pt_sequence do

    freqs =
      shapes()
      |> Enum.frequencies_by(& &1.pt_sequence)
      |> Enum.sort_by(&elem(&1, 1), :desc)

    len = Enum.count(freqs)

    [
      Enum.slice(freqs, 0, len - 1),
      Enum.slice(freqs, -len + 1, len),
    ]
    |> Enum.zip_with(fn [a, b] -> not a >= b end)
    |> Enum.any?() # maybe better

  end
  # 2110


  @doc "3.1) Нет ли такого, что частоты pt_sequence не располагаются в порядке возрастания?"
  def check_pt_sequence_order do
    shapes()
    |> Enum.group_by(& &1.id, & &1.pt_sequence)
    |> Enum.map
  end




end
