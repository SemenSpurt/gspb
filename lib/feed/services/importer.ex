defmodule Feed.Services.Importer do
  alias Feed.{
    Repo,
    Ecto,
    Services.Toolkit,
    Services.Research
  }

  # Import multiple feeds regarding to their date of origin
  def import_all(path \\ "src") do
    # Clean up src dir
    Toolkit.rm_except_zip_in_src(path)

    # List feed.zip files, unzip subsequently
    Toolkit.list_zip_in_src(path)
    |> Enum.each(&Toolkit.unzip_one(&1))

    # List uziped folders
    # Run import function for each feed folder
    File.ls!(path)
    |> Enum.filter(&(not String.ends_with?(&1, ".zip")))
    |> Enum.map(&Path.expand(&1, path))
    |> Enum.each(&import_feed(&1))

    # Clean up src dir
    Toolkit.rm_except_zip_in_src(path)
  end

  @date "2024-11-10"

  def import_feed(feed_dir_path, date \\ @date) do
    ## WEEK AND CALENDAR
    # Import week schedules in distinct table
    weekday = Toolkit.weekday_atom_from_date(date)
    records = Research.Calendar.records(feed_dir_path)

    service_names =
      records
      |> Enum.map(
        &Map.take(&1, [
          :monday,
          :tuesday,
          :wednesday,
          :thursday,
          :friday,
          :saturday,
          :sunday,
          :name
        ])
      )
      |> Enum.filter(& &1[weekday])
      |> Enum.uniq_by(& &1.name)
      |> Enum.chunk_every(1)
      |> Enum.map(
        &Repo.insert_all(
          Ecto.Calendar.Week,
          &1,
          on_conflict: :replace_all,
          conflict_target: [:name],
          returning: true
        )
      )
      |> Enum.flat_map(&elem(&1, 1))
      |> Enum.map(& &1.name)

    service_ids =
      records
      |> Enum.map(
        &Map.take(&1, [
          :service_id,
          :start_date,
          :end_date,
          :name
        ])
      )
      |> Enum.filter(&(&1.name in service_names))
      |> Enum.chunk_every(1000)
      |> Enum.map(
        &Repo.insert_all(
          Ecto.Calendar.Calendar,
          &1,
          on_conflict: :replace_all,
          conflict_target: :service_id,
          returning: true
        )
      )
      |> Enum.flat_map(&elem(&1, 1))
      |> Enum.map(& &1.service_id)

    ## TRACKS
    # Import only tracks binded to trips
    track_ids =
    Research.Shapes.records(feed_dir_path)
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
        on_conflict: :replace_all,
        conflict_target: :track_id,
        returning: true
      )
    )
    |> Enum.flat_map(&elem(&1, 1))
    |> Enum.map(& &1.track_id)

    ## TRIPS
    # Import trips for filtered service_id, keep trip_ids
    [trip_ids, route_ids] =
      Research.Trips.records(feed_dir_path)
      |> Enum.filter(& &1.service_id in service_ids)
      |> Enum.filter(& &1.track_id in track_ids)
      |> Enum.chunk_every(1000)
      |> Enum.map(
        &Repo.insert_all(
          Ecto.Trips.Trip,
          &1,
          on_conflict: :replace_all,
          conflict_target: :id,
          returning: true
        )
      )
      |> Enum.flat_map(&elem(&1, 1))
      |> Enum.map(&Map.from_struct(&1))
      |> Enum.map(&[&1.id, &1.route_id])
      |> Enum.zip_with(&Enum.uniq(&1))

    ## ROUTES
    # Import only binded routes
    Research.Routes.records(feed_dir_path)
    |> Enum.filter(&(&1.id in route_ids))
    |> Enum.chunk_every(1000)
    |> Enum.each(
      &Repo.insert_all(
        Ecto.Routes.Route,
        &1,
        on_conflict: :nothing,
        returning: false
      )
    )

    ## STOP TIMES
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

    ## STOPS
    # Import stops from stop_ids
    Research.Stops.records(feed_dir_path)
    |> Enum.filter(&(&1.id in stop_ids))
    |> Enum.chunk_every(1000)
    |> Enum.each(
      &Repo.insert_all(
        Ecto.Stops.Stop,
        &1,
        on_conflict: :nothing,
        returning: false
      )
    )

    ## STAGES
    # Import only stages binded to stop_times
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
    |> Enum.each(
      &Repo.insert_all(
        Ecto.Shapes.Stage,
        &1,
        on_conflict: :nothing,
        returning: false
      )
    )
  end
end
