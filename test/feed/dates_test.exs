defmodule Feed.DatesTest do
  use Feed.DataCase

  alias Feed.Dates

  describe "dates" do
    alias Feed.Dates.Date

    import Feed.DatesFixtures

    @invalid_attrs %{service_id: nil, monday: nil, tuesday: nil, wednesday: nil, thursday: nil, friday: nil, saturday: nil, sunday: nil, start_date: nil, end_date: nil, service_name: nil}

    test "list_dates/0 returns all dates" do
      date = date_fixture()
      assert Dates.list_dates() == [date]
    end

    test "get_date!/1 returns the date with given id" do
      date = date_fixture()
      assert Dates.get_date!(date.id) == date
    end

    test "create_date/1 with valid data creates a date" do
      valid_attrs = %{service_id: "some service_id", monday: true, tuesday: true, wednesday: true, thursday: true, friday: true, saturday: true, sunday: true, start_date: ~D[2024-11-24], end_date: ~D[2024-11-24], service_name: "some service_name"}

      assert {:ok, %Date{} = date} = Dates.create_date(valid_attrs)
      assert date.service_id == "some service_id"
      assert date.monday == true
      assert date.tuesday == true
      assert date.wednesday == true
      assert date.thursday == true
      assert date.friday == true
      assert date.saturday == true
      assert date.sunday == true
      assert date.start_date == ~D[2024-11-24]
      assert date.end_date == ~D[2024-11-24]
      assert date.service_name == "some service_name"
    end

    test "create_date/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Dates.create_date(@invalid_attrs)
    end

    test "update_date/2 with valid data updates the date" do
      date = date_fixture()
      update_attrs = %{service_id: "some updated service_id", monday: false, tuesday: false, wednesday: false, thursday: false, friday: false, saturday: false, sunday: false, start_date: ~D[2024-11-25], end_date: ~D[2024-11-25], service_name: "some updated service_name"}

      assert {:ok, %Date{} = date} = Dates.update_date(date, update_attrs)
      assert date.service_id == "some updated service_id"
      assert date.monday == false
      assert date.tuesday == false
      assert date.wednesday == false
      assert date.thursday == false
      assert date.friday == false
      assert date.saturday == false
      assert date.sunday == false
      assert date.start_date == ~D[2024-11-25]
      assert date.end_date == ~D[2024-11-25]
      assert date.service_name == "some updated service_name"
    end

    test "update_date/2 with invalid data returns error changeset" do
      date = date_fixture()
      assert {:error, %Ecto.Changeset{}} = Dates.update_date(date, @invalid_attrs)
      assert date == Dates.get_date!(date.id)
    end

    test "delete_date/1 deletes the date" do
      date = date_fixture()
      assert {:ok, %Date{}} = Dates.delete_date(date)
      assert_raise Ecto.NoResultsError, fn -> Dates.get_date!(date.id) end
    end

    test "change_date/1 returns a date changeset" do
      date = date_fixture()
      assert %Ecto.Changeset{} = Dates.change_date(date)
    end
  end

  describe "dates" do
    alias Feed.Dates.Date

    import Feed.DatesFixtures

    @invalid_attrs %{date: nil, service_id: nil, exception_type: nil}

    test "list_dates/0 returns all dates" do
      date = date_fixture()
      assert Dates.list_dates() == [date]
    end

    test "get_date!/1 returns the date with given id" do
      date = date_fixture()
      assert Dates.get_date!(date.id) == date
    end

    test "create_date/1 with valid data creates a date" do
      valid_attrs = %{date: ~D[2024-11-24], service_id: 42, exception_type: 42}

      assert {:ok, %Date{} = date} = Dates.create_date(valid_attrs)
      assert date.date == ~D[2024-11-24]
      assert date.service_id == 42
      assert date.exception_type == 42
    end

    test "create_date/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Dates.create_date(@invalid_attrs)
    end

    test "update_date/2 with valid data updates the date" do
      date = date_fixture()
      update_attrs = %{date: ~D[2024-11-25], service_id: 43, exception_type: 43}

      assert {:ok, %Date{} = date} = Dates.update_date(date, update_attrs)
      assert date.date == ~D[2024-11-25]
      assert date.service_id == 43
      assert date.exception_type == 43
    end

    test "update_date/2 with invalid data returns error changeset" do
      date = date_fixture()
      assert {:error, %Ecto.Changeset{}} = Dates.update_date(date, @invalid_attrs)
      assert date == Dates.get_date!(date.id)
    end

    test "delete_date/1 deletes the date" do
      date = date_fixture()
      assert {:ok, %Date{}} = Dates.delete_date(date)
      assert_raise Ecto.NoResultsError, fn -> Dates.get_date!(date.id) end
    end

    test "change_date/1 returns a date changeset" do
      date = date_fixture()
      assert %Ecto.Changeset{} = Dates.change_date(date)
    end
  end
end
