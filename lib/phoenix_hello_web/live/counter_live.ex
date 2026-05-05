defmodule PhoenixHelloWeb.CounterLive do
  use PhoenixHelloWeb, :live_view

  # PubSub 토픽 이름 (방송 채널 이름 같은 것)
  @topic "counter:global"

  def mount(_params, _session, socket) do
    # 이 LiveView가 시작될 때 "counter:global" 채널을 구독(청취 시작)
    if connected?(socket) do
      Phoenix.PubSub.subscribe(PhoenixHello.PubSub, @topic)
    end

    {:ok, assign(socket, count: 0)}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="text-center py-20">
        <h1 class="text-4xl font-bold mb-8">실시간 카운터 (전체 공유)</h1>
        
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

  # 버튼 클릭 시 → 새 count 계산 → 전체 채널에 방송!
  def handle_event("increment", _params, socket) do
    new_count = socket.assigns.count + 1
    Phoenix.PubSub.broadcast(PhoenixHello.PubSub, @topic, {:count_updated, new_count})
    {:noreply, assign(socket, count: new_count)}
  end

  def handle_event("decrement", _params, socket) do
    new_count = socket.assigns.count - 1
    Phoenix.PubSub.broadcast(PhoenixHello.PubSub, @topic, {:count_updated, new_count})
    {:noreply, assign(socket, count: new_count)}
  end

  def handle_event("reset", _params, socket) do
    Phoenix.PubSub.broadcast(PhoenixHello.PubSub, @topic, {:count_updated, 0})
    {:noreply, assign(socket, count: 0)}
  end

  # 다른 브라우저에서 방송(broadcast)이 오면 이 함수가 실행됨!
  def handle_info({:count_updated, new_count}, socket) do
    {:noreply, assign(socket, count: new_count)}
  end
end
