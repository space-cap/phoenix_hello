defmodule PhoenixHello.TodosFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PhoenixHello.Todos` context.
  """

  @doc """
  Generate a todo.
  """
  def todo_fixture(attrs \\ %{}) do
    {:ok, todo} =
      attrs
      |> Enum.into(%{
        done: true,
        title: "some title"
      })
      |> PhoenixHello.Todos.create_todo()

    todo
  end
end
