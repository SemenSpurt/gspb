defmodule FeedWeb.Schema.TripTypes do
  use Absinthe.Schema.Notation

  object :trip do
    field :id, :id
    field :route_id, :integer
    field :service_id, :integer
    # field :times, list_of(:time)
  end
end
