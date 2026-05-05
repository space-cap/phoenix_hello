defmodule PhoenixHelloWeb.HelloController do
  use PhoenixHelloWeb, :controller

  def index(conn, _params) do
    render(conn, :index)
  end

  def greet(conn, %{"name" => name}) do
    render(conn, :greet, name: name)
  end
end
