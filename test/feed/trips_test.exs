defmodule Feed.TripsTest do
  use Feed.DataCase

  alias Feed.Trips

  describe "routes" do
    alias Feed.Trips.Trip

    import Feed.TripsFixtures

    @invalid_attrs %{
      route_id: nil,
      service_id: nil,
      trip_id: nil,
      direction_id: nil,
      shape_id: nil
    }

    test "list_routes/0 returns all routes" do
      trip = trip_fixture()
      assert Trips.list_routes() == [trip]
    end

    test "get_trip!/1 returns the trip with given id" do
      trip = trip_fixture()
      assert Trips.get_trip!(trip.id) == trip
    end

    test "create_trip/1 with valid data creates a trip" do
      valid_attrs = %{
        route_id: 42,
        service_id: "some service_id",
        trip_id: 42,
        direction_id: true,
        shape_id: 42
      }

      assert {:ok, %Trip{} = trip} = Trips.create_trip(valid_attrs)
      assert trip.route_id == 42
      assert trip.service_id == "some service_id"
      assert trip.trip_id == 42
      assert trip.direction_id == true
      assert trip.shape_id == 42
    end

    test "create_trip/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Trips.create_trip(@invalid_attrs)
    end

    test "update_trip/2 with valid data updates the trip" do
      trip = trip_fixture()

      update_attrs = %{
        route_id: 43,
        service_id: "some updated service_id",
        trip_id: 43,
        direction_id: false,
        shape_id: 43
      }

      assert {:ok, %Trip{} = trip} = Trips.update_trip(trip, update_attrs)
      assert trip.route_id == 43
      assert trip.service_id == "some updated service_id"
      assert trip.trip_id == 43
      assert trip.direction_id == false
      assert trip.shape_id == 43
    end

    test "update_trip/2 with invalid data returns error changeset" do
      trip = trip_fixture()
      assert {:error, %Ecto.Changeset{}} = Trips.update_trip(trip, @invalid_attrs)
      assert trip == Trips.get_trip!(trip.id)
    end

    test "delete_trip/1 deletes the trip" do
      trip = trip_fixture()
      assert {:ok, %Trip{}} = Trips.delete_trip(trip)
      assert_raise Ecto.NoResultsError, fn -> Trips.get_trip!(trip.id) end
    end

    test "change_trip/1 returns a trip changeset" do
      trip = trip_fixture()
      assert %Ecto.Changeset{} = Trips.change_trip(trip)
    end
  end

  describe "trips" do
    alias Feed.Trips.Trip

    import Feed.TripsFixtures

    @invalid_attrs %{
      route_id: nil,
      service_id: nil,
      trip_id: nil,
      direction_id: nil,
      shape_id: nil
    }

    test "list_trips/0 returns all trips" do
      trip = trip_fixture()
      assert Trips.list_trips() == [trip]
    end

    test "get_trip!/1 returns the trip with given id" do
      trip = trip_fixture()
      assert Trips.get_trip!(trip.id) == trip
    end

    test "create_trip/1 with valid data creates a trip" do
      valid_attrs = %{
        route_id: 42,
        service_id: "some service_id",
        trip_id: 42,
        direction_id: true,
        shape_id: 42
      }

      assert {:ok, %Trip{} = trip} = Trips.create_trip(valid_attrs)
      assert trip.route_id == 42
      assert trip.service_id == "some service_id"
      assert trip.trip_id == 42
      assert trip.direction_id == true
      assert trip.shape_id == 42
    end

    test "create_trip/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Trips.create_trip(@invalid_attrs)
    end

    test "update_trip/2 with valid data updates the trip" do
      trip = trip_fixture()

      update_attrs = %{
        route_id: 43,
        service_id: "some updated service_id",
        trip_id: 43,
        direction_id: false,
        shape_id: 43
      }

      assert {:ok, %Trip{} = trip} = Trips.update_trip(trip, update_attrs)
      assert trip.route_id == 43
      assert trip.service_id == "some updated service_id"
      assert trip.trip_id == 43
      assert trip.direction_id == false
      assert trip.shape_id == 43
    end

    test "update_trip/2 with invalid data returns error changeset" do
      trip = trip_fixture()
      assert {:error, %Ecto.Changeset{}} = Trips.update_trip(trip, @invalid_attrs)
      assert trip == Trips.get_trip!(trip.id)
    end

    test "delete_trip/1 deletes the trip" do
      trip = trip_fixture()
      assert {:ok, %Trip{}} = Trips.delete_trip(trip)
      assert_raise Ecto.NoResultsError, fn -> Trips.get_trip!(trip.id) end
    end

    test "change_trip/1 returns a trip changeset" do
      trip = trip_fixture()
      assert %Ecto.Changeset{} = Trips.change_trip(trip)
    end
  end

  describe "trips" do
    alias Feed.Trips.Trip

    import Feed.TripsFixtures

    @invalid_attrs %{
      route_id: nil,
      service_id: nil,
      trip_id: nil,
      direction_id: nil,
      shape_id: nil
    }

    test "list_trips/0 returns all trips" do
      trip = trip_fixture()
      assert Trips.list_trips() == [trip]
    end

    test "get_trip!/1 returns the trip with given id" do
      trip = trip_fixture()
      assert Trips.get_trip!(trip.id) == trip
    end

    test "create_trip/1 with valid data creates a trip" do
      valid_attrs = %{
        route_id: 42,
        service_id: 42,
        trip_id: 42,
        direction_id: true,
        shape_id: "some shape_id"
      }

      assert {:ok, %Trip{} = trip} = Trips.create_trip(valid_attrs)
      assert trip.route_id == 42
      assert trip.service_id == 42
      assert trip.trip_id == 42
      assert trip.direction_id == true
      assert trip.shape_id == "some shape_id"
    end

    test "create_trip/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Trips.create_trip(@invalid_attrs)
    end

    test "update_trip/2 with valid data updates the trip" do
      trip = trip_fixture()

      update_attrs = %{
        route_id: 43,
        service_id: 43,
        trip_id: 43,
        direction_id: false,
        shape_id: "some updated shape_id"
      }

      assert {:ok, %Trip{} = trip} = Trips.update_trip(trip, update_attrs)
      assert trip.route_id == 43
      assert trip.service_id == 43
      assert trip.trip_id == 43
      assert trip.direction_id == false
      assert trip.shape_id == "some updated shape_id"
    end

    test "update_trip/2 with invalid data returns error changeset" do
      trip = trip_fixture()
      assert {:error, %Ecto.Changeset{}} = Trips.update_trip(trip, @invalid_attrs)
      assert trip == Trips.get_trip!(trip.id)
    end

    test "delete_trip/1 deletes the trip" do
      trip = trip_fixture()
      assert {:ok, %Trip{}} = Trips.delete_trip(trip)
      assert_raise Ecto.NoResultsError, fn -> Trips.get_trip!(trip.id) end
    end

    test "change_trip/1 returns a trip changeset" do
      trip = trip_fixture()
      assert %Ecto.Changeset{} = Trips.change_trip(trip)
    end
  end
end
