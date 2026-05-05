defmodule PhoenixHelloWeb.HelloHTML do
  use PhoenixHelloWeb, :html

  # 이 모듈이 존재해야 같은 이름의 폴더(hello_html/) 안에 있는
  # index.html.heex 파일을 Phoenix가 인식할 수 있습니다.
  embed_templates "hello_html/*"

  def greet(assigns) do
    ~H"""
    <h1>안녕하세요, {@name}님! 👋</h1>
    """
  end
end
