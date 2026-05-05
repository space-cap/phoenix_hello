defmodule PhoenixHelloWeb.CounterLive do
  use PhoenixHelloWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, count: 0)}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="text-center py-20">
        <h1 class="text-4xl font-bold mb-8">실시간 카운터</h1>
        
        <p class="text-8xl font-mono mb-10">{@count}</p>
        
        <div class="flex gap-4 justify-center">
          <button
            phx-click="decrement"
            class="px-6 py-3 bg-red-500 text-white rounded-lg text-xl hover:bg-red-600"
          >
            ➖ 감소
          </button>
          <button
            phx-click="reset"
            class="px-6 py-3 bg-gray-500 text-white rounded-lg text-xl hover:bg-gray-600"
          >
            🔄 초기화
          </button>
          <button
            phx-click="increment"
            class="px-6 py-3 bg-blue-500 text-white rounded-lg text-xl hover:bg-blue-600"
          >
            ➕ 증가
          </button>
        </div>
      </div>
    </Layouts.app>
    """
  end

  def handle_event("increment", _params, socket) do
    {:noreply, update(socket, :count, &(&1 + 1))}
  end

  def handle_event("decrement", _params, socket) do
    {:noreply, update(socket, :count, &(&1 - 1))}
  end

  def handle_event("reset", _params, socket) do
    {:noreply, assign(socket, count: 0)}
  end
end
