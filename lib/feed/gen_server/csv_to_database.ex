defmodule Feed.GenServer.CsvToDatabase do
  use GenServer, restart: :permanent, shutdown: 1000 * 60 * 60 * 24

  import Ecto.Query, warn: false

  alias Feed.{
    Repo,
    Handlers,
    Services.Toolkit,
    Services.Research
  }

  # Client

  def start_link(state) do
    GenServer.start_link(__MODULE__, state)
  end

  # Server (callbacks)
  @impl true
  def handle_cast({:put, key, value}, state) do
    {:noreply, Map.put(state, key, value)}
  end

  @impl true
  def handle_call({:get, key}, _from, state) do
    {:reply, Map.fetch!(state, key), state}
  end

  @impl true
  def init(state \\ %{}) do
    # Timex.today("GMT+3") |> to_string

    state = Map.put(state, :prefix, "2025-02-02")

    Repo.query!("""
    CREATE SCHEMA IF NOT EXISTS "#{state.prefix}"
    """)

    Ecto.Migrator.run(
      Feed.Repo,
      [
        {
          20_250_130_111_113,
          Feed.Storage.Migrations.RoutesRealSchedule
        }
      ],
      :up,
      Keyword.put([prefix: state.prefix], :all, true)
    )

    state =
      Map.put(
        state,
        :routes,
        Toolkit.list_pg_tables(state.prefix)
        |> Enum.filter(&String.contains?(&1, "route_"))
        |> Enum.map(&String.trim(&1, "route_"))
      )

    schedule_work()

    {:ok, state}
  end

  @impl true
  def handle_info(:get, state) do
    # Do the desired work here

    files = check_files_to_load()

    case files do
      [] ->
        (["3812"] ++ state.routes)
        |> Enum.map(
          &(%{
              route: &1,
              stime:
                last_time(&1)
                |> Repo.one()
            }
            |> Handlers.trip()
            |> import_new())
        )

      _ ->
        files
        |> Enum.map(&Path.expand(&1, "temp"))
        |> Enum.map(&Research.Positions.records(&1))
        |> Enum.map(&insert_into_table(&1, state.prefix, state))

        files
        |> Enum.map(&Path.expand(&1, "temp"))
        |> Enum.map(&File.rm_rf!(&1))
    end

    # Reschedule once more
    schedule_work()

    {:noreply, state}
  end

  defp schedule_work do
    Process.send_after(self(), :get, 1000 * 20 * 1)
  end

  defp import_new(records) do
    Repo.insert_all(
      "real_schedule",
      records,
      on_conflict: :nothing,
      conflict_target: [
        :route_id,
        :trip_id,
        :direction,
        :stime
      ]
    )
  end

  defp last_time(route) do
    from(
      t in "real_schedule",
      select: t.etime,
      where: t.route_id == ^route,
      order_by: [desc: t.etime],
      offset: 2,
      limit: 1
    )
  end

  def prepare_table(name) do
    Repo.query!("""
    CREATE TABLE IF NOT EXISTS
    #{name} (
      vehicle_id int,
      direction_id boolean,
      timestamp timestamp,
      position geography,
      order_num int,
      plate varchar(20),
      label varchar(20)
    );
    """)

    Repo.query!("""
    CREATE UNIQUE INDEX ON
    #{name} (vehicle_id, timestamp);
    """)

    Repo.query!("""
    CREATE UNIQUE INDEX ON
    #{name} (timestamp);
    """)
  end

  defp file_to_time(name) do
    name
    |> String.replace(".", ":")
    |> String.replace("csv", "00")
    |> NaiveDateTime.from_iso8601!()
  end

  defp check_files_to_load(path \\ "temp", threshold \\ 10) do
    File.ls!(path)
    |> Enum.filter(&String.ends_with?(&1, ".csv"))
    |> Enum.filter(
      &(NaiveDateTime.diff(Timex.now("GMT+3"), file_to_time(&1), :minute) > threshold)
    )
  end

  defp insert_into_table(records, prefix, state) do
    records
    |> Enum.group_by(
      & &1.route_id,
      &%{
        vehicle_id: &1.vehicle_id,
        direction_id: &1.direction_id,
        timestamp: &1.timestamp,
        position: &1.position,
        order_num: &1.order,
        plate: &1.plate,
        label: &1.label
      }
    )
    |> Enum.map(fn {route, positions} ->
      if route not in state.routes do
        prepare_table("\"#{prefix}\".route_#{route}")
        GenServer.cast(self(), {:put, :routes, [route | state.routes]})
        # GenServer.cast(self(), {:push, route})
      end

      positions
      |> Enum.chunk_every(1000)
      |> Enum.map(
        &Repo.insert_all(
          "route_#{route}",
          &1,
          on_conflict: :nothing,
          conflict_target: [
            :vehicle_id,
            :timestamp
          ]
        )
      )
    end)
  end
end
