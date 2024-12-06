defmodule FeedWeb.TripResolver do
  alias Feed.Trips

  def trip_stops(_root, %{trip_id: trip_id}, _info) do
    {:ok, Trips.trip_stops(trip_id)}
  end
end
