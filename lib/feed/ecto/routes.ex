defmodule Feed.Ecto.Routes do
  import Ecto.Query, warn: false

  alias Feed.{
    Repo,
    Ecto.Trips.Trip
  }

  defmodule Route do
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key {:id, :integer, autogenerate: false}
    schema "routes" do
      field :short_name, :string
      field :long_name, :string
      field :transport, :string
      field :circular, :boolean
      field :urban, :boolean

      has_many :trips, Trip,
        foreign_key: :route_id,
        references: :id
    end

    def changeset(route, attrs) do
      route
      |> cast(
        attrs,
        [
          :id,
          :short_name,
          :long_name,
          :transport,
          :circular,
          :urban
        ]
      )
      |> validate_required([
        :id,
        :short_name,
        :long_name,
        :transport,
        :circular,
        :urban
      ])
    end
  end

  def list_routes do
    Repo.all(Route)
  end
end
