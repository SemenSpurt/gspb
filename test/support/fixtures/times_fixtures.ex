defmodule Feed.TimesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Feed.Times` context.
  """

  @doc """
  Generate a time.
  """
  def time_fixture(attrs \\ %{}) do
    {:ok, time} =
      attrs
      |> Enum.into(%{
        arrival_time: ~T[14:00:00],
        departure_time: ~T[14:00:00],
        shape_dist_traveled: 120.5,
        shape_id: "some shape_id",
        stop_id: 42,
        stop_sequence: 42,
        trip_id: 42
      })
      |> Feed.Times.create_time()

    time
  end
end
