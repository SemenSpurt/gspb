defmodule Feed.GenServer.FeedDownload do
  use GenServer, restart: :permanent, shutdown: 1000 * 60 * 60 * 24

  alias Feed.Services.Import

  @url "https://transport.orgp.spb.ru/Portal/transport/internalapi/gtfs/feed.zip"

  # Client

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  # Server (callbacks)

  @impl true
  def init(state) do
    schedule_work()
    {:ok, state}
  end

  @impl true
  def handle_info(:get, state) do
    # Do the desired work here
    src = "src/"
    prefix = Timex.today("GMT+3") |> to_string()

    File.ls!(src)
    |> Enum.filter(&(not String.contains?(&1, prefix)))
    |> Enum.map(&Path.expand([src, &1]))
    |> Enum.map(&File.rm_rf!(&1))

    if Timex.now("GMT+3") > Time.from_iso8601!("06:00:00") do
      file = prefix <> ".zip"

      if file not in File.ls!(src) do
        unzip_to = src <> prefix

        ## LOAD
        # curl file to the src/{prefix}.zip
        System.cmd("curl", ["-k", @url, "-o", src <> file])

        ## UNZIP
        # src/{prefix}.zip -> src/{prefix}
        :zip.unzip(~c"#{src <> file}", [{:cwd, ~c"#{unzip_to}"}])

        ## PREPARE DB
        # Feed origin date -> db schema prefix
        Feed.Repo.query("""
        CREATE SCHEMA IF NOT EXISTS "#{prefix}"
        """)

        # Run migrations to target schema
        Ecto.Migrator.run(
          Feed.Repo,
          [
            {20_250_104_101_509, Feed.Storage.Migrations.CreateCalendar},
            {20_250_104_104_252, Feed.Storage.Migrations.CreateTrips},
            {20_250_104_104_157, Feed.Storage.Migrations.CreateStopTimes}
          ],
          :up,
          Keyword.put([prefix: prefix], :all, true)
        )

        ### IMPORT FEED

        ## CALENDAR
        # Import only valid service_ids
        service_ids = Import.Calendar.import(unzip_to, prefix)

        ## STOP
        # Import stops from stop_ids
        stop_ids = Import.Stop.import(unzip_to)

        ## TRIP
        # Import trips for filtered service_id and rotues,
        # keep trip_ids and track_ids
        [
          route_ids,
          trip_ids,
          track_ids
        ] = Import.Trip.import(unzip_to, service_ids)

        ## STOP TIME
        # Import stop_times by trip_ids and stop_ids
        Import.StopTime.import(unzip_to, trip_ids, stop_ids)

        ## TRACK
        # Import only tracks binded to trip_ids
        Import.Track.import(unzip_to, track_ids)

        ## ROUTE
        # Import routes
        Import.Route.import(unzip_to, route_ids)

        ## STAGE
        # Import only stages binded to stop_times
        Import.Stage.import(unzip_to)
      end
    end

    # Reschedule once more
    schedule_work()

    {:noreply, state}
  end

  defp schedule_work do
    Process.send_after(self(), :get, 1000 * 60 * 1)
  end
end
