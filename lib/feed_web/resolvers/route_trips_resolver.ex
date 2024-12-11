defmodule FeedWeb.RouteTripsResolver do
  alias Feed.Route.Routes

  def route_trips(_root, %{route_id: route_id}, _info) do
    {:ok, Routes.route_trips(route_id)}
  end
end
