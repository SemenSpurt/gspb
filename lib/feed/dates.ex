defmodule Feed.Dates do
  @moduledoc """
  The Dates context.
  """

  import Ecto.Query, warn: false
  alias Feed.Repo

  alias Feed.Dates.Date

  @doc """
  Returns the list of dates.

  ## Examples

      iex> list_dates()
      [%Date{}, ...]

  """
  def list_dates do
    Repo.all(Date)
  end

  @doc """
  Gets a single date.

  Raises `Ecto.NoResultsError` if the Date does not exist.

  ## Examples

      iex> get_date!(123)
      %Date{}

      iex> get_date!(456)
      ** (Ecto.NoResultsError)

  """
  def get_date!(id), do: Repo.get!(Date, id)

  @doc """
  Creates a date.

  ## Examples

      iex> create_date(%{field: value})
      {:ok, %Date{}}

      iex> create_date(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_date(attrs \\ %{}) do
    %Date{}
    |> Date.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a date.

  ## Examples

      iex> update_date(date, %{field: new_value})
      {:ok, %Date{}}

      iex> update_date(date, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_date(%Date{} = date, attrs) do
    date
    |> Date.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a date.

  ## Examples

      iex> delete_date(date)
      {:ok, %Date{}}

      iex> delete_date(date)
      {:error, %Ecto.Changeset{}}

  """
  def delete_date(%Date{} = date) do
    Repo.delete(date)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking date changes.

  ## Examples

      iex> change_date(date)
      %Ecto.Changeset{data: %Date{}}

  """
  def change_date(%Date{} = date, attrs \\ %{}) do
    Date.changeset(date, attrs)
  end

  def import(attrs \\ %{}) do
    # %Date{}
    # |> Date.changeset(attrs)
    # |> Repo.insert()
    Task.async_stream(attrs, fn one -> %Date{} |> Date.changeset(one) |> Repo.insert end)
    |> Stream.run()
  end
end
