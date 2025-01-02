defmodule FeedWeb.Schema do
  use Absinthe.Schema

  import_types(FeedWeb.Schema.{
    RouteTypes,
    StopTypes,
    TripTypes
  })

  alias FeedWeb.{
    RouteResolver,
    StopResolver,
    TripResolver
  }

  query do
    @desc "Show stops within the radius specified"
    field :stops_nearby, list_of(:stop) do
      arg(:search, :string, default_value: "")
      arg(:radius, :integer, default_value: 1500)
      arg(:types, list_of(:string), default_value: [])
      arg(:coords, list_of(:float), default_value: [30.336146, 59.934243])
      resolve(&StopResolver.stops_within_radius/3)
    end

    @desc "Show routes with distance greater then @dist"
    field :routes_dist_gt, list_of(:route) do
      arg(:dist_gt, :integer, default_value: 1500)
      arg(:search, :string, default_value: "")
      arg(:types, list_of(:string), default_value: [])
      arg(:day, :string, default_value: :tuesday)
      resolve(&RouteResolver.routes_dist_gt/3)
    end

    @desc "Show routes that cross the stop at day specified"
    field :routes_over_stop, list_of(:route) do
      arg(:stop_id, :integer, default_value: 18840)
      arg(:day, :string, default_value: :tuesday)
      resolve(&RouteResolver.routes_over_stop/3)
    end

    @desc "Show routes that cross the stop at day specified"
    field :hourly_mean_arrival, list_of(:route) do
      arg(:stop_id, :integer, default_value: 18840)
      arg(:day, :string, default_value: :tuesday)
      resolve(&RouteResolver.hourly_mean_arrival/3)
    end
  end
end
