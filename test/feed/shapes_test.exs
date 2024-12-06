defmodule Feed.ShapesTest do
  use Feed.DataCase

  alias Feed.Shapes

  describe "shapes" do
    alias Feed.Shapes.Shape

    import Feed.ShapesFixtures

    @invalid_attrs %{shape_id: nil, shape_pt_lat: nil, shape_pt_lon: nil, shape_pt_sequence: nil, shape_dist_traveled: nil}

    test "list_shapes/0 returns all shapes" do
      shape = shape_fixture()
      assert Shapes.list_shapes() == [shape]
    end

    test "get_shape!/1 returns the shape with given id" do
      shape = shape_fixture()
      assert Shapes.get_shape!(shape.id) == shape
    end

    test "create_shape/1 with valid data creates a shape" do
      valid_attrs = %{shape_id: "some shape_id", shape_pt_lat: 120.5, shape_pt_lon: 120.5, shape_pt_sequence: 42, shape_dist_traveled: 120.5}

      assert {:ok, %Shape{} = shape} = Shapes.create_shape(valid_attrs)
      assert shape.shape_id == "some shape_id"
      assert shape.shape_pt_lat == 120.5
      assert shape.shape_pt_lon == 120.5
      assert shape.shape_pt_sequence == 42
      assert shape.shape_dist_traveled == 120.5
    end

    test "create_shape/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Shapes.create_shape(@invalid_attrs)
    end

    test "update_shape/2 with valid data updates the shape" do
      shape = shape_fixture()
      update_attrs = %{shape_id: "some updated shape_id", shape_pt_lat: 456.7, shape_pt_lon: 456.7, shape_pt_sequence: 43, shape_dist_traveled: 456.7}

      assert {:ok, %Shape{} = shape} = Shapes.update_shape(shape, update_attrs)
      assert shape.shape_id == "some updated shape_id"
      assert shape.shape_pt_lat == 456.7
      assert shape.shape_pt_lon == 456.7
      assert shape.shape_pt_sequence == 43
      assert shape.shape_dist_traveled == 456.7
    end

    test "update_shape/2 with invalid data returns error changeset" do
      shape = shape_fixture()
      assert {:error, %Ecto.Changeset{}} = Shapes.update_shape(shape, @invalid_attrs)
      assert shape == Shapes.get_shape!(shape.id)
    end

    test "delete_shape/1 deletes the shape" do
      shape = shape_fixture()
      assert {:ok, %Shape{}} = Shapes.delete_shape(shape)
      assert_raise Ecto.NoResultsError, fn -> Shapes.get_shape!(shape.id) end
    end

    test "change_shape/1 returns a shape changeset" do
      shape = shape_fixture()
      assert %Ecto.Changeset{} = Shapes.change_shape(shape)
    end
  end
end
