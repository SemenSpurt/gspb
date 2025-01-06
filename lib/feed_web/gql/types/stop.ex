defmodule FeedWeb.Types.Stop do
  use Absinthe.Schema.Notation
  alias FeedWeb.Gql.Resolvers.StopResolver

  object :stop do
    field :id, :id
    field :name, :string
    field :coords, :string
    field :transport, :string
  end

  @desc "Show stops within the radius specified"
  object :stop_queries do
    field :stops_nearby,
          non_null(list_of(non_null(:stop))) do
      arg :search, :string, default_value: ""
      arg :radius, :integer, default_value: 2500
      arg :types, list_of(:string), default_value: []
      arg :coords, list_of(:float), default_value: [30.336146, 59.934243]
      resolve &StopResolver.stops_within_radius/3
    end
  end
end
