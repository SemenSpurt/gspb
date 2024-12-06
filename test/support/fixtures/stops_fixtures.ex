defmodule Feed.StopsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Feed.Stops` context.
  """

  @doc """
  Generate a stop.
  """
  def stop_fixture(attrs \\ %{}) do
    {:ok, stop} =
      attrs
      |> Enum.into(%{
        location_type: 42,
        stop_code: 42,
        stop_id: 42,
        stop_lat: 120.5,
        stop_lon: 120.5,
        stop_name: "some stop_name",
        transport_type: "some transport_type",
        wheelchair_boarding: 42
      })
      |> Feed.Stops.create_stop()

    stop
  end
end
