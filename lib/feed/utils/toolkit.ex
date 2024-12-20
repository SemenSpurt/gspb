defmodule Toolkit do
  alias Time

  @doc "Count unique values in table column"
  def count_uniq_in(table, column) do
    table
    |> Enum.uniq_by(& &1[column])
    |> Enum.count()
  end


  @doc "Check for noninteger values in column"
  def check_nonintegers_in(table, column) do
    table
    |> Enum.any?(& not is_integer(&1[column]))
  end


  @doc "Get time from values greater then 24 hours"
  def time_from_seconds_after_midnight(time_str) do
    [hr, min, sec] =
      time_str
      |> String.split(":")
      |> Enum.map(&String.to_integer/1)

    Time.from_seconds_after_midnight(hr * 3600 + min * 60 + sec)
  end


  @doc "Parse date from string in 'YYYYMMDD' format"
  def date_from_reverse_string(date_string) do
    Enum.at(
      (for <<
      y::binary-size(4),
      m::binary-size(2),
      d::binary-size(2) <- date_string
      >>, do: "#{y}-#{m}-#{d}"), 0
    )
    |> Date.from_iso8601!()

  end


  @doc "Goejson.io string tamplete"
  def geojson_string(coords \\ []) do
    %{
      type: "FeatureCollection",
      features: [
        %{
          type: "Feature",
          geometry: %{
              type: "MultiPoint",
              coordinates: coords
            },
          properties: %{}
        }
      ]
    }
    |> Jason.encode!()
  end

end
