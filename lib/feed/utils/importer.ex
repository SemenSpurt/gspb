defmodule Feed.Utils.Importer do
  alias Feed.Repo

  alias Feed.Ecto
  alias Feed.Services.Research

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

  def unzip_one(file) do
    :zip.unzip(
      ~c"#{file}",
      [{:cwd, ~c"#{String.trim(file, ".zip")}"}]
    )
  end

  def get_date_from_filepath(feed) do
    feed
    |> String.trim("/")
    |> String.split("/")
    |> Enum.at(-1)
    |> String.trim("feed_")
    |> String.split(".")
    |> Enum.reverse()
    |> Enum.join("-")
    |> Date.from_iso8601!()
  end

  def import_feed(feed_dir_path \\ "C:/Users/SamJa/Desktop/gspb/src/feed_02.09.2023/") do
    date = get_date_from_filepath(feed_dir_path)

    weekday =
      date
      |> Calendar.Date.day_of_week_name()
      |> String.downcase()
      |> String.to_atom()

    # Import actual week days for feed
    service_type_names =
      Research.Calendar.records(feed_dir_path)
      |> Enum.map(
        &Map.take(
          &1,
          [
            :name,
            :monday,
            :tuesday,
            :wednesday,
            :thursday,
            :friday,
            :saturday,
            :sunday
          ]
        )
      )
      |> Enum.uniq_by(& &1.name)

    Repo.insert_all(
      Ecto.Calendar.Week,
      service_type_names,
      on_conflict: :nothing,
      returning: false
    )

    # Save service_names for feed
    type_names =
      service_type_names
      |> Enum.filter(& &1[weekday])
      |> Enum.map(& &1.name)

    # Import only target service_ids by service_name and end_date
    # Get service_ids back
    service_ids =
      Research.Calendar.records(feed_dir_path)
      |> Enum.map(
        &Map.take(
          &1,
          [
            :service_id,
            :start_date,
            :end_date,
            :name
          ]
        )
      )
      |> Enum.filter(&(&1.name in type_names and &1.end_date == date))
      |> Enum.chunk_every(1000)
      |> Enum.map(
        &Repo.insert_all(
          Ecto.Calendar.Calendar,
          &1,
          on_conflict: :nothing,
          returning: true
        )
      )
      |> Enum.at(0)
      |> elem(1)
      |> Enum.map(&Map.from_struct(&1))
      |> Enum.map(& &1.service_id)

    # Import trips for filtered service_id, keep trip_ids
    [trip_ids, route_ids, track_ids] =
      Research.Trips.records(feed_dir_path)
      |> Enum.filter(&(&1.service_id in service_ids))
      |> Enum.chunk_every(1000)
      |> Enum.map(
        &Repo.insert_all(
          Ecto.Trips.Trip,
          &1,
          on_conflict: :nothing,
          returning: true
        )
      )
      |> Enum.flat_map(&elem(&1, 1))
      |> Enum.map(&Map.from_struct(&1))
      |> Enum.map(&[&1.id, &1.route_id, &1.track_id])
      |> Enum.zip_with(&Enum.uniq(&1))

    # Import only binded routes
    Research.Routes.records(feed_dir_path)
    |> Enum.filter(&(&1.id in route_ids))
    |> Enum.chunk_every(1000)
    |> Enum.map(
      &Repo.insert_all(
        Ecto.Routes.Route,
        &1,
        on_conflict: :nothing,
        returning: false
      )
    )

    # Import only binded tracks
    Research.Shapes.records(feed_dir_path)
    |> Enum.filter(&(&1.shape_id in track_ids))
    |> Enum.group_by(& &1.shape_id, & &1.coords)
    |> Enum.map(fn {k, v} ->
      %{
        track_id: k,
        line: %Geo.LineString{coordinates: v}
      }
    end)
    |> Enum.chunk_every(1000)
    |> Enum.map(
      &Repo.insert_all(
        Ecto.Shapes.Track,
        &1,
        on_conflict: :nothing,
        returning: false
      )
    )

    # Import stop_times for trips from trip_ids
    [stop_ids, stage_ids] =
      Research.StopTimes.records(feed_dir_path)
      |> Enum.filter(&(&1.trip_id in trip_ids))
      |> Enum.chunk_every(1000)
      |> Enum.map(
        &Repo.insert_all(
          Ecto.StopTimes.StopTime,
          &1,
          on_conflict: :nothing,
          returning: true
        )
      )
      |> Enum.flat_map(&elem(&1, 1))
      |> Enum.map(&Map.from_struct(&1))
      |> Enum.map(&[&1.stop_id, &1.stage_id])
      |> Enum.zip_with(&Enum.uniq(&1))

    # Import stops from stop_ids
    Research.Stops.records(feed_dir_path)
    |> Enum.filter(&(&1.id in stop_ids))
    |> Enum.chunk_every(1000)
    |> Enum.map(
      &Repo.insert_all(
        Ecto.Stops.Stop,
        &1,
        on_conflict: :nothing,
        returning: false
      )
    )

    # Import only binded stages
    Research.Shapes.records(feed_dir_path)
    |> Enum.filter(&(&1.shape_id in stage_ids))
    |> Enum.group_by(& &1.shape_id, & &1.coords)
    |> Enum.map(fn {k, v} ->
      %{
        stage_id: k,
        line: %Geo.LineString{coordinates: v}
      }
    end)
    |> Enum.chunk_every(1000)
    |> Enum.map(
      &Repo.insert_all(
        Ecto.Shapes.Stage,
        &1,
        on_conflict: :nothing,
        returning: false
      )
    )
  end

  def import_all(path \\ "src") do
    rm_except_zip_in_src(path)

    list_zip_in_src(path)
    |> Enum.each(
      &(unzip_one(&1)))

    File.ls!(path)
    |> Enum.filter(& not String.ends_with?(&1, ".zip"))
    |> Enum.map(&Path.expand(&1, path))
    |> Enum.map(&import_feed(&1))

    rm_except_zip_in_src()
  end
end
