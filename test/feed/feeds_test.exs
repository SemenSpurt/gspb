defmodule Feed.FeedsTest do
  use Feed.DataCase

  alias Feed.Feeds

  describe "agencies" do
    alias Feed.Feeds.Agency

    import Feed.FeedsFixtures

    @invalid_attrs %{agency_id: nil, agency_name: nil, agency_url: nil, agency_phone: nil, agency_timezone: nil}

    test "list_agencies/0 returns all agencies" do
      agency = agency_fixture()
      assert Feeds.list_agencies() == [agency]
    end

    test "get_agency!/1 returns the agency with given id" do
      agency = agency_fixture()
      assert Feeds.get_agency!(agency.id) == agency
    end

    test "create_agency/1 with valid data creates a agency" do
      valid_attrs = %{agency_id: 42, agency_name: "some agency_name", agency_url: "some agency_url", agency_phone: "some agency_phone", agency_timezone: "some agency_timezone"}

      assert {:ok, %Agency{} = agency} = Feeds.create_agency(valid_attrs)
      assert agency.agency_id == 42
      assert agency.agency_name == "some agency_name"
      assert agency.agency_url == "some agency_url"
      assert agency.agency_phone == "some agency_phone"
      assert agency.agency_timezone == "some agency_timezone"
    end

    test "create_agency/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Feeds.create_agency(@invalid_attrs)
    end

    test "update_agency/2 with valid data updates the agency" do
      agency = agency_fixture()
      update_attrs = %{agency_id: 43, agency_name: "some updated agency_name", agency_url: "some updated agency_url", agency_phone: "some updated agency_phone", agency_timezone: "some updated agency_timezone"}

      assert {:ok, %Agency{} = agency} = Feeds.update_agency(agency, update_attrs)
      assert agency.agency_id == 43
      assert agency.agency_name == "some updated agency_name"
      assert agency.agency_url == "some updated agency_url"
      assert agency.agency_phone == "some updated agency_phone"
      assert agency.agency_timezone == "some updated agency_timezone"
    end

    test "update_agency/2 with invalid data returns error changeset" do
      agency = agency_fixture()
      assert {:error, %Ecto.Changeset{}} = Feeds.update_agency(agency, @invalid_attrs)
      assert agency == Feeds.get_agency!(agency.id)
    end

    test "delete_agency/1 deletes the agency" do
      agency = agency_fixture()
      assert {:ok, %Agency{}} = Feeds.delete_agency(agency)
      assert_raise Ecto.NoResultsError, fn -> Feeds.get_agency!(agency.id) end
    end

    test "change_agency/1 returns a agency changeset" do
      agency = agency_fixture()
      assert %Ecto.Changeset{} = Feeds.change_agency(agency)
    end
  end
end
