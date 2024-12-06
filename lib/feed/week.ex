defmodule Feed.Week do
  @moduledoc """
  The Week context.
  """

  import Ecto.Query, warn: false
  alias Feed.Repo

  alias Feed.Week.Days

  @doc """
  Returns the list of days.

  ## Examples

      iex> list_days()
      [%Days{}, ...]

  """
  def list_days do
    Repo.all(Days)
  end

  @doc """
  Gets a single days.

  Raises `Ecto.NoResultsError` if the Days does not exist.

  ## Examples

      iex> get_days!(123)
      %Days{}

      iex> get_days!(456)
      ** (Ecto.NoResultsError)

  """
  def get_days!(id), do: Repo.get!(Days, id)

  @doc """
  Creates a days.

  ## Examples

      iex> create_days(%{field: value})
      {:ok, %Days{}}

      iex> create_days(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_days(attrs \\ %{}) do
    %Days{}
    |> Days.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a days.

  ## Examples

      iex> update_days(days, %{field: new_value})
      {:ok, %Days{}}

      iex> update_days(days, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_days(%Days{} = days, attrs) do
    days
    |> Days.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a days.

  ## Examples

      iex> delete_days(days)
      {:ok, %Days{}}

      iex> delete_days(days)
      {:error, %Ecto.Changeset{}}

  """
  def delete_days(%Days{} = days) do
    Repo.delete(days)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking days changes.

  ## Examples

      iex> change_days(days)
      %Ecto.Changeset{data: %Days{}}

  """
  def change_days(%Days{} = days, attrs \\ %{}) do
    Days.changeset(days, attrs)
  end

  def import(attrs \\ %{}) do
    # %Days{}
    # |> Days.changeset(attrs)
    # |> Repo.insert()
    Task.async_stream(attrs, fn one -> %Days{} |> Days.changeset(one) |> Repo.insert end)
    |> Stream.run()
  end
end
