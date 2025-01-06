defmodule Feed.RoutesTest do
  use Feed.DataCase

  alias Feed.Routes

  describe "routes" do
    alias Feed.Routes.Route

    import Feed.RoutesFixtures

    @invalid_attrs %{
      circular: nil,
      route_id: nil,
      agency_id: nil,
      route_short_name: nil,
      route_long_name: nil,
      route_type: nil,
      transport_type: nil,
      urban: nil,
      night: nil
    }

    test "list_routes/0 returns all routes" do
      route = route_fixture()
      assert Routes.list_routes() == [route]
    end

    test "get_route!/1 returns the route with given id" do
      route = route_fixture()
      assert Routes.get_route!(route.id) == route
    end

    test "create_route/1 with valid data creates a route" do
      valid_attrs = %{
        circular: true,
        route_id: 42,
        agency_id: 42,
        route_short_name: "some route_short_name",
        route_long_name: "some route_long_name",
        route_type: 42,
        transport_type: 42,
        urban: true,
        night: true
      }

      assert {:ok, %Route{} = route} = Routes.create_route(valid_attrs)
      assert route.circular == true
      assert route.route_id == 42
      assert route.agency_id == 42
      assert route.route_short_name == "some route_short_name"
      assert route.route_long_name == "some route_long_name"
      assert route.route_type == 42
      assert route.transport_type == 42
      assert route.urban == true
      assert route.night == true
    end

    test "create_route/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Routes.create_route(@invalid_attrs)
    end

    test "update_route/2 with valid data updates the route" do
      route = route_fixture()

      update_attrs = %{
        circular: false,
        route_id: 43,
        agency_id: 43,
        route_short_name: "some updated route_short_name",
        route_long_name: "some updated route_long_name",
        route_type: 43,
        transport_type: 43,
        urban: false,
        night: false
      }

      assert {:ok, %Route{} = route} = Routes.update_route(route, update_attrs)
      assert route.circular == false
      assert route.route_id == 43
      assert route.agency_id == 43
      assert route.route_short_name == "some updated route_short_name"
      assert route.route_long_name == "some updated route_long_name"
      assert route.route_type == 43
      assert route.transport_type == 43
      assert route.urban == false
      assert route.night == false
    end

    test "update_route/2 with invalid data returns error changeset" do
      route = route_fixture()
      assert {:error, %Ecto.Changeset{}} = Routes.update_route(route, @invalid_attrs)
      assert route == Routes.get_route!(route.id)
    end

    test "delete_route/1 deletes the route" do
      route = route_fixture()
      assert {:ok, %Route{}} = Routes.delete_route(route)
      assert_raise Ecto.NoResultsError, fn -> Routes.get_route!(route.id) end
    end

    test "change_route/1 returns a route changeset" do
      route = route_fixture()
      assert %Ecto.Changeset{} = Routes.change_route(route)
    end
  end
end
