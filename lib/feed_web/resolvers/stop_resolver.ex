defmodule FeedWeb.StopResolver do
  alias Feed.Stops

  def list_stops(_root, _args, _info) do
    {:ok, Stops.list_stops()}
  end
end
