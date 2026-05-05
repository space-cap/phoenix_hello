defmodule PhoenixHelloWeb.TodoLive.TodoItemComponent do
  use PhoenixHelloWeb, :live_component
  alias PhoenixHello.Todos

  def render(assigns) do
    ~H"""
    <div id={@id} class="flex items-center gap-4 p-3 border-b hover:bg-gray-50 transition">
      <input
        type="checkbox"
        checked={@todo.done}
        phx-click="toggle_done"
        phx-target={@myself}
        class="w-5 h-5 rounded"
      />
      <span class={[@todo.done && "line-through text-gray-400", "flex-grow font-medium"]}>
        {@todo.title}
      </span>
      <.link navigate={~p"/todos/#{@todo}/edit"} class="text-sm text-blue-500 hover:underline">
        수정
      </.link>
      <.link
        phx-click="delete"
        phx-value-id={@todo.id}
        data-confirm="정말 삭제하시겠습니까?"
        class="text-sm text-red-500 hover:underline"
      >
        삭제
      </.link>
    </div>
    """
  end

  def handle_event("toggle_done", _params, socket) do
    # 이 컴포넌트 안에서만 이벤트 처리 (phx-target={@myself})
    todo = socket.assigns.todo
    {:ok, updated_todo} = Todos.update_todo(todo, %{done: !todo.done})

    # 부모 LiveView에 변경 사항 알림
    send(self(), {:todo_updated, updated_todo})
    {:noreply, assign(socket, :todo, updated_todo)}
  end
end
