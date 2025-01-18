defmodule FeedWeb.Types.Route do
  use Absinthe.Schema.Notation
  alias FeedWeb.Gql.Resolvers.RouteResolver

  object :route do
    field :id, :id
    field :short_name, :string
    field :long_name, :string
    field :transport, :string
    field :circular, :boolean
    field :urban, :boolean
  end

  object :trip_frequencies do
    field :hour, :integer
    field :interval, :float
  end

  object :route_inspection do
    field :plan_trips, list_of(:trip_edges)
    field :actual_trips, list_of(:trip_edges)
  end

  object :trip_edges do
    field :trip_id, :integer
    field :start, :string
    field :finish, :string
  end

  object :trip_inspection do
    field :order, :integer
    field :plan_time, :string
    field :actual_time, :string
  end

  object :route_queries do
    @desc "Show routes with distance greater then @dist"
    field :routes_dist_gt,
          non_null(list_of(non_null(:route))) do
      arg :dist_gt, :integer, default_value: 1_550_500
      arg :search, :string, default_value: "пdfdf"
      arg :types, list_of(:string), default_value: []
      arg :day, :string, default_value: "2023-09-02"
      resolve &RouteResolver.routes_dist_gt/3
    end

    @desc "Show routes that cross the stop at day specified"
    field :routes_over_stop,
          non_null(list_of(non_null(:route))) do
      arg :stop_id, :integer, default_value: 17998
      arg :day, :string, default_value: "2024-09-02"
      resolve &RouteResolver.routes_over_stop/3
    end

    @desc "Show routes mean arrival interval on stop specified"
    field :route_average_interval,
          non_null(list_of(non_null(:trip_frequencies))) do
      arg :route_id, :integer, default_value: 3812
      arg :stop_id, :integer, default_value: 40382
      arg :day, :string, default_value: "2024-09-02"
      resolve &RouteResolver.route_average_interval/3
    end

    @desc "Show routes that go throught two subsequent stops"
    field :routes_between_two_stops,
          non_null(list_of(non_null(:route))) do
      arg :stop_id1, :integer, default_value: 31925
      arg :stop_id2, :integer, default_value: 27774
      arg :day, :string, default_value: "2023-09-02"
      resolve &RouteResolver.routes_between_two_stops/3
    end

    @desc "Show routes that have similarity percent"
    field :route_substitutions,
          non_null(list_of(non_null(:route))) do
      arg :route_id, :integer, default_value: 9286
      arg :percent, :integer, default_value: 75
      arg :day, :string, default_value: "2024-06-16"
      resolve &RouteResolver.route_substitutions/3
    end

    @desc """
    Return two lists:
    1) Plan trips with start and finish times
    2) Actual trips with start and finish times
    """
    field :inspect_route,
          non_null(list_of(non_null(list_of(non_null(:route_inspection))))) do
      arg :route_id, :integer, default_value: 1266
      arg :day, :string, default_value: "2024-11-09"
      arg :start_time, :string, default_value: "19:20:00"
      arg :end_time, :string, default_value: "21:30:00"
      resolve &RouteResolver.inspect_route/3
    end

    @desc """
    Return two lists:
    1) Plan trips with start and finish times
    2) Actual trips with start and finish times
    """
    field :inspect_trip,
          non_null(list_of(non_null(list_of(non_null(:trip_inspection))))) do
      arg :trip_id, :integer, default_value: 64_883_593
      resolve &RouteResolver.inspect_trip/3
    end
  end
end
