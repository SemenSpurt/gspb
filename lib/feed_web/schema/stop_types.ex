defmodule FeedWeb.Schema.StopTypes do
  use Absinthe.Schema.Notation

  object :stop do
    field :id, :id
    field :name, :string
    field :coords, :string
    field :transport, :string
  end
end
