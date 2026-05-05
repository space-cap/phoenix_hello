defmodule PhoenixHelloWeb.MessageLive do
  use PhoenixHelloWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(messages: [], form: to_form(%{"text" => ""}))}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="max-w-lg mx-auto py-10">
        <h1 class="text-3xl font-bold mb-6">📝 메시지 보드</h1>
        
        <.form for={@form} id="message-form" phx-submit="add_message" class="flex gap-2 mb-8">
          <.input field={@form[:text]} type="text" placeholder="메시지를 입력하세요..." />
          <button type="submit" class="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600">
            전송
          </button>
        </.form>
        
        <ul class="space-y-2">
          <%= for {msg, i} <- Enum.with_index(@messages) do %>
            <li class="flex items-center gap-2 p-3 bg-gray-100 rounded-lg">
              <span class="text-gray-400 text-sm">{i + 1}.</span> <span>{msg}</span>
            </li>
          <% end %>
        </ul>
      </div>
    </Layouts.app>
    """
  end

  def handle_event("add_message", %{"text" => text}, socket) when text != "" do
    messages = [text | socket.assigns.messages]

    {:noreply,
     socket
     |> assign(messages: messages, form: to_form(%{"text" => ""}))}
  end

  def handle_event("add_message", _params, socket) do
    {:noreply, socket}
  end
end
