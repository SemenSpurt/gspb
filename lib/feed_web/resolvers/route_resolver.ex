defmodule FeedWeb.RouteResolver do
  alias Feed.Route.Routes

  def list_routes(_root, _args, _info) do
    {:ok, Routes.list_routes()}
  end

  def get_route(_root, %{route_id: route_id}, _info) do
    {:ok, Routes.get_route(route_id)}
  end

  def route_trips(_root, %{route_id: route_id}, _info) do
    {:ok, Routes.route_trips(route_id)}
  end
end
