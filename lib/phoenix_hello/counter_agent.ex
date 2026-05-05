defmodule PhoenixHello.CounterAgent do
  @moduledoc """
  카운터의 현재 값을 서버 메모리에 보관하는 공유 상태 저장소.
  서버가 살아있는 동안 누가 접속해도 현재 값을 유지합니다.
  """
  use Agent

  def start_link(_opts) do
    Agent.start_link(fn -> 0 end, name: __MODULE__)
  end

  # 현재 카운터 값 읽기
  def get do
    Agent.get(__MODULE__, & &1)
  end

  # 카운터 값 저장
  def set(value) do
    Agent.update(__MODULE__, fn _ -> value end)
  end
end
