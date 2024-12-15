defmodule Feed.Route.Routes do
  import Ecto.Query, warn: false
  alias Feed.Repo

  alias Feed.{
    Time.Dates.Date,
    Route.Trips.Trip,
  }

  defmodule Route do
    use Ecto.Schema
    import Ecto.Changeset


    schema "routes" do
      field :route_id, :integer
      field :agency_id, :string
      field :route_short_name, :string
      field :route_long_name, :string
      field :route_type, :integer
      field :transport_type, :string
      field :circular, :boolean
      field :urban, :boolean
      field :night, :boolean

      has_many :trips, Trip,
        foreign_key: :route_id,
        references: :route_id

      many_to_many :dates, Date,
        join_through: Trip,
        join_keys: [
          route_id: :route_id,
          service_id: :service_id
        ],
        preload_order: [asc: :date]

      timestamps(type: :utc_datetime)
    end

    @doc false
    def changeset(route, attrs) do
      route
      |> cast(attrs, [
        :route_id,
        :agency_id,
        :route_short_name,
        :route_long_name,
        :route_type,
        :transport_type,
        :circular,
        :urban,
        :night
      ])
      |> validate_required([
        :route_id,
        :agency_id,
        :route_short_name,
        :route_long_name,
        :route_type,
        :transport_type,
        :circular,
        :urban,
        :night
      ])
    end
  end


  def list_routes do
    Repo.all(Route)
  end


  def get_route(route_id) do
    Repo.all(Route)
    |> Enum.find(fn(item) -> Map.get(item, :route_id) === route_id end)
  end

  def create_route(attrs \\ %{}) do
    %Route{}
    |> Route.changeset(attrs)
    |> Repo.insert()
  end

  def update_route(%Route{} = route, attrs) do
    route
    |> Route.changeset(attrs)
    |> Repo.update()
  end

  def delete_route(%Route{} = route) do
    Repo.delete(route)
  end


  def change_route(%Route{} = route, attrs \\ %{}) do
    Route.changeset(route, attrs)
  end

  def import(records \\ %{}) do

    Route
    |> Repo.insert_all(
      Enum.map(records, fn [
        route_id,
        agency_id,
        route_short_name,
        route_long_name,
        route_type,
        transport_type,
        circular,
        urban,
        night
      ] ->
      %{
        :route_id           => String.to_integer(route_id),
        :agency_id          => agency_id,
        :route_short_name   => route_short_name,
        :route_long_name    => route_long_name,
        :route_type         => String.to_integer(route_type),
        :transport_type     => transport_type,
        :circular           => circular == "1",
        :urban              => urban == "1",
        :night              => night == "1",

        :inserted_at        => DateTime.utc_now(:second),
        :updated_at         => DateTime.utc_now(:second)
      }
      end)
    )
  end
end
