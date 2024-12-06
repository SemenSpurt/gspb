defmodule Feed.ShapesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Feed.Shapes` context.
  """

  @doc """
  Generate a shape.
  """
  def shape_fixture(attrs \\ %{}) do
    {:ok, shape} =
      attrs
      |> Enum.into(%{
        shape_dist_traveled: 120.5,
        shape_id: "some shape_id",
        shape_pt_lat: 120.5,
        shape_pt_lon: 120.5,
        shape_pt_sequence: 42
      })
      |> Feed.Shapes.create_shape()

    shape
  end
end
