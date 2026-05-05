defmodule PhoenixHelloWeb.TodoLive.Index do
  use PhoenixHelloWeb, :live_view

  alias PhoenixHello.Todos

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        <span id="title-anim" phx-hook=".ColorBlink">Listing Todos</span>
        <:actions>
          <.button variant="primary" navigate={~p"/todos/new"}>
            <.icon name="hero-plus" /> New Todo
          </.button>
        </:actions>
      </.header>

      <script :type={Phoenix.LiveView.ColocatedHook} name=".ColorBlink">
        export default {
          mounted() {
            this.el.addEventListener("mouseenter", () => {
              this.el.style.color = "blue";
            });
            this.el.addEventListener("mouseleave", () => {
              this.el.style.color = "";
            });
          }
        }
      </script>

      <div id="todos" phx-update="stream" class="mt-8 bg-white shadow rounded-lg p-4">
        <.live_component
          :for={{id, todo} <- @streams.todos}
          module={PhoenixHelloWeb.TodoLive.TodoItemComponent}
          id={id}
          todo={todo}
        />
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :todos, PhoenixHello.Todos.list_todos(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    todo = Todos.get_todo!(id)
    {:ok, _} = Todos.delete_todo(todo)

    {:noreply, stream_delete(socket, :todos, todo)}
  end

  @impl true
  def handle_info({:todo_updated, updated_todo}, socket) do
    {:noreply, stream_insert(socket, :todos, updated_todo)}
  end

  @impl true
  def handle_info({:todo_deleted, id}, socket) do
    {:noreply, stream_delete(socket, :todos, id)}
  end
end
