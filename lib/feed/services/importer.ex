defmodule Feed.Services.Importer do
  alias Feed.{
    Services.Imports,
    Services.Toolkit
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

  def import_feed(file_path, date \\ "2025-01-19") do
    ## WEEK
    # Import week schedules in distinct table
    service_names = Imports.Week.import(date)

    ## Calendar
    # Import only valid service_ids
    service_ids = Imports.Calendar.import(service_names)

    ## ROUTES
    # Import only binded routes
    route_ids = Imports.Route.import()

    ## TRACKS
    # Import all tracks
    track_ids = Imports.Track.import()

    ## TRIPS
    # Import trips for filtered service_id, keep trip_ids
    trip_ids = Imports.Trips.import(service_ids, route_ids, track_ids)

    ## STOPS
    # Import stops from stop_ids
    stop_ids = Imports.Stop.import()

    ## STAGES
    # Import all stages
    Imports.Stage.import()

    ## STOP TIMES
    # Import stop_times by trip_ids and stop_ids
    Imports.StopTime.import(trip_ids, stop_ids)
  end
end
