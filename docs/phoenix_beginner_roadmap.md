# 🐦 Phoenix 초보자 학습 로드맵

> Hello World를 완성한 당신, 이제 진짜 Phoenix를 맛볼 차례입니다! 🚀

---

## 학습 단계 한눈에 보기

```
[1단계] 라우터 이해하기
    ↓
[2단계] 컨트롤러 & 뷰 구조 파악
    ↓
[3단계] LiveView로 실시간 카운터 만들기  ⭐ Phoenix 핵심!
    ↓
[4단계] 폼으로 사용자 입력 받기
    ↓
[5단계] Ecto로 DB 연동 (TODO 앱 완성!)
```

---

## 1단계: 라우터(Router) 이해하기

### 개념
"어떤 URL로 들어오면 어떤 코드를 실행할지" 결정하는 교통 정리 역할이에요.

### 실습: 새 페이지 추가해보기

**`lib/phoenix_hello_web/router.ex`** 파일을 열고 아래처럼 경로를 추가해보세요:

```elixir
scope "/", PhoenixHelloWeb do
  pipe_through :browser

  get "/", PageController, :home
  get "/hello", HelloController, :index   # ← 이미 있을 거예요
  get "/about", PageController, :about   # ← 이걸 새로 추가!
end
```

**`lib/phoenix_hello_web/controllers/page_controller.ex`** 에 액션 추가:

```elixir
def about(conn, _params) do
  render(conn, :about)
end
```

**`lib/phoenix_hello_web/controllers/page_html/about.html.heex`** 템플릿 생성:

```html
<h1>About 페이지</h1>
<p>안녕하세요! Phoenix로 만든 첫 번째 사이트입니다. 🎉</p>
```

### ✅ 확인 방법
브라우저에서 `http://localhost:4000/about` 접속해보기

---

## 2단계: 컨트롤러 & 뷰 구조 파악

### 개념
Phoenix는 요청이 들어오면 이렇게 처리해요:

```
URL 요청 → Router → Controller → View → Template(HTML)
```

| 파일 | 역할 | 예시 |
|------|------|------|
| `router.ex` | URL 매핑 | `/hello` → HelloController |
| `hello_controller.ex` | 데이터 준비 | DB 조회, 변수 세팅 |
| `hello_html.ex` | 렌더링 설정 | 어떤 템플릿 쓸지 |
| `index.html.heex` | 화면(HTML) | 실제 보여지는 화면 |

### 실습: 이름을 URL로 받아서 인사하기

**router.ex** 에 추가:
```elixir
get "/greet/:name", HelloController, :greet
```

**hello_controller.ex** 에 추가:
```elixir
def greet(conn, %{"name" => name}) do
  render(conn, :greet, name: name)
end
```

**hello_html.ex** 에 추가:
```elixir
def greet(assigns) do
  ~H"""
  <h1>안녕하세요, {@name}님! 👋</h1>
  """
end
```

> 💡 **"`.heex` 파일 없이 왜 화면이 나와요?"** 라고 궁금하셨죠?
>
> Phoenix에서 HTML을 출력하는 방법은 **두 가지**예요:
>
> **방법 1: `.heex` 파일로 만들기 (외부 파일)**
> ```
> hello_html/
> └── index.html.heex   ← 파일로 만든 템플릿
> ```
> `embed_templates "hello_html/*"` 한 줄이 이 폴더 안의 모든 `.heex` 파일을
> 자동으로 함수로 변환해줘요.
>
> **방법 2: `~H"""..."""` 로 파일 안에 직접 쓰기 (인라인 템플릿)**
> ```elixir
> def greet(assigns) do
>   ~H"""
>   <h1>안녕하세요, {@name}님! 👋</h1>
>   """
> end
> ```
> `~H"""..."""` 는 Elixir의 **시질(Sigil)** 이라는 문법이에요.
> `~H`가 붙으면 Phoenix가 "이건 HTML이야!"라고 인식하고 컴파일해줘요.
> `.heex` 파일이 없어도 동작하는 이유가 바로 이것이에요!
>
> | 방법 | 장점 | 추천 상황 |
> |------|------|-----------|
> | `.heex` 파일 | HTML이 길어도 깔끔 | 내용이 많은 페이지 |
> | `~H"""..."""` 인라인 | 파일을 따로 안 만들어도 됨 | 간단한 조각(버튼, 인사 등) |

### ✅ 확인 방법
`http://localhost:4000/greet/철수` 접속해보기

---

## 3단계: LiveView로 실시간 카운터 만들기 ⭐

### 개념
Phoenix **LiveView**는 Phoenix의 가장 강력한 기능이에요!
JavaScript 없이 Elixir 코드만으로 실시간 인터랙티브 UI를 만들 수 있어요.

```
클릭! → 서버에 이벤트 전송 → 서버에서 상태 변경 → 화면 자동 업데이트
```

### 실습: 버튼 클릭 카운터

**`lib/phoenix_hello_web/live/counter_live.ex`** 새 파일 생성:

```elixir
defmodule PhoenixHelloWeb.CounterLive do
  use PhoenixHelloWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, count: 0)}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="text-center py-20">
        <h1 class="text-4xl font-bold mb-8">실시간 카운터</h1>

        <p class="text-8xl font-mono mb-10">{@count}</p>

        <div class="flex gap-4 justify-center">
          <button phx-click="decrement"
                  class="px-6 py-3 bg-red-500 text-white rounded-lg text-xl hover:bg-red-600">
            ➖ 감소
          </button>
          <button phx-click="reset"
                  class="px-6 py-3 bg-gray-500 text-white rounded-lg text-xl hover:bg-gray-600">
            🔄 초기화
          </button>
          <button phx-click="increment"
                  class="px-6 py-3 bg-blue-500 text-white rounded-lg text-xl hover:bg-blue-600">
            ➕ 증가
          </button>
        </div>
      </div>
    </Layouts.app>
    """
  end

  def handle_event("increment", _params, socket) do
    {:noreply, update(socket, :count, &(&1 + 1))}
  end

  def handle_event("decrement", _params, socket) do
    {:noreply, update(socket, :count, &(&1 - 1))}
  end

  def handle_event("reset", _params, socket) do
    {:noreply, assign(socket, count: 0)}
  end
end
```

**router.ex** 에 추가:
```elixir
live "/counter", CounterLive
```

### ✅ 확인 방법
`http://localhost:4000/counter` 접속 → 버튼 클릭해보기

> 💡 페이지 새로고침 없이 숫자가 바뀌는 게 LiveView의 마법이에요!

---

## 4단계: 폼(Form)으로 사용자 입력 받기

### 개념
LiveView 폼을 사용하면 사용자가 입력한 값을 실시간으로 처리할 수 있어요.

### 실습: 간단한 메시지 보드

**`lib/phoenix_hello_web/live/message_live.ex`** 새 파일 생성:

```elixir
defmodule PhoenixHelloWeb.MessageLive do
  use PhoenixHelloWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(messages: [], form: to_form(%{"text" => ""}))
    }
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="max-w-lg mx-auto py-10">
        <h1 class="text-3xl font-bold mb-6">📝 메시지 보드</h1>

        <.form for={@form} id="message-form" phx-submit="add_message" class="flex gap-2 mb-8">
          <.input field={@form[:text]} type="text" placeholder="메시지를 입력하세요..." />
          <button type="submit" class="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600">
            전송
          </button>
        </.form>

        <ul class="space-y-2">
          <%= for {msg, i} <- Enum.with_index(@messages) do %>
            <li class="flex items-center gap-2 p-3 bg-gray-100 rounded-lg">
              <span class="text-gray-400 text-sm">{i + 1}.</span>
              <span>{msg}</span>
            </li>
          <% end %>
        </ul>
      </div>
    </Layouts.app>
    """
  end

  def handle_event("add_message", %{"text" => text}, socket) when text != "" do
    messages = [text | socket.assigns.messages]
    {:noreply,
     socket
     |> assign(messages: messages, form: to_form(%{"text" => ""}))}
  end

  def handle_event("add_message", _params, socket) do
    {:noreply, socket}
  end
end
```

**router.ex** 에 추가:
```elixir
live "/messages", MessageLive
```

### ✅ 확인 방법
`http://localhost:4000/messages` 접속 → 메시지 입력해보기

---

## 5단계: Ecto로 DB 연동 (TODO 앱!) 🏆

### 개념
지금까지는 서버 메모리에만 데이터를 저장했어요. 페이지를 새로고침하면 사라지죠.
**Ecto**는 Elixir에서 데이터베이스(PostgreSQL)와 대화하는 도구예요.

### 실습 순서

#### (1) 스키마(Schema) 자동 생성
터미널에서:
```bash
mix phx.gen.live Todos Todo todos title:string done:boolean
```
이 명령어 하나로 CRUD 기능이 모두 자동 생성돼요! 🎉

#### (2) 마이그레이션 실행
```bash
mix ecto.migrate
```

#### (3) router.ex에 안내된 경로 추가
명령 실행 후 터미널 출력에 나오는 안내를 따라 `router.ex`에 추가하면 완성!

### ✅ 결과
- `http://localhost:4000/todos` 에서 TODO 목록 보기
- TODO 추가 / 수정 / 삭제 / 완료 처리가 DB와 연동!

---

## 🗺️ 전체 학습 지도

```
1단계 (라우터)     →  URL 개념, 새 페이지 추가
2단계 (컨트롤러)   →  URL 파라미터, 데이터 전달
3단계 (LiveView)   →  실시간 UI, 이벤트 처리  ⭐ 핵심
4단계 (폼)         →  사용자 입력, 상태 관리
5단계 (Ecto)       →  DB 저장, CRUD, 실전 앱
```

---

## 📚 추천 다음 자료

| 자료 | 링크 |
|------|------|
| 공식 Phoenix 가이드 | https://hexdocs.pm/phoenix/overview.html |
| LiveView 공식 문서 | https://hexdocs.pm/phoenix_live_view |
| Elixir 언어 공부 | https://elixir-lang.org/getting-started |
| Phoenix 커뮤니티 포럼 | https://elixirforum.com |

---

> 💬 **팁**: 단계를 건너뛰지 말고 순서대로 해보세요.
> 각 단계마다 `mix phx.server`를 실행하고 브라우저에서 직접 확인하는 게 가장 중요합니다!
