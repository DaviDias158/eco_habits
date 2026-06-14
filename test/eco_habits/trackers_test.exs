defmodule EcoHabits.TrackersTest do
  use EcoHabits.DataCase

  alias EcoHabits.Trackers

  describe "check_ins" do
    alias EcoHabits.Trackers.CheckIn

    import EcoHabits.TrackersFixtures

    @invalid_attrs %{date: nil}

    test "list_check_ins/0 returns all check_ins" do
      check_in = check_in_fixture()
      assert Trackers.list_check_ins() == [check_in]
    end

    test "get_check_in!/1 returns the check_in with given id" do
      check_in = check_in_fixture()
      assert Trackers.get_check_in!(check_in.id) == check_in
    end

    test "create_check_in/1 with valid data creates a check_in" do
      valid_attrs = %{date: ~D[2026-06-01]}

      assert {:ok, %CheckIn{} = check_in} = Trackers.create_check_in(valid_attrs)
      assert check_in.date == ~D[2026-06-01]
    end

    test "create_check_in/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Trackers.create_check_in(@invalid_attrs)
    end

    test "update_check_in/2 with valid data updates the check_in" do
      check_in = check_in_fixture()
      update_attrs = %{date: ~D[2026-06-02]}

      assert {:ok, %CheckIn{} = check_in} = Trackers.update_check_in(check_in, update_attrs)
      assert check_in.date == ~D[2026-06-02]
    end

    test "update_check_in/2 with invalid data returns error changeset" do
      check_in = check_in_fixture()
      assert {:error, %Ecto.Changeset{}} = Trackers.update_check_in(check_in, @invalid_attrs)
      assert check_in == Trackers.get_check_in!(check_in.id)
    end

    test "delete_check_in/1 deletes the check_in" do
      check_in = check_in_fixture()
      assert {:ok, %CheckIn{}} = Trackers.delete_check_in(check_in)
      assert_raise Ecto.NoResultsError, fn -> Trackers.get_check_in!(check_in.id) end
    end

    test "change_check_in/1 returns a check_in changeset" do
      check_in = check_in_fixture()
      assert %Ecto.Changeset{} = Trackers.change_check_in(check_in)
    end
  end
end
