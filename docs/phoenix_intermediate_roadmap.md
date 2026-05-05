# 🚀 Phoenix 중급 학습 로드맵

> 초보자 5단계를 완주한 당신을 위한 다음 도전!

---

## 초보 → 중급 체크리스트

초보 단계에서 배운 것:
- [x] 라우터, 컨트롤러, 뷰
- [x] LiveView 기본 (상태, 이벤트)
- [x] PubSub (다중 브라우저 실시간)
- [x] Agent (공유 상태)
- [x] Ecto 기본 CRUD

중급 단계에서 배울 것:
- [ ] 인증/인가 (로그인/회원가입)
- [ ] Ecto 심화 (관계, 쿼리 최적화)
- [ ] LiveView 심화 (컴포넌트, 파일 업로드)
- [ ] 테스트 작성
- [ ] 배포 (실제 인터넷에 올리기)
- [ ] 실전 프로젝트 (실시간 채팅앱)

---

## 1단계: 인증/인가 (로그인 시스템) 🔐

### 왜 중요한가요?
대부분의 실제 앱은 "로그인한 사용자만 접근 가능"한 기능이 있어요.
Phoenix는 이걸 자동으로 만들어주는 명령어가 있어요!

### `mix phx.gen.auth` 명령어

```bash
mix phx.gen.auth Accounts User users
mix ecto.migrate
```

이 한 줄로 생성되는 것들:
- 회원가입 페이지
- 로그인/로그아웃
- 이메일 인증
- 비밀번호 재설정
- 세션 관리
- "로그인한 사용자만" 접근 제한

### 핵심 개념

**인증 (Authentication)**: "이 사람이 누구인가?" → 로그인
**인가 (Authorization)**: "이 사람이 이걸 할 수 있는가?" → 권한

```elixir
# router.ex 에 자동 생성되는 패턴
scope "/", PhoenixHelloWeb do
  pipe_through [:browser, :require_authenticated_user]  # ← 로그인 필수!

  live "/dashboard", DashboardLive  # 로그인해야만 접근 가능
end
```

### 실습 목표
- 회원가입 → 로그인 → "내 TODO만 보기" 기능 추가
- 로그인하지 않으면 `/todos`에 접근 못하게 막기

---

## 2단계: Ecto 심화 — 회원별 TODO 만들기 (1:N 관계) 🔗

### 개념: 초보 단계의 한계
지금 우리가 만든 TODO 앱은 **누가 작성한 건지** 알 수 없고, 모든 사람이 똑같은 할 일 목록을 공유합니다.
1단계에서 로그인(User) 기능을 만들었으니, 이제 **"이 TODO는 누가 만들었나(user_id)"** 정보를 DB에 추가해서 **각자의 TODO**만 보이게 연결해볼 거예요. 이것이 관계형 DB의 1:N (One-to-Many) 관계입니다.

---

### 실습 순서: 직접 따라 해보세요!

#### (1) DB 마이그레이션 — `todos` 테이블에 `user_id` 추가하기

터미널을 열고 다음 명령어를 입력하세요:
```bash
mix ecto.gen.migration add_user_id_to_todos
```
`priv/repo/migrations/` 폴더에 새 파일(`숫자_add_user_id_to_todos.exs`)이 생깁니다. 이 파일을 열어서 아래처럼 수정하세요:

```elixir
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
```
저장 후, 마이그레이션을 실행해서 실제 DB에 반영합니다:
```bash
mix ecto.migrate
```

#### (2) 스키마(Schema) 연결하기

이제 Elixir 코드에 "User와 Todo가 연결되어 있다"고 알려줘야 해요.

**`lib/phoenix_hello/todos/todo.ex` 수정:**
```elixir
defmodule PhoenixHello.Todos.Todo do
  use Ecto.Schema
  import Ecto.Changeset

  schema "todos" do
    field :title, :string
    field :done, :boolean, default: false
    # 이 줄을 추가하세요! (Todo는 User에 속한다)
    belongs_to :user, PhoenixHello.Accounts.User

    timestamps(type: :utc_datetime)
  end

  def changeset(todo, attrs) do
    todo
    |> cast(attrs, [:title, :done, :user_id]) # :user_id 추가!
    |> validate_required([:title, :done])
  end
end
```

**`lib/phoenix_hello/accounts/user.ex` 수정:**
```elixir
  schema "users" do
    field :email, :string
    field :password, :string, virtual: true, redact: true
    field :hashed_password, :string, redact: true
    field :confirmed_at, :naive_datetime
    
    # 이 줄을 추가하세요! (User는 여러 개의 Todo를 가진다)
    has_many :todos, PhoenixHello.Todos.Todo

    timestamps(type: :utc_datetime)
  end
```

#### (3) 특정 사용자의 TODO만 가져오도록 수정 (Context)

`lib/phoenix_hello/todos.ex` 파일을 엽니다. 기존에는 `Repo.all(Todo)`로 모든 TODO를 가져왔죠? 이제 사용자 ID를 받아서 필터링하는 함수를 만듭니다.

```elixir
  # 파일 상단에 아래 import 추가
  import Ecto.Query

  # 기존 list_todos/0 아래에 새 함수 추가
  def list_todos_for_user(user_id) do
    Todo
    |> where([t], t.user_id == ^user_id)
    |> Repo.all()
  end
```

#### (4) LiveView에서 현재 로그인한 유저 연결하기

`lib/phoenix_hello_web/live/todo_live/index.ex`를 열고, 기존 `Todos.list_todos()`를 방금 만든 함수로 교체합니다. 로그인 정보는 `@current_user`에 들어있습니다.

```elixir
  @impl true
  def mount(_params, _session, socket) do
    # 로그인한 유저의 ID로 TODO 목록 가져오기
    user_id = socket.assigns.current_user.id
    {:ok, stream(socket, :todos, PhoenixHello.Todos.list_todos_for_user(user_id))}
  end
```

그리고 새 TODO를 생성할 때 누구의 것인지(`user_id`) 넣어줘야 합니다. `form.ex`나 해당 로직을 처리하는 곳에서 `attrs`에 `user_id: user.id`를 추가하면 됩니다.

### ✅ 확인 방법
1. 브라우저에서 `/users/register`로 가입 후 로그인
2. `/todos`에 접속하여 할 일을 추가해보기
3. 로그아웃 후 다른 계정으로 가입/로그인하면 **서로 다른 TODO 목록**이 보이는지 확인!

---

## 3단계: LiveView 심화 🔥

### LiveComponent — 재사용 가능한 UI 조각

컴포넌트는 "복잡한 UI를 독립적인 조각으로 나누는" 도구예요.

```elixir
# lib/phoenix_hello_web/live/components/todo_item.ex
defmodule PhoenixHelloWeb.TodoItem do
  use PhoenixHelloWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="flex items-center gap-2 p-3 border rounded">
      <input type="checkbox" checked={@todo.done}
             phx-click="toggle" phx-value-id={@todo.id} phx-target={@myself} />
      <span class={[@todo.done && "line-through text-gray-400"]}>
        {@todo.title}
      </span>
    </div>
    """
  end

  def handle_event("toggle", %{"id" => id}, socket) do
    # 이 컴포넌트 안에서만 이벤트 처리!
    {:noreply, socket}
  end
end
```

```elixir
# 부모 LiveView에서 컴포넌트 사용
<.live_component module={PhoenixHelloWeb.TodoItem}
                 id={"todo-#{todo.id}"}
                 todo={todo} />
```

### LiveView 스트림 — 대용량 목록 처리

초보 때 배운 `assign(messages: [...])`은 목록이 커질수록 메모리를 많이 써요.
**스트림**은 이 문제를 해결해줘요.

```elixir
def mount(_params, _session, socket) do
  {:ok, stream(socket, :todos, Todos.list_todos())}
  #      ↑ 일반 assign 대신 stream 사용!
end

# 템플릿에서
<div id="todos" phx-update="stream">  # ← phx-update="stream" 필수!
  <div :for={{id, todo} <- @streams.todos} id={id}>
    {todo.title}
  </div>
</div>
```

### 파일 업로드

```elixir
def mount(_params, _session, socket) do
  {:ok,
   socket
   |> allow_upload(:avatar, accept: ~w(.jpg .png), max_entries: 1)}
end

def render(assigns) do
  ~H"""
  <form phx-submit="save" phx-change="validate">
    <.live_file_input upload={@uploads.avatar} />
    <button type="submit">업로드</button>
  </form>
  """
end

def handle_event("save", _params, socket) do
  uploaded_files =
    consume_uploaded_entries(socket, :avatar, fn %{path: path}, _entry ->
      dest = Path.join("priv/static/uploads", Path.basename(path))
      File.cp!(path, dest)
      {:ok, "/uploads/#{Path.basename(dest)}"}
    end)

  {:noreply, assign(socket, uploaded_files: uploaded_files)}
end
```

### JS Hooks — JavaScript가 꼭 필요할 때

LiveView로 해결 안 되는 경우 (예: 지도, 차트, 특수 애니메이션):

```javascript
// assets/js/hooks/chart_hook.js
const ChartHook = {
  mounted() {
    this.chart = new Chart(this.el, { type: "line", data: {} })

    // 서버에서 새 데이터를 받으면 차트 업데이트
    this.handleEvent("update_chart", (data) => {
      this.chart.data = data
      this.chart.update()
    })
  }
}
export default ChartHook
```

```elixir
# LiveView에서 JS로 이벤트 전송
def handle_info({:new_data, data}, socket) do
  {:noreply, push_event(socket, "update_chart", %{labels: data.labels, values: data.values})}
end
```

---

## 4단계: 테스트 작성 ✅

### 왜 테스트가 중요한가요?
- 코드를 수정할 때 "다른 기능이 망가지지 않았는지" 자동으로 확인해줘요
- Phoenix는 기본적으로 테스트 도구가 포함되어 있어요

### Ecto 컨텍스트 테스트

```elixir
# test/phoenix_hello/todos_test.exs
defmodule PhoenixHello.TodosTest do
  use PhoenixHello.DataCase  # DB 테스트 환경 설정

  alias PhoenixHello.Todos

  test "list_todos/0 returns all todos" do
    todo = todo_fixture()  # 테스트용 데이터 생성
    assert Todos.list_todos() == [todo]
  end

  test "create_todo/1 with valid data creates a todo" do
    assert {:ok, todo} = Todos.create_todo(%{title: "공부하기", done: false})
    assert todo.title == "공부하기"
  end

  test "create_todo/1 with invalid data returns error" do
    assert {:error, changeset} = Todos.create_todo(%{})  # 빈 데이터
    assert "can't be blank" in errors_on(changeset).title
  end
end
```

### LiveView 테스트

```elixir
# test/phoenix_hello_web/live/todo_live_test.exs
defmodule PhoenixHelloWeb.TodoLiveTest do
  use PhoenixHelloWeb.ConnCase

  import Phoenix.LiveViewTest

  test "displays todos", %{conn: conn} do
    todo = todo_fixture(title: "테스트 할 일")

    {:ok, view, html} = live(conn, ~p"/todos")

    assert html =~ "테스트 할 일"
    assert has_element?(view, "#todo-#{todo.id}")
  end

  test "can create a new todo", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/todos/new")

    view
    |> form("#todo-form", todo: %{title: "새 할 일", done: false})
    |> render_submit()

    assert has_element?(view, "[data-role=todo-title]", "새 할 일")
  end
end
```

### 테스트 실행

```bash
mix test                     # 전체 테스트
mix test test/phoenix_hello/todos_test.exs  # 특정 파일만
mix test --failed            # 실패한 테스트만 다시 실행
```

---

## 5단계: 배포 (실제 인터넷에 올리기) 🌍

### Fly.io 배포 (가장 쉬운 방법)

Fly.io는 Phoenix 앱 배포에 최적화된 플랫폼이에요. 무료 플랜도 있어요!

#### 설치 및 로그인
```bash
# Fly CLI 설치 (https://fly.io/docs/hands-on/install-flyctl/)
curl -L https://fly.io/install.sh | sh

# 로그인
fly auth login
```

#### 배포 설정
```bash
# 프로젝트 루트에서 실행
fly launch
# 이 명령이 자동으로:
# - Dockerfile 생성
# - fly.toml 생성
# - PostgreSQL DB 연결 설정
```

#### 배포
```bash
fly deploy        # 코드 배포
fly open          # 브라우저로 열기
fly logs          # 실시간 로그 확인
```

### 환경 변수 설정 (비밀 정보)

```bash
# 배포 서버에 비밀 키 설정
fly secrets set DATABASE_URL=postgres://...
fly secrets set SECRET_KEY_BASE=...
```

`runtime.exs`에서 환경 변수로 읽음:
```elixir
config :phoenix_hello, PhoenixHello.Repo,
  url: System.get_env("DATABASE_URL")  # 환경 변수에서 읽기!
```

---

## 6단계: 실전 프로젝트 — 실시간 채팅 앱 💬

### 지금까지 배운 것 총정리!

채팅 앱은 중급 단계의 모든 기술을 사용해요:

```
인증(mix phx.gen.auth)  →  로그인한 사람만 채팅 가능
Ecto 관계              →  Message belongs_to User
LiveView               →  실시간 메시지 표시
PubSub                 →  다른 사람 메시지 수신
LiveView Stream        →  메시지 목록 효율적 관리
파일 업로드            →  이미지 전송
테스트                 →  채팅 기능 검증
배포                   →  Fly.io에 올리기
```

### 채팅 앱 구조

```
lib/
├── phoenix_hello/
│   ├── accounts/          ← 회원 관리 (phx.gen.auth)
│   │   └── user.ex
│   └── chat/              ← 채팅 기능 (phx.gen.live)
│       ├── message.ex     ← Message 스키마
│       └── room.ex        ← Room 스키마
└── phoenix_hello_web/
    └── live/
        └── chat_live/
            ├── index.ex   ← 채팅방 목록
            └── room.ex    ← 채팅방 (LiveView + PubSub!)
```

### 채팅방 핵심 코드

```elixir
defmodule PhoenixHelloWeb.ChatLive.Room do
  use PhoenixHelloWeb, :live_view

  def mount(%{"id" => room_id}, _session, socket) do
    topic = "room:#{room_id}"

    if connected?(socket) do
      Phoenix.PubSub.subscribe(PhoenixHello.PubSub, topic)
    end

    messages = Chat.list_messages(room_id)

    {:ok,
     socket
     |> assign(room_id: room_id, topic: topic)
     |> stream(:messages, messages)}  # 스트림으로 효율적 관리!
  end

  def handle_event("send_message", %{"text" => text}, socket) do
    user = socket.assigns.current_user
    {:ok, message} = Chat.create_message(%{
      text: text,
      user_id: user.id,
      room_id: socket.assigns.room_id
    })

    # 같은 방의 모든 사람에게 방송!
    Phoenix.PubSub.broadcast(
      PhoenixHello.PubSub,
      socket.assigns.topic,
      {:new_message, message}
    )

    {:noreply, socket}
  end

  # 다른 사람이 보낸 메시지 수신
  def handle_info({:new_message, message}, socket) do
    {:noreply, stream_insert(socket, :messages, message)}
  end
end
```

---

## 🗺️ 중급 학습 지도

```
1단계 (인증)       →  로그인/회원가입, 접근 제한
2단계 (Ecto 심화)  →  테이블 관계, 쿼리 최적화, 트랜잭션
3단계 (LiveView)   →  컴포넌트, 스트림, 파일 업로드, JS 훅
4단계 (테스트)     →  ExUnit, LiveView 테스트, 자동화
5단계 (배포)       →  Fly.io, 환경 변수, 프로덕션 설정
6단계 (실전)       →  위 모든 기술을 통합한 채팅 앱!
```

---

## 📚 추천 학습 자료

| 자료 | 설명 | 링크 |
|------|------|------|
| Programming Phoenix (책) | 가장 좋은 Phoenix 교재 | https://pragprog.com/titles/phoenix14/ |
| Elixir in Action (책) | Elixir/OTP 심화 | https://www.manning.com/books/elixir-in-action |
| Fly.io Elixir 가이드 | 배포 공식 문서 | https://fly.io/docs/elixir/ |
| Elixir School | 무료 한국어 강의 | https://elixirschool.com/ko |
| Phoenix Forum | 커뮤니티 Q&A | https://elixirforum.com |
| Pragmatic Studio | Phoenix LiveView 영상 강의 | https://pragmaticstudio.com/phoenix-liveview |

---

## 중급 이후 (고급) 미리보기

중급을 마치면 이런 것들이 기다리고 있어요:

| 고급 주제 | 설명 |
|-----------|------|
| **OTP / GenServer** | 백그라운드 작업, 스케줄러, 상태 머신 |
| **Phoenix Channels** | WebSocket 직접 다루기 |
| **Distributed Elixir** | 여러 서버가 하나처럼 동작 |
| **Broadway** | 대용량 데이터 파이프라인 |
| **Nx / Axon** | Elixir로 머신러닝! |
| **Membrane** | 미디어 스트리밍 |

> 💬 **팁**: 중급 단계는 순서보다 "실제 프로젝트를 만들면서 필요한 것을 찾아 배우는 것"이 효과적이에요.
> 만들고 싶은 앱이 있다면 바로 시작해보세요! 🚀
