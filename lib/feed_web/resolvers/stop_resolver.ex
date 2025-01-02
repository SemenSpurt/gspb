defmodule FeedWeb.StopResolver do
  alias Feed.Ecto.Stops

  def stops_within_radius(_root, args, _info) do
    {:ok, Stops.stops_within_radius(args)}
  end
end
