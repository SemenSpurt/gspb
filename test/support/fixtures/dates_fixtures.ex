defmodule Feed.Time.DatesFixtures do
  @doc """
  Generate a date.
  """
  def date_fixture(attrs \\ %{}) do
    {:ok, date} =
      attrs
      |> Enum.into(%{
        date: ~D[2024-11-24],
        exception_type: 42,
        service_id: 42
      })
      |> Feed.Time.Dates.create_date()

    date
  end
end
