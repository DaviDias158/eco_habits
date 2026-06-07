defmodule EcoHabits.Habits do
  import Ecto.Query, warn: false
  alias EcoHabits.Repo
  alias EcoHabits.Habits.Habit

  # Lista todos os hábitos aplicando um filtro opcional de categoria (RF05)
  def list_habits(filter_category \\ nil) do
    query = from h in Habit, order_by: [desc: h.inserted_at]

    query =
      if filter_category in Habit.categories() do
        from h in query, where: h.category == ^filter_category
      else
        query
      end

    Repo.all(query)
  end

  def get_habit!(id), do: Repo.get!(Habit, id)

  def create_habit(attrs \\ %{}) do
    %Habit{}
    |> Habit.changeset(attrs)
    |> Repo.insert()
  end

  def update_habit(%Habit{} = habit, attrs) do
    habit
    |> Habit.changeset(attrs)
    |> Repo.update()
  end

  def delete_habit(%Habit{} = habit) do
    Repo.delete(habit)
  end

  def change_habit(%Habit{} = habit, attrs \\ %{}) do
    Habit.changeset(habit, attrs)
  end
end
