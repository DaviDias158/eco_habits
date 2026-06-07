defmodule EcoHabitsWeb.TrackerLive.Index do
  use EcoHabitsWeb, :live_view

  alias EcoHabits.Habits
  alias EcoHabits.Trackers

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="mx-auto max-w-6xl mt-8 grid grid-cols-1 lg:grid-cols-3 gap-8">

        <div class="bg-white p-6 rounded-xl border border-zinc-200 shadow-sm h-fit space-y-4">
          <h2 class="text-xl font-bold text-zinc-900">Praticou um Hábito Hoje?</h2>
          <p class="text-sm text-zinc-500">Clique no botão para registrar sua ação sustentável e ganhar pontos!</p>

          <div class="space-y-3 pt-2">
            <%= if Enum.empty?(@available_habits) do %>
              <p class="text-sm text-zinc-400 italic">Nenhum hábito cadastrado no sistema ainda.</p>
            <% end %>
            <%= for habit <- @available_habits do %>
              <div class="flex items-center justify-between p-3 bg-zinc-50 rounded-lg border border-zinc-100">
                <div class="max-w-[180px]">
                  <span class="font-semibold text-sm text-zinc-900 block truncate"><%= habit.name %></span>
                  <span class="text-xs text-green-600 font-bold uppercase"><%= habit.category %></span>
                </div>
                <button
                  phx-click="check_in"
                  phx-value-habit_id={habit.id}
                  class="bg-green-600 hover:bg-green-700 text-white font-bold text-xs py-2 px-3 rounded-lg shadow transition cursor-pointer"
                >
                  +<%= habit.points %> Pts
                </button>
              </div>
            <% end %>
          </div>
        </div>

        <div class="bg-white p-6 rounded-xl border border-zinc-200 shadow-sm h-fit space-y-6">
          <div class="border-b border-zinc-100 pb-4">
            <h2 class="text-xl font-bold text-zinc-900">Seu Dashboard</h2>
            <p class="text-sm text-zinc-500">Histórico pessoal de hábitos praticados.</p>
          </div>

          <div class="bg-zinc-50 p-3 rounded-lg border border-zinc-100">
            <span class="text-xs font-bold text-zinc-500 uppercase tracking-wider block mb-2">Suas Conquistas de Hoje:</span>
            <div class="flex flex-wrap gap-2">
              <%= if Enum.empty?(@badges) do %>
                <span class="text-xs text-zinc-400 italic">Pratique hábitos para desbloquear medalhas!</span>
              <% end %>
              <%= for badge <- @badges do %>
                <span class="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-medium bg-green-100 text-green-800 border border-green-200 shadow-sm animate-bounce">
                  🎖️ <%= String.capitalize(badge) %>
                </span>
              <% end %>
            </div>
          </div>

          <div class="space-y-3 max-h-[400px] overflow-y-auto pr-1">
            <%= if Enum.empty?(@user_check_ins) do %>
              <p class="text-sm text-zinc-400 italic text-center py-4">Você ainda não fez nenhum check-in.</p>
            <% end %>
            <%= for check_in <- @user_check_ins do %>
              <div class="flex items-center justify-between p-3 border-l-4 border-green-500 bg-zinc-50 rounded-r-lg">
                <div>
                  <span class="font-semibold text-sm text-zinc-900 block"><%= check_in.habit.name %></span>
                  <span class="text-xs text-zinc-400">Praticado em: <%= Calendar.strftime(check_in.date, "%d/%m/%Y") %></span>
                </div>
                <span class="text-sm font-black text-green-600">+<%= check_in.habit.points %></span>
              </div>
            <% end %>
          </div>
        </div>

        <div class="bg-zinc-900 text-white p-6 rounded-xl shadow-xl h-fit space-y-4">
          <div class="flex items-center justify-between border-b border-zinc-800 pb-4">
            <div>
              <h2 class="text-xl font-bold text-green-400">Feed da Comunidade</h2>
              <p class="text-xs text-zinc-400">Atualizações em tempo real (PubSub)</p>
            </div>
            <span class="flex h-3 w-3 relative">
              <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-green-400 opacity-75"></span>
              <span class="relative inline-flex rounded-full h-3 w-3 bg-green-500"></span>
            </span>
          </div>

          <div id="community-feed" phx-update="stream" class="space-y-4 max-h-[450px] overflow-y-auto pr-1">
            <%= for {id, check_in} <- @streams.feed_check_ins do %>
              <div id={id} class="p-3 bg-zinc-800 rounded-lg border border-zinc-700 space-y-1 animate-fadeIn">
                <div class="flex justify-between items-start text-xs">
                  <span class="font-bold text-zinc-300"><%= check_in.user.name || "Usuário" %></span>
                  <span class="text-zinc-500"><%= Calendar.strftime(check_in.inserted_at, "%H:%M:%S") %></span>
                </div>
                <p class="text-sm text-zinc-200">
                  Praticou <span class="text-green-400 font-semibold"><%= check_in.habit.name %></span>
                  e garantiu <span class="font-bold text-green-400">+<%= check_in.habit.points %></span> pontos!
                </p>
              </div>
            <% end %>
          </div>
        </div>

      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    # Ativa a escuta do PubSub para este processo LiveView (RT05 / RF09)
    if connected?(socket), do: Trackers.subscribe()

    user_id = socket.assigns.current_scope.user.id
    available_habits = Habits.list_habits()
    user_check_ins = Trackers.list_user_check_ins(user_id)
    feed_list = Trackers.list_community_feed()
    badges = EcoHabits.Trackers.compute_badges(user_check_ins) # Computa conquistas usando reduce e map (Funções de Alta Ordem)

    {:ok,
     socket
     |> assign(current_user_id: user_id)
     |> assign(available_habits: available_habits)
     |> assign(user_check_ins: user_check_ins)
     |> assign(badges: badges) # Injeta os badges na tela
     # Usamos streams para o feed gerenciar a inserção em tempo real de forma performática
     |> stream(:feed_check_ins, feed_list)}
  end

  @impl true
  def handle_event("check_in", %{"habit_id" => habit_id}, socket) do
    user_id = socket.assigns.current_user_id
    today = Date.utc_today()

    attrs = %{
      "user_id" => user_id,
      "habit_id" => habit_id,
      "date" => today
    }

    case Trackers.create_check_in(attrs) do
      {:ok, _check_in} ->
        updated_check_ins = Trackers.list_user_check_ins(user_id)

        {:noreply,
         socket
         |> put_flash(:info, "Check-in realizado com sucesso!")
         # |> assign(user_check_ins: Trackers.list_user_check_ins(user_id))}
         |> assign(user_check_ins: updated_check_ins)
         |> assign(badges: Trackers.compute_badges(updated_check_ins))} # Recalcula aqui

      {:error, changeset} ->
        # Captura o erro do Ecto (RF07 / RT06) e exibe na tela de forma amigável
        error_msg =
          case changeset.errors[:user_id] do
            {msg, _} -> msg
            nil -> "Não foi possível realizar o check-in."
          end

        {:noreply, put_flash(socket, :error, error_msg)}
    end
  end

  # Escuta as mensagens disparadas pelo PubSub (RT05 / RF09)
  @impl true
  def handle_info({:new_check_in, check_in}, socket) do
    {:noreply,
     socket
     # O insert_at: :at_front coloca o novo elemento no topo da lista do feed visualmente
     |> stream_insert(:feed_check_ins, check_in, at_front: true)}
  end
end
