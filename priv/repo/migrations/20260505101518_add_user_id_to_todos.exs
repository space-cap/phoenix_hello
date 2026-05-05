defmodule PhoenixHello.Repo.Migrations.AddUserIdToTodos do
  use Ecto.Migration

  def change do
    alter table(:todos) do
      # users 테이블을 참조하는 user_id 컬럼 추가
      # on_delete: :delete_all 은 유저가 탈퇴하면 그 유저의 todo도 다 지우라는 뜻이에요!
      add :user_id, references(:users, on_delete: :delete_all)
    end

    # user_id로 검색을 빨리 하기 위해 인덱스(색인) 추가
    create index(:todos, [:user_id])
  end
end
