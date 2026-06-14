defmodule EcoHabits.TrackersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `EcoHabits.Trackers` context.
  """

  @doc """
  Generate a check_in.
  """
  def check_in_fixture(attrs \\ %{}) do
    {:ok, check_in} =
      attrs
      |> Enum.into(%{
        date: ~D[2026-06-01]
      })
      |> EcoHabits.Trackers.create_check_in()

    check_in
  end
end
