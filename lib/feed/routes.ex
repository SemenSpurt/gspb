defmodule Feed.Routes do
  @moduledoc """
  The Routes context.
  """

  import Ecto.Query, warn: false
  alias Feed.Repo

  alias Feed.Routes.Route

  @doc """
  Returns the list of routes.

  ## Examples

      iex> list_routes()
      [%Route{}, ...]

  """
  def list_routes do
    Repo.all(Route)
    # |> Repo.preload([:trips])
  end

  def route_trips(route_id) do
    get_route(route_id)
    |> Repo.preload([dates: [:trips]])
  end

  @doc """
  Gets a single route.

  Raises `Ecto.NoResultsError` if the Route does not exist.

  ## Examples

      iex> get_route!(123)
      %Route{}

      iex> get_route!(456)
      ** (Ecto.NoResultsError)

  """
  def get_route(route_id) do
    Repo.all(Route)
    |> Enum.find(fn(item) -> Map.get(item, :route_id) === route_id end)
    # |> Repo.preload([:trips])
  end

  @doc """
  Creates a route.

  ## Examples

      iex> create_route(%{field: value})
      {:ok, %Route{}}

      iex> create_route(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_route(attrs \\ %{}) do
    %Route{}
    |> Route.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a route.

  ## Examples

      iex> update_route(route, %{field: new_value})
      {:ok, %Route{}}

      iex> update_route(route, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_route(%Route{} = route, attrs) do
    route
    |> Route.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a route.

  ## Examples

      iex> delete_route(route)
      {:ok, %Route{}}

      iex> delete_route(route)
      {:error, %Ecto.Changeset{}}

  """
  def delete_route(%Route{} = route) do
    Repo.delete(route)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking route changes.

  ## Examples

      iex> change_route(route)
      %Ecto.Changeset{data: %Route{}}

  """
  def change_route(%Route{} = route, attrs \\ %{}) do
    Route.changeset(route, attrs)
  end

  def import(attrs \\ %{}) do
    # %Route{}
    # |> Route.changeset(attrs)
    # |> Repo.insert()
    Task.async_stream(attrs, fn one -> %Route{} |> Route.changeset(one) |> Repo.insert end)
    |> Stream.run()
  end
end
