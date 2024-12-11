defmodule Feed.Time.WeekFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Feed.Week` context.
  """

  @doc """
  Generate a days.
  """
  def days_fixture(attrs \\ %{}) do
    {:ok, days} =
      attrs
      |> Enum.into(%{
        end_date: ~D[2024-11-24],
        friday: true,
        monday: true,
        saturday: true,
        service_id: "some service_id",
        service_name: "some service_name",
        start_date: ~D[2024-11-24],
        sunday: true,
        thursday: true,
        tuesday: true,
        wednesday: true
      })
      |> Feed.Time.Week.create_days()

    days
  end
end
