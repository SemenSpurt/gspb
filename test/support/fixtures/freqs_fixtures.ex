defmodule Feed.Time.FreqsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Feed.Freqs` context.
  """

  @doc """
  Generate a freq.
  """
  def freq_fixture(attrs \\ %{}) do
    {:ok, freq} =
      attrs
      |> Enum.into(%{
        end_time: ~T[14:00:00],
        exact_times: true,
        headway_secs: 42,
        start_time: ~T[14:00:00],
        trip_id: 42
      })
      |> Feed.Time.Freqs.create_freq()

    freq
  end
end
