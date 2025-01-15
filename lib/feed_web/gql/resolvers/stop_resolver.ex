defmodule FeedWeb.Gql.Resolvers.StopResolver do
  alias Feed.Services.Handlers

  def stops_within_radius(_root, args, _info) do
    {:ok, Handlers.stops_within_radius(args)}
  end
end
