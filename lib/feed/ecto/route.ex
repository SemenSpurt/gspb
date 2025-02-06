defmodule Feed.Ecto.Route do
  import Ecto.Query, warn: false
  import Ecto.Changeset
  use Ecto.Schema

  alias Feed.Ecto.Trip

  @primary_key {:route_id, :integer, autogenerate: false}
  schema "routes" do
    field :short_name, :string
    field :long_name, :string
    field :transport, :string
    field :circular, :boolean
    field :urban, :boolean

    has_many :trips, Trip,
      foreign_key: :route_id,
      references: :route_id
  end

  def changeset(route, attrs) do
    route
    |> cast(
      attrs,
      [
        :route_id,
        :short_name,
        :long_name,
        :transport,
        :circular,
        :urban
      ]
    )
    |> validate_required([
      :route_id,
      :short_name,
      :long_name,
      :transport,
      :circular,
      :urban
    ])
  end
end
