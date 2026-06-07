defmodule EcoHabits.Habits.Habit do
  use Ecto.Schema
  import Ecto.Changeset

  @categories ["alimentação", "transporte", "energia", "água", "resíduos"]

  schema "habits" do
    field :name, :string
    field :description, :string
    field :category, :string
    field :points, :integer

    belongs_to :user, EcoHabits.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(habit, attrs) do
    habit
    |> cast(attrs, [:name, :description, :category, :points, :user_id])
    |> validate_required([:name, :category, :points, :user_id])
    |> validate_inclusion(:category, @categories, message: "Categoria inválida")
    |> validate_number(:points, greater_than: 0, message: "A pontuação deve ser maior que zero")
  end

  def categories, do: @categories
end
