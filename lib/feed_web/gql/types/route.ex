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

  object :route_queries do
    @desc "Show routes with distance greater then @dist"
    field :routes_dist_gt,
          non_null(list_of(non_null(:route))) do
      arg :dist_gt, :integer, default_value: 2500
      arg :search, :string, default_value: "пр"
      arg :types, list_of(:string), default_value: []
      arg :day, :string, default_value: "2023-09-02"
      resolve &RouteResolver.routes_dist_gt/3
    end

    @desc "Show routes that cross the stop at day specified"
    field :routes_over_stop,
          non_null(list_of(non_null(:route))) do
      arg :stop_id, :integer, default_value: 17998
      arg :day, :string, default_value: "2023-09-02"
      resolve &RouteResolver.routes_over_stop/3
    end

    @desc "Show routes mean arrival interval on stop specified"
    field :hourly_mean_arrival,
          non_null(list_of(non_null(:trip_frequencies))) do
      arg :stop_id, :integer, default_value: 35807
      arg :day, :string, default_value: "2023-09-02"
      resolve &RouteResolver.hourly_mean_arrival/3
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
      arg :route_id, :integer, default_value: 1380
      arg :percent, :integer, default_value: 25
      arg :day, :string, default_value: "2023-09-02"
      resolve &RouteResolver.route_substitutions/3
    end
  end
end
