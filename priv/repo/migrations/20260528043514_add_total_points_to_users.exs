defmodule EcoHabits.Repo.Migrations.AddTotalPointsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :total_points, :integer, default: 0, null: false
    end
  end
end
