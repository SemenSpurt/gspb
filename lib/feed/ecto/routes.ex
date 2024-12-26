defmodule Feed.Ecto.Routes do
  import Ecto.Query, warn: false

  alias Feed.{
    Repo,
    # Ecto.Dates.Date,
    Ecto.Trips.Trip,
  }

  defmodule Route do
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key {:id, :integer, autogenerate: false}
    schema "routes" do
      field :short_name, :string
      field :long_name,  :string
      field :transport,  :string
      field :circular,   :boolean
      field :urban,      :boolean

      has_many :trips, Trip,
        foreign_key: :route_id,
        references: :id

      # many_to_many :dates, Date,
      #   join_through: Trip,
      #   join_keys: [
      #     route_id: :id,
      #     service_id: :service_id
      #   ],
      #   preload_order: [asc: :date]

      timestamps(type: :utc_datetime)
    end

    @doc false
    def changeset(route, attrs) do
      route
      |> cast(attrs, [
        :id,
        :short_name,
        :long_name,
        :transport,
        :circular,
        :urban
      ])
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


  def get_route(id) do
    Repo.all(Route)
    |> Enum.find(fn(item) -> Map.get(item, :id) === id end)
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

  def import_records(records \\ %{}) do
    Repo.insert_all(Route, records)
  end
end
