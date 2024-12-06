defmodule Feed.FreqsTest do
  use Feed.DataCase

  alias Feed.Freqs

  describe "freqs" do
    alias Feed.Freqs.Freq

    import Feed.FreqsFixtures

    @invalid_attrs %{trip_id: nil, start_time: nil, end_time: nil, headway_secs: nil, exact_times: nil}

    test "list_freqs/0 returns all freqs" do
      freq = freq_fixture()
      assert Freqs.list_freqs() == [freq]
    end

    test "get_freq!/1 returns the freq with given id" do
      freq = freq_fixture()
      assert Freqs.get_freq!(freq.id) == freq
    end

    test "create_freq/1 with valid data creates a freq" do
      valid_attrs = %{trip_id: 42, start_time: ~T[14:00:00], end_time: ~T[14:00:00], headway_secs: 42, exact_times: true}

      assert {:ok, %Freq{} = freq} = Freqs.create_freq(valid_attrs)
      assert freq.trip_id == 42
      assert freq.start_time == ~T[14:00:00]
      assert freq.end_time == ~T[14:00:00]
      assert freq.headway_secs == 42
      assert freq.exact_times == true
    end

    test "create_freq/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Freqs.create_freq(@invalid_attrs)
    end

    test "update_freq/2 with valid data updates the freq" do
      freq = freq_fixture()
      update_attrs = %{trip_id: 43, start_time: ~T[15:01:01], end_time: ~T[15:01:01], headway_secs: 43, exact_times: false}

      assert {:ok, %Freq{} = freq} = Freqs.update_freq(freq, update_attrs)
      assert freq.trip_id == 43
      assert freq.start_time == ~T[15:01:01]
      assert freq.end_time == ~T[15:01:01]
      assert freq.headway_secs == 43
      assert freq.exact_times == false
    end

    test "update_freq/2 with invalid data returns error changeset" do
      freq = freq_fixture()
      assert {:error, %Ecto.Changeset{}} = Freqs.update_freq(freq, @invalid_attrs)
      assert freq == Freqs.get_freq!(freq.id)
    end

    test "delete_freq/1 deletes the freq" do
      freq = freq_fixture()
      assert {:ok, %Freq{}} = Freqs.delete_freq(freq)
      assert_raise Ecto.NoResultsError, fn -> Freqs.get_freq!(freq.id) end
    end

    test "change_freq/1 returns a freq changeset" do
      freq = freq_fixture()
      assert %Ecto.Changeset{} = Freqs.change_freq(freq)
    end
  end
end
