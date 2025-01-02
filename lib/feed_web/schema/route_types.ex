defmodule FeedWeb.Schema.RouteTypes do
  use Absinthe.Schema.Notation

  object :route do
    field :id, :id
    field :short_name, :string
    field :long_name, :string
    field :transport, :string
    field :circular, :boolean
    field :urban, :boolean
  end
end
