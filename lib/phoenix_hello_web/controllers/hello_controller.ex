defmodule PhoenixHelloWeb.HelloController do
  use PhoenixHelloWeb, :controller

  def index(conn, _params) do
    render(conn, :index)
  end
end