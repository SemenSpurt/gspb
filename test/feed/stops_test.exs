defmodule Feed.StopsTest do
  use Feed.DataCase

  alias Feed.Stops

  describe "stops" do
    alias Feed.Stops.Stop

    import Feed.StopsFixtures

    @invalid_attrs %{stop_id: nil, stop_code: nil, stop_name: nil, stop_lat: nil, stop_lon: nil, location_type: nil, wheelchair_boarding: nil, transport_type: nil}

    test "list_stops/0 returns all stops" do
      stop = stop_fixture()
      assert Stops.list_stops() == [stop]
    end

    test "get_stop!/1 returns the stop with given id" do
      stop = stop_fixture()
      assert Stops.get_stop!(stop.id) == stop
    end

    test "create_stop/1 with valid data creates a stop" do
      valid_attrs = %{stop_id: 42, stop_code: 42, stop_name: "some stop_name", stop_lat: 120.5, stop_lon: 120.5, location_type: 42, wheelchair_boarding: 42, transport_type: "some transport_type"}

      assert {:ok, %Stop{} = stop} = Stops.create_stop(valid_attrs)
      assert stop.stop_id == 42
      assert stop.stop_code == 42
      assert stop.stop_name == "some stop_name"
      assert stop.stop_lat == 120.5
      assert stop.stop_lon == 120.5
      assert stop.location_type == 42
      assert stop.wheelchair_boarding == 42
      assert stop.transport_type == "some transport_type"
    end

    test "create_stop/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Stops.create_stop(@invalid_attrs)
    end

    test "update_stop/2 with valid data updates the stop" do
      stop = stop_fixture()
      update_attrs = %{stop_id: 43, stop_code: 43, stop_name: "some updated stop_name", stop_lat: 456.7, stop_lon: 456.7, location_type: 43, wheelchair_boarding: 43, transport_type: "some updated transport_type"}

      assert {:ok, %Stop{} = stop} = Stops.update_stop(stop, update_attrs)
      assert stop.stop_id == 43
      assert stop.stop_code == 43
      assert stop.stop_name == "some updated stop_name"
      assert stop.stop_lat == 456.7
      assert stop.stop_lon == 456.7
      assert stop.location_type == 43
      assert stop.wheelchair_boarding == 43
      assert stop.transport_type == "some updated transport_type"
    end

    test "update_stop/2 with invalid data returns error changeset" do
      stop = stop_fixture()
      assert {:error, %Ecto.Changeset{}} = Stops.update_stop(stop, @invalid_attrs)
      assert stop == Stops.get_stop!(stop.id)
    end

    test "delete_stop/1 deletes the stop" do
      stop = stop_fixture()
      assert {:ok, %Stop{}} = Stops.delete_stop(stop)
      assert_raise Ecto.NoResultsError, fn -> Stops.get_stop!(stop.id) end
    end

    test "change_stop/1 returns a stop changeset" do
      stop = stop_fixture()
      assert %Ecto.Changeset{} = Stops.change_stop(stop)
    end
  end
end
