defmodule EcoHabitsWeb.UserLive.Profile do
  use EcoHabitsWeb, :live_view

  alias EcoHabits.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="mx-auto max-w-lg space-y-6 mt-8">

        <div class="bg-white p-6 rounded-xl border border-zinc-200 shadow-sm space-y-4">
          <div class="flex items-center justify-between">
            <div>
              <h1 class="text-2xl font-bold text-zinc-900"><%= @current_user.name %></h1>
              <p class="text-sm text-zinc-500"><%= @current_user.email %></p>
            </div>
            <div class="bg-green-100 text-green-800 px-4 py-2 rounded-lg text-center">
              <span class="block text-2xl font-black"><%= @current_user.total_points %></span>
              <span class="text-xs font-bold uppercase tracking-wider">Pontos</span>
            </div>
          </div>

          <div class="border-t border-zinc-100 pt-4">
            <h2 class="text-xs font-bold text-zinc-400 uppercase tracking-wider mb-1">Sobre mim (Bio)</h2>
            <p class="text-zinc-700 italic">
              <%= if @current_user.bio, do: @current_user.bio, else: "Você ainda não escreveu uma bio..." %>
            </p>
          </div>
        </div>

        <div class="bg-zinc-50 p-6 rounded-xl border border-zinc-200">
          <h2 class="text-lg font-semibold text-zinc-900 mb-4">Editar Perfil</h2>

          <.form for={@form} id="profile_form" phx-submit="save" phx-change="validate" class="space-y-4">

            <div class="space-y-1">
              <label class="block text-sm font-semibold text-zinc-900">Alterar Nome</label>
              <.input field={@form[:name]} type="text" required />
            </div>

            <div class="space-y-1">
              <label class="block text-sm font-semibold text-zinc-900">Sua Biografia</label>
              <.input field={@form[:bio]} type="textarea" placeholder="Conte um pouco sobre seus hábitos ecológicos..." />
            </div>

            <div class="pt-2">
              <button
                type="submit"
                phx-disable-with="Salvando..."
                class="w-full bg-green-600 hover:bg-green-700 text-white font-semibold py-2 px-4 rounded-lg shadow transition-colors duration-200 cursor-pointer"
              >
                Salvar Alterações
              </button>
            </div>
          </.form>
        </div>

      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    # O escopo padrão do Phoenix armazena o usuário dentro de current_scope.user
    user = socket.assigns.current_scope.user
    changeset = EcoHabits.Accounts.User.profile_changeset(user, %{})

    {:ok,
     socket
     |> assign(current_user: user)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"user" => profile_params}, socket) do
    changeset =
      socket.assigns.current_user
      |> EcoHabits.Accounts.User.profile_changeset(profile_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  @impl true
  def handle_event("save", %{"user" => profile_params}, socket) do
    case Accounts.update_user_profile(socket.assigns.current_user, profile_params) do
      {:ok, updated_user} ->
        {:noreply,
         socket
         # Atualiza o usuário na tela para refletir o novo nome/bio instantaneamente
         |> assign(current_user: updated_user)
         |> put_flash(:info, "Perfil atualizado com sucesso!")
         # Recarrega o formulário com os novos dados salvos
         |> assign_form(EcoHabits.Accounts.User.profile_changeset(updated_user, %{}))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, form: to_form(changeset, as: "user"))
  end
end
