defmodule FeedWeb.Schema do
  use Absinthe.Schema

  alias FeedWeb.{
    RouteResolver,
    StopResolver,
    TripResolver,
    # DateResolver
  }
  # alias Feed.Stops
  # alias Feed.Trips
  # import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  object :route do
    field :route_id, :integer
    field :agency_id, :string
    field :route_short_name, :string
    field :route_long_name, :string
    field :route_type, :integer
    field :transport_type, :string
    field :circular, :boolean
    field :urban, :boolean
    field :night, :boolean

  end

  object :stop do
    field :stop_id, :integer
    field :stop_code, :integer
    field :stop_name, :string
    field :stop_lat, :float
    field :stop_lon, :float
    field :location_type, :integer
    field :wheelchair_boarding, :integer
    field :transport_type, :string
  end

  object :trip do
    field :trip_id, :integer
    field :route_id, :integer
    field :service_id, :integer
    field :times, list_of(:time)
  end

  object :time do
    field :stop_id, :integer
    field :stop_sequence, :integer
    field :arrival_time, :string
    field :stop, :stop
    field :shape_id, :string
    field :shapes, list_of(:shape)
  end

  object :shape do
    field :shape_id, :string
    field :shape_pt_lat, :float
    field :shape_pt_lon, :float
    field :shape_pt_sequence, :integer
  end

  object :route_trips do
    field :route_id, :integer
    field :route_short_name, :string
    field :route_long_name, :string
    field :dates, list_of(:date)
  end

  object :date do
    field :service_id, :integer
    field :date, :string
    field :trips, list_of(:only_trips)
  end

  object :only_trips do
    field :trip_id, :integer
  end

  query do
    @desc "All stops"
    field :list_stops, non_null(list_of(non_null(:stop))) do
      resolve(&StopResolver.list_stops/3)
    end

    @desc "All routes"
    field :list_routes, non_null(list_of(non_null(:route))) do
      resolve(&RouteResolver.list_routes/3)
    end

    @desc "Route by id"
    field :get_route, :route do
      arg :route_id, :integer
      resolve(&RouteResolver.get_route/3)
    end

    @desc "Trips on route by date"
    field :trips_on_route, :route_trips do
      arg :route_id, :integer
      resolve(&RouteResolver.route_trips/3)
    end

    @desc "Trips stops and tracks"
    field :trip_stops, :trip do
      arg :trip_id, :integer
      resolve(&TripResolver.trip_stops/3)
    end

  end

end
