defmodule EcoHabits.Trackers.CheckIn do
  use Ecto.Schema
  import Ecto.Changeset

  schema "check_ins" do
    field :date, :date

    belongs_to :user, EcoHabits.Accounts.User
    belongs_to :habit, EcoHabits.Habits.Habit

    timestamps(type: :utc_datetime)
  end

  def changeset(check_in, attrs) do
    check_in
    |> cast(attrs, [:date, :user_id, :habit_id])
    |> validate_required([:date, :user_id, :habit_id])
    # RT06: Transforma a restrição do banco em erro de validação do Ecto
    |> unique_constraint([:user_id, :habit_id, :date], name: :user_habit_daily_checkin, message: "Você já realizou o check-in deste hábito hoje!")
  end
end
