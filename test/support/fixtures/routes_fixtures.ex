defmodule Feed.Route.RoutesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Feed.Routes` context.
  """

  @doc """
  Generate a route.
  """
  def route_fixture(attrs \\ %{}) do
    {:ok, route} =
      attrs
      |> Enum.into(%{
        agency_id: 42,
        circular: true,
        night: true,
        route_id: 42,
        route_long_name: "some route_long_name",
        route_short_name: "some route_short_name",
        route_type: 42,
        transport_type: 42,
        urban: true
      })
      |> Feed.Route.Routes.create_route()

    route
  end
end
