defmodule FeedWeb.TripResolver do
  alias Feed.Route.Trips

  def trip_stops(_root, %{trip_id: trip_id}, _info) do
    {:ok, Trips.trip_stops(trip_id)}
  end

  def route_trips!(_root, %{route_id: route_id, date: date}, _info) do
    {:ok, Trips.route_trips(route_id, date)}
    # Trips.route_trips(route_id, date)
  end
end
