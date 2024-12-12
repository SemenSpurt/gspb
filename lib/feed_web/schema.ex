defmodule FeedWeb.Schema do
  use Absinthe.Schema

  alias FeedWeb.{
    RouteResolver,
    StopResolver,
    TripResolver
  }


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



  object :date do
    field :service_id, :integer
    field :date, :string
  end


  query do
    @desc "All stops"
    field :list_stops, list_of(:stop) do
      resolve(&StopResolver.list_stops/3)
    end

    @desc "All routes"
    field :list_routes, list_of(:route) do
      resolve(&RouteResolver.list_routes/3)
    end

    @desc "Route by id"
    field :get_route, :route do
      arg :route_id, :integer
      resolve(&RouteResolver.get_route/3)
    end

    @desc "Trips stops and tracks"
    field :trip_stops, list_of(:trip) do
      arg :trip_id, :integer
      resolve(&TripResolver.trip_stops/3)
    end

    @desc "Trips on route by date"
    field :route_trips, list_of(:trip) do
      arg :route_id, :integer
      arg :date, :string
      resolve(&TripResolver.route_trips!/3)
    end

  end
end
