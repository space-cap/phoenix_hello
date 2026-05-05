defmodule PhoenixHello.Todos.Todo do
  use Ecto.Schema
  import Ecto.Changeset

  schema "todos" do
    field :title, :string
    field :done, :boolean, default: false
    belongs_to :user, PhoenixHello.Accounts.User

    timestamps(type: :utc_datetime)
  end

  def changeset(todo, attrs) do
    todo
    |> cast(attrs, [:title, :done])
    |> validate_required([:title, :done])
  end
end
