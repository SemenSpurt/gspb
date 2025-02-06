defmodule Feed.Services.Toolkit do
  import Ecto.Query

  @doc "Count unique values in table column"
  def count_uniq_in(table, column) do
    table
    |> Enum.uniq_by(& &1[column])
    |> Enum.count()
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
      for(
        <<
          y::binary-size(4),
          m::binary-size(2),
          d::binary-size(2) <- date_string
        >>,
        do: "#{y}-#{m}-#{d}"
      ),
      0
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

  def dist_between_points(coords) do
    earth_radius = 6_371_210
    uno_degree = Math.pi() / 180

    [
      [lat1, lon1],
      [lat2, lon2]
    ] =
      coords
      |> Enum.map(&Enum.map(&1, fn x -> x * uno_degree end))

    dlat = lat2 - lat1
    dlon = lon2 - lon1

    a =
      Math.sin(dlat / 2) ** 2 +
        Math.cos(lat1) *
          Math.cos(lat2) *
          Math.sin(dlon / 2) ** 2

    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))

    earth_radius * c
  end

  def rm_except_zip_in_src(path \\ "src") do
    File.ls!(path)
    |> Enum.filter(&(not String.ends_with?(&1, ".zip")))
    |> Enum.map(&Path.expand(&1, path))
    |> Enum.map(&File.rm_rf!(&1))
  end

  def list_zip_in_src(path \\ "src") do
    File.ls!(path)
    |> Enum.filter(&String.ends_with?(&1, ".zip"))
    |> Enum.map(&Path.expand(&1, path))
  end

  def str_to_weekday(date) do
    date
    |> Date.from_iso8601!()
    |> Calendar.Date.day_of_week_name()
    |> String.downcase()
    |> String.to_atom()
  end

  def rollback_feed_migrations(prefix \\ Date.utc_today() |> to_string) do
    Ecto.Migrator.run(
      Feed.Repo,
      [
        {20_250_104_101_509, Feed.Storage.Migrations.CreateCalendar},
        {20_250_104_104_252, Feed.Storage.Migrations.CreateTrips},
        {20_250_104_104_157, Feed.Storage.Migrations.CreateStopTimes}
      ],
      :down,
      Keyword.put([prefix: prefix], :all, true)
    )
  end

  def create_table(name) do
    Feed.Repo.query("""
    CREATE TABLE IF NOT EXISTS #{name} (
      vehicle_id int,
      direction_id boolean,
      timestamp timestamp,
      position geography,
      order_num int,
      plate varchar(20),
      label varchar(20)
    );
    """)
  end

  def compute_smooth_tracks(direction, prefix \\ Date.utc_today() |> to_string) do
    Ecto.Migrator.run(
      Feed.Repo,
      [
        {20_250_130_111_113, Feed.Storage.Migrations.ProcessFeed}
      ],
      direction,
      Keyword.put([prefix: prefix], :all, true)
    )
  end

  def compute_route_stops(direction \\ :up) do
    Ecto.Migrator.run(
      Feed.Repo,
      [
        {20_250_131_163_430, Feed.Storage.Migrations.RouteStops}
      ],
      direction,
      Keyword.put([prefix: "2025-02-02"], :all, true)
    )

    # Timex.today("GMT+3") |> to_string

    if direction == :up do
      query =
        from t in Feed.Ecto.Trip,
          join: st in Feed.Ecto.StopTime,
          on: st.trip_id == t.trip_id,
          join: s in Feed.Ecto.Stop,
          on: s.stop_id == st.stop_id,
          distinct: [
            t.route_id,
            t.direction_id,
            st.stop_sequence
          ],
          select: %{
            route_id: t.route_id,
            direction: t.direction_id,
            stop_num: st.stop_sequence,
            stop: s.coords
          }

      Feed.Repo.all(query)
      |> Enum.chunk_every(1000)
      |> Enum.each(&Feed.Repo.insert_all("route_stops", &1))
    end
  end

  def list_pg_tables(prefix \\ Date.utc_today() |> to_string) do
    Feed.Repo.query!("""
    SELECT
      table_schema, table_name
    FROM
      information_schema.tables
    ORDER BY
      table_schema, table_name;
    """).rows
    |> Enum.filter(fn [schema, _] ->
      schema == prefix
    end)
    |> Enum.map(&Enum.at(&1, 1))
  end

  def drop_prefix_tables(prefix) do
    list_pg_tables(prefix)
    |> Enum.each(
      &Feed.Repo.query!("""
      DROP TABLE IF EXISTS
        "#{prefix}".#{&1}
      CASCADE
      """)
    )
  end

  def drop_table(name) do
    Feed.Repo.query!("""
    DROP TABLE IF EXISTS
      #{name}
    CASCADE
    """)
  end

  def check_directions(route) do
    Feed.Handlers.route_directions(route)
    |> Enum.frequencies_by(& &1.direction)
  end

  def check_all_directions do
    list_pg_tables()
    |> Enum.filter(&String.contains?(&1, "route_"))
    |> Enum.map(&String.trim(&1, "route_"))
    |> Enum.map(&{&1, check_directions(&1)})
  end
end
