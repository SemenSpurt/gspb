defmodule Feed.Freqs do
  @moduledoc """
  The Freqs context.
  """

  import Ecto.Query, warn: false
  alias Feed.Repo

  alias Feed.Freqs.Freq

  @doc """
  Returns the list of freqs.

  ## Examples

      iex> list_freqs()
      [%Freq{}, ...]

  """
  def list_freqs do
    Repo.all(Freq)
  end

  @doc """
  Gets a single freq.

  Raises `Ecto.NoResultsError` if the Freq does not exist.

  ## Examples

      iex> get_freq!(123)
      %Freq{}

      iex> get_freq!(456)
      ** (Ecto.NoResultsError)

  """
  def get_freq!(id), do: Repo.get!(Freq, id)

  @doc """
  Creates a freq.

  ## Examples

      iex> create_freq(%{field: value})
      {:ok, %Freq{}}

      iex> create_freq(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_freq(attrs \\ %{}) do
    %Freq{}
    |> Freq.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a freq.

  ## Examples

      iex> update_freq(freq, %{field: new_value})
      {:ok, %Freq{}}

      iex> update_freq(freq, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_freq(%Freq{} = freq, attrs) do
    freq
    |> Freq.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a freq.

  ## Examples

      iex> delete_freq(freq)
      {:ok, %Freq{}}

      iex> delete_freq(freq)
      {:error, %Ecto.Changeset{}}

  """
  def delete_freq(%Freq{} = freq) do
    Repo.delete(freq)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking freq changes.

  ## Examples

      iex> change_freq(freq)
      %Ecto.Changeset{data: %Freq{}}

  """
  def change_freq(%Freq{} = freq, attrs \\ %{}) do
    Freq.changeset(freq, attrs)
  end

  def import(attrs \\ %{}) do
    # %Freq{}
    # |> Freq.changeset(attrs)
    # |> Repo.insert()
    Task.async_stream(attrs, fn one -> %Freq{} |> Freq.changeset(one) |> Repo.insert end)
    |> Stream.run()
  end
end
