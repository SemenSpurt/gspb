defmodule Feed.TripsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Feed.Trips` context.
  """

  @doc """
  Generate a trip.
  """
  def trip_fixture(attrs \\ %{}) do
    {:ok, trip} =
      attrs
      |> Enum.into(%{
        direction_id: true,
        route_id: 42,
        service_id: 42,
        shape_id: "some shape_id",
        trip_id: 42
      })
      |> Feed.Trips.create_trip()

    trip
  end
end
