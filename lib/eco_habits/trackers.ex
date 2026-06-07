defmodule EcoHabits.Trackers do
  import Ecto.Query, warn: false
  alias EcoHabits.Repo
  alias EcoHabits.Trackers.CheckIn
  alias EcoHabits.Accounts

  # Tópico do PubSub para transmissão em tempo real (RF09)
  @pubsub_topic "community_feed"

  def subscribe do
    Phoenix.PubSub.subscribe(EcoHabits.PubSub, @pubsub_topic)
  end

  def broadcast_check_in({:ok, check_in} = result) do
    # Faz um pre-load para trazer os dados do usuário e do hábito no feed
    check_in_preloaded = Repo.preload(check_in, [:user, :habit])
    Phoenix.PubSub.broadcast(EcoHabits.PubSub, @pubsub_topic, {:new_check_in, check_in_preloaded})
    result
  end
  def broadcast_check_in(error_result), do: error_result

  # Lista os últimos check-ins de toda a comunidade para o feed (RF09)
  def list_community_feed do
    from(c in CheckIn,
      order_by: [desc: c.inserted_at],
      limit: 10,
      preload: [:user, :habit]
    )
    |> Repo.all()
  end

  # Lista o histórico de um usuário específico (RF08)
  def list_user_check_ins(user_id) do
    from(c in CheckIn,
      where: c.user_id == ^user_id,
      order_by: [desc: c.date],
      preload: [:habit]
    )
    |> Repo.all()
  end

  # Realiza o check-in e incrementa a pontuação global do usuário
  def create_check_in(attrs \\ %{}) do
    %CheckIn{}
    |> CheckIn.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, check_in} ->
        # Busca o hábito para saber quantos pontos vale
        habit = EcoHabits.Habits.get_habit!(check_in.habit_id)
        # Soma os pontos no perfil do usuário
        Accounts.add_points_to_user(check_in.user_id, habit.points)

        {:ok, check_in}
      {:error, changeset} ->
        {:error, changeset}
    end
    |> broadcast_check_in() # Transmite via PubSub se tiver dado certo
  end

  # Regra de negócio funcional: Filtra e agrupa categorias únicas do dia de hoje
  def compute_badges(check_ins) do
    today = Date.utc_today()

    check_ins
    |> Enum.filter(fn c -> c.date == today end)
    |> Enum.map(fn c -> c.habit.category end)
    |> Enum.uniq()
  end
end
