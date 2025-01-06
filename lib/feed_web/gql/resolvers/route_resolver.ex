defmodule FeedWeb.Gql.Resolvers.RouteResolver do
  alias Feed.Handlers

  def routes_dist_gt(_root, args, _info) do
    {:ok, Handlers.routes_dist_gt(args)}
  end

  def routes_over_stop(_root, args, _info) do
    {:ok, Handlers.routes_over_stop(args)}
  end

  def hourly_mean_arrival(_root, args, _info) do
    {:ok, Handlers.hourly_mean_arrival(args)}
  end

  def routes_between_two_stops(_root, args, _info) do
    {:ok, Handlers.routes_between_two_stops(args)}
  end

  def route_substitutions(_root, args, _info) do
    {:ok, Handlers.route_substitutions(args)}
  end
end
