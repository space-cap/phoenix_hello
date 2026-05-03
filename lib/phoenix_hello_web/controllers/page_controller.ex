defmodule PhoenixHelloWeb.PageController do
  use PhoenixHelloWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
