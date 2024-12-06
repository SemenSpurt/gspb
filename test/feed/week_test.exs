defmodule Feed.WeekTest do
  use Feed.DataCase

  alias Feed.Week

  describe "days" do
    alias Feed.Week.Days

    import Feed.WeekFixtures

    @invalid_attrs %{service_id: nil, monday: nil, tuesday: nil, wednesday: nil, thursday: nil, friday: nil, saturday: nil, sunday: nil, start_date: nil, end_date: nil, service_name: nil}

    test "list_days/0 returns all days" do
      days = days_fixture()
      assert Week.list_days() == [days]
    end

    test "get_days!/1 returns the days with given id" do
      days = days_fixture()
      assert Week.get_days!(days.id) == days
    end

    test "create_days/1 with valid data creates a days" do
      valid_attrs = %{service_id: "some service_id", monday: true, tuesday: true, wednesday: true, thursday: true, friday: true, saturday: true, sunday: true, start_date: ~D[2024-11-24], end_date: ~D[2024-11-24], service_name: "some service_name"}

      assert {:ok, %Days{} = days} = Week.create_days(valid_attrs)
      assert days.service_id == "some service_id"
      assert days.monday == true
      assert days.tuesday == true
      assert days.wednesday == true
      assert days.thursday == true
      assert days.friday == true
      assert days.saturday == true
      assert days.sunday == true
      assert days.start_date == ~D[2024-11-24]
      assert days.end_date == ~D[2024-11-24]
      assert days.service_name == "some service_name"
    end

    test "create_days/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Week.create_days(@invalid_attrs)
    end

    test "update_days/2 with valid data updates the days" do
      days = days_fixture()
      update_attrs = %{service_id: "some updated service_id", monday: false, tuesday: false, wednesday: false, thursday: false, friday: false, saturday: false, sunday: false, start_date: ~D[2024-11-25], end_date: ~D[2024-11-25], service_name: "some updated service_name"}

      assert {:ok, %Days{} = days} = Week.update_days(days, update_attrs)
      assert days.service_id == "some updated service_id"
      assert days.monday == false
      assert days.tuesday == false
      assert days.wednesday == false
      assert days.thursday == false
      assert days.friday == false
      assert days.saturday == false
      assert days.sunday == false
      assert days.start_date == ~D[2024-11-25]
      assert days.end_date == ~D[2024-11-25]
      assert days.service_name == "some updated service_name"
    end

    test "update_days/2 with invalid data returns error changeset" do
      days = days_fixture()
      assert {:error, %Ecto.Changeset{}} = Week.update_days(days, @invalid_attrs)
      assert days == Week.get_days!(days.id)
    end

    test "delete_days/1 deletes the days" do
      days = days_fixture()
      assert {:ok, %Days{}} = Week.delete_days(days)
      assert_raise Ecto.NoResultsError, fn -> Week.get_days!(days.id) end
    end

    test "change_days/1 returns a days changeset" do
      days = days_fixture()
      assert %Ecto.Changeset{} = Week.change_days(days)
    end
  end
end
