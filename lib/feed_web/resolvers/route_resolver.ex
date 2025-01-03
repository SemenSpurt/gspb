defmodule FeedWeb.RouteResolver do
  alias Feed.Ecto.Routes

  def routes_dist_gt(_root, args, _info) do
    {:ok, Routes.routes_dist_gt(args)}
  end

  def routes_over_stop(_root, args, _info) do
    {:ok, Routes.routes_over_stop(args)}
  end

  def hourly_mean_arrival(_root, args, _info) do
    {:ok, Routes.hourly_mean_arrival(args)}
  end

  def routes_between_two_stops(_root, args, _info) do
    {:ok, Routes.routes_between_two_stops(args)}
  end

  def route_substitutions(_root, args, _info) do
    {:ok, Routes.route_substitutions(args)}
  end
end
