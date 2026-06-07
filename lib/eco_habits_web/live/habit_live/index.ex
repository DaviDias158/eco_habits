defmodule EcoHabitsWeb.HabitLive.Index do
  use EcoHabitsWeb, :live_view

  alias EcoHabits.Habits
  alias EcoHabits.Habits.Habit

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="mx-auto max-w-6xl mt-8 grid grid-cols-1 md:grid-cols-3 gap-8">

        <div class="bg-zinc-50 p-6 rounded-xl border border-zinc-200 h-fit">
          <h2 class="text-xl font-bold text-zinc-900 mb-4">
            <%= if @habit.id, do: "Editar Hábito", else: "Novo Hábito Sustentável" %>
          </h2>

          <.form for={@form} id="habit_form" phx-submit="save" phx-change="validate" class="space-y-4">
            <div class="space-y-1">
              <label class="block text-sm font-semibold text-zinc-900">Nome do Hábito</label>
              <.input field={@form[:name]} type="text" placeholder="Ex: Reciclagem de plástico" required />
            </div>

            <div class="space-y-1">
              <label class="block text-sm font-semibold text-zinc-900">Descrição</label>
              <.input field={@form[:description]} type="textarea" placeholder="Descreva brevemente a ação..." />
            </div>

            <div class="space-y-1">
              <label class="block text-sm font-semibold text-zinc-900">Categoria</label>
              <.input
                field={@form[:category]}
                type="select"
                options={[{"Selecione...", ""}] ++ Enum.map(Habit.categories(), &{String.capitalize(&1), &1})}
                required
              />
            </div>

            <div class="space-y-1">
              <label class="block text-sm font-semibold text-zinc-900">Pontuação</label>
              <.input field={@form[:points]} type="number" placeholder="Ex: 15" required />
            </div>

            <div class="pt-2 flex gap-2">
              <button type="submit" phx-disable-with="Salvando..." class="flex-1 bg-green-600 hover:bg-green-700 text-white font-semibold py-2 px-4 rounded-lg shadow cursor-pointer text-center">
                Salvar Hábito
              </button>
              <%= if @habit.id do %>
                <button type="button" phx-click="cancel-edit" class="bg-zinc-300 hover:bg-zinc-400 text-zinc-800 font-semibold py-2 px-4 rounded-lg cursor-pointer">
                  Cancelar
                </button>
              <% end %>
            </div>
          </.form>
        </div>

        <div class="md:col-span-2 space-y-6">
          <div class="bg-white p-4 rounded-xl border border-zinc-200 flex flex-wrap items-center gap-2">
            <span class="text-sm font-bold text-zinc-500 uppercase mr-2">Filtrar por:</span>
            <button
              phx-click="filter"
              phx-value-category="todos"
              class={"px-3 py-1.5 text-xs font-semibold rounded-lg border cursor-pointer #{if @current_filter == "todos", do: "bg-green-600 text-white border-green-600", else: "bg-zinc-50 text-zinc-700 border-zinc-200 hover:bg-zinc-100"}"}
            >
              Todos
            </button>
            <%= for cat <- Habit.categories() do %>
              <button
                phx-click="filter"
                phx-value-category={cat}
                class={"px-3 py-1.5 text-xs font-semibold rounded-lg border cursor-pointer #{if @current_filter == cat, do: "bg-green-600 text-white border-green-600", else: "bg-zinc-50 text-zinc-700 border-zinc-200 hover:bg-zinc-100"}"}
              >
                <%= String.capitalize(cat) %>
              </button>
            <% end %>
          </div>

          <div class="bg-white rounded-xl border border-zinc-200 shadow-sm overflow-hidden">
            <table class="w-full text-left border-collapse">
              <thead>
                <tr class="bg-zinc-50 border-b border-zinc-200 text-zinc-400 text-xs font-bold uppercase tracking-wider">
                  <th class="p-4">Hábito</th>
                  <th class="p-4">Categoria</th>
                  <th class="p-4 text-center">Pontos</th>
                  <th class="p-4 text-right">Ações</th>
                </tr>
              </thead>
              <tbody class="divide-y divide-zinc-100 text-zinc-700">
                <%= if Enum.empty?(@habits) do %>
                  <tr>
                    <td colspan="4" class="p-8 text-center text-zinc-400 italic">Nenhum hábito cadastrado nesta categoria.</td>
                  </tr>
                <% end %>
                <%= for habit <- @habits do %>
                  <tr class="hover:bg-zinc-50 transition-colors">
                    <td class="p-4">
                      <span class="font-semibold text-zinc-900 block"><%= habit.name %></span>
                      <span class="text-sm text-zinc-500 block max-w-md truncate"><%= habit.description %></span>
                    </td>
                    <td class="p-4">
                      <span class="px-2 py-1 text-xs font-bold uppercase rounded bg-zinc-100 text-zinc-600">
                        <%= habit.category %>
                      </span>
                    </td>
                    <td class="p-4 text-center font-black text-green-600">+<%= habit.points %></td>
                    <td class="p-4 text-right space-x-2">
                      <%= if habit.user_id == @current_user_id do %>
                        <button phx-click="edit" phx-value-id={habit.id} class="text-sm font-semibold text-brand hover:underline cursor-pointer">
                          Editar
                        </button>
                        <button phx-click="delete" phx-value-id={habit.id} data-confirm="Deseja mesmo excluir este hábito?" class="text-sm font-semibold text-red-600 hover:underline cursor-pointer">
                          Excluir
                        </button>
                      <% else %>
                        <span class="text-xs text-zinc-400 italic">Criado por outro usuário</span>
                      <% end %>
                    </td>
                  </tr>
                <% end %>
              </tbody>
            </table>
          </div>
        </div>

      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    user_id = socket.assigns.current_scope.user.id
    habits = Habits.list_habits()
    changeset = Habits.change_habit(%Habit{})

    {:ok,
     socket
     |> assign(current_user_id: user_id)
     |> assign(habits: habits)
     |> assign(habit: %Habit{})
     |> assign(current_filter: "todos")
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("filter", %{"category" => category}, socket) do
    filter = if category == "todos", do: nil, else: category
    habits = Habits.list_habits(filter)

    {:noreply,
     socket
     |> assign(current_filter: category)
     |> assign(habits: habits)}
  end

  @impl true
  def handle_event("validate", %{"habit" => habit_params}, socket) do
    changeset =
      socket.assigns.habit
      |> Habits.change_habit(habit_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  @impl true
  def handle_event("save", %{"habit" => habit_params}, socket) do
    # Forçamos o id do usuário logado no parâmetro do hábito para o RF06
    habit_params = Map.put(habit_params, "user_id", socket.assigns.current_user_id)

    case save_habit(socket.assigns.habit, habit_params) do
      {:ok, _habit} ->
        # Recarrega a lista respeitando o filtro ativo
        filter = if socket.assigns.current_filter == "todos", do: nil, else: socket.assigns.current_filter

        {:noreply,
         socket
         |> put_flash(:info, "Hábito salvo com sucesso!")
         |> assign(habits: Habits.list_habits(filter))
         |> assign(habit: %Habit{})
         |> assign_form(Habits.change_habit(%Habit{}))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  @impl true
  def handle_event("edit", %{"id" => id}, socket) do
    habit = Habits.get_habit!(id)
    changeset = Habits.change_habit(habit)

    {:noreply,
     socket
     |> assign(habit: habit)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("cancel-edit", _params, socket) do
    {:noreply,
     socket
     |> assign(habit: %Habit{})
     |> assign_form(Habits.change_habit(%Habit{}))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    habit = Habits.get_habit!(id)
    {:ok, _} = Habits.delete_habit(habit)

    filter = if socket.assigns.current_filter == "todos", do: nil, else: socket.assigns.current_filter

    {:noreply,
     socket
     |> put_flash(:info, "Hábito removido com sucesso.")
     |> assign(habits: Habits.list_habits(filter))}
  end

  defp save_habit(%Habit{id: nil}, habit_params), do: Habits.create_habit(habit_params)
  defp save_habit(%Habit{} = habit, habit_params), do: Habits.update_habit(habit, habit_params)

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, form: to_form(changeset, as: "habit"))
  end
end
