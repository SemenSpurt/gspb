defmodule Feed.TimesTest do
  use Feed.DataCase

  alias Feed.Times

  describe "times" do
    alias Feed.Times.Time

    import Feed.TimesFixtures

    @invalid_attrs %{
      trip_id: nil,
      arrival_time: nil,
      departure_time: nil,
      stop_id: nil,
      stop_sequence: nil,
      shape_id: nil,
      shape_dist_traveled: nil
    }

    test "list_times/0 returns all times" do
      time = time_fixture()
      assert Times.list_times() == [time]
    end

    test "get_time!/1 returns the time with given id" do
      time = time_fixture()
      assert Times.get_time!(time.id) == time
    end

    test "create_time/1 with valid data creates a time" do
      valid_attrs = %{
        trip_id: 42,
        arrival_time: ~T[14:00:00],
        departure_time: ~T[14:00:00],
        stop_id: 42,
        stop_sequence: 42,
        shape_id: "some shape_id",
        shape_dist_traveled: 120.5
      }

      assert {:ok, %Time{} = time} = Times.create_time(valid_attrs)
      assert time.trip_id == 42
      assert time.arrival_time == ~T[14:00:00]
      assert time.departure_time == ~T[14:00:00]
      assert time.stop_id == 42
      assert time.stop_sequence == 42
      assert time.shape_id == "some shape_id"
      assert time.shape_dist_traveled == 120.5
    end

    test "create_time/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Times.create_time(@invalid_attrs)
    end

    test "update_time/2 with valid data updates the time" do
      time = time_fixture()

      update_attrs = %{
        trip_id: 43,
        arrival_time: ~T[15:01:01],
        departure_time: ~T[15:01:01],
        stop_id: 43,
        stop_sequence: 43,
        shape_id: "some updated shape_id",
        shape_dist_traveled: 456.7
      }

      assert {:ok, %Time{} = time} = Times.update_time(time, update_attrs)
      assert time.trip_id == 43
      assert time.arrival_time == ~T[15:01:01]
      assert time.departure_time == ~T[15:01:01]
      assert time.stop_id == 43
      assert time.stop_sequence == 43
      assert time.shape_id == "some updated shape_id"
      assert time.shape_dist_traveled == 456.7
    end

    test "update_time/2 with invalid data returns error changeset" do
      time = time_fixture()
      assert {:error, %Ecto.Changeset{}} = Times.update_time(time, @invalid_attrs)
      assert time == Times.get_time!(time.id)
    end

    test "delete_time/1 deletes the time" do
      time = time_fixture()
      assert {:ok, %Time{}} = Times.delete_time(time)
      assert_raise Ecto.NoResultsError, fn -> Times.get_time!(time.id) end
    end

    test "change_time/1 returns a time changeset" do
      time = time_fixture()
      assert %Ecto.Changeset{} = Times.change_time(time)
    end
  end
end
