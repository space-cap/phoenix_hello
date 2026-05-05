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

일반 컨트롤러 방식과 LiveView 방식의 차이:

| | 일반 Controller | LiveView |
|--|----------------|----------|
| 동작 방식 | 요청할 때마다 HTML 새로 생성 | WebSocket으로 지속 연결, 변경된 부분만 전송 |
| 실시간 | ❌ (새로고침 필요) | ✅ (자동 업데이트) |
| JavaScript 필요 | 직접 써야 함 | 거의 불필요 |
| 파일 위치 | `controllers/` | `live/` |

---

### ❓ Q1: 왜 `live/` 폴더에 만들어야 하나요? `run/` 폴더로 해도 되나요?

**짧은 답: 꼭 `live/`일 필요는 없어요. 하지만 강력하게 권장해요.**

Phoenix는 파일 위치를 강제하지 않아요. 기술적으로는 어느 폴더에 만들어도 동작해요.
그런데 Phoenix 커뮤니티 전체가 LiveView 파일은 `live/` 폴더에 두는 것을 **관례(Convention)**로 정해뒀어요.

```
lib/phoenix_hello_web/
├── controllers/    ← 일반 HTTP 요청 처리 (Controller)
├── live/           ← LiveView 실시간 페이지  ← ✅ 여기!
└── components/     ← 재사용 UI 컴포넌트
```

마치 한국에서 차는 우측통행이에요. 좌측으로 달려도 물리적으로는 가능하지만,
모두가 규칙을 지켜야 혼란이 없겠죠? 이와 같은 이유예요.

> 💡 **관례를 따르면**: 다른 개발자가 코드를 봤을 때 "아, `live/`에 있으니 LiveView겠구나!" 바로 알 수 있어요.

---

### ❓ Q2: 파일을 만들면 자동으로 `CounterLive`가 생성되나요?

**아니요! 파일 이름과 모듈 이름은 별개예요. 단, 규칙을 따르면 헷갈리지 않아요.**

```
파일 이름:   counter_live.ex       ← snake_case (소문자 + 언더스코어)
모듈 이름:   CounterLive           ← PascalCase (각 단어 첫 글자 대문자)
```

Phoenix가 자동으로 파일을 읽어서 모듈을 만들지는 않아요.
`defmodule PhoenixHelloWeb.CounterLive do ... end` 코드를 **우리가 직접 파일 안에 작성**해야 해요.
파일 이름과 모듈 이름을 맞추는 건 **Elixir의 강력한 관례**예요.

> ⚠️ 파일 이름이 `counter_live.ex`인데 안에 `defmodule PhoenixHelloWeb.FooBar`라고 쓰면?
> 오류는 안 나지만 다른 사람이 파일을 찾을 때 엄청 혼란스러워요. 항상 맞춰 쓰세요!

---

### 실습: 버튼 클릭 카운터

**`lib/phoenix_hello_web/live/counter_live.ex`** 새 파일 생성:

```elixir
defmodule PhoenixHelloWeb.CounterLive do  # ← (1) 모듈 선언
  use PhoenixHelloWeb, :live_view         # ← (2) LiveView 기능 불러오기

  def mount(_params, _session, socket) do # ← (3) 초기 설정
    {:ok, assign(socket, count: 0)}
  end

  def render(assigns) do                  # ← (4) 화면 그리기
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

  def handle_event("increment", _params, socket) do  # ← (5) 이벤트 처리
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

---

### 📖 코드 한 줄 한 줄 설명

#### (1) `defmodule PhoenixHelloWeb.CounterLive do`
Elixir에서 코드 묶음(모듈)을 선언해요.
`PhoenixHelloWeb.CounterLive`는 "PhoenixHelloWeb 앱 안의 CounterLive 모듈"이라는 뜻이에요.

```
PhoenixHelloWeb  ← 우리 앱의 웹 모듈 (네임스페이스)
CounterLive      ← 이 파일의 고유 이름
```

#### (2) `use PhoenixHelloWeb, :live_view`
"LiveView에 필요한 모든 기능을 여기서 사용할게요!"라고 선언하는 줄이에요.

이 한 줄이 없으면 `mount`, `render`, `handle_event` 같은 LiveView 기능을 전혀 쓸 수 없어요.
마치 공구함을 열지 않으면 드라이버를 꺼낼 수 없는 것처럼요.

```
use PhoenixHelloWeb, :live_view
                    ↑
        이 옵션이 "나는 LiveView야"라고 알려줘요.
        :html 이면 일반 뷰, :live_view 이면 LiveView
```

#### (3) `def mount(_params, _session, socket) do`
**"페이지가 처음 열릴 때 딱 한 번 실행"** 되는 함수예요. 초기화 역할이에요.

```elixir
def mount(_params, _session, socket) do
#          ↑         ↑        ↑
#       URL 파라미터  세션 정보  현재 연결 상태 (제일 중요!)
#       (_로 시작 = 지금은 사용 안 함, 무시)

  {:ok, assign(socket, count: 0)}
#  ↑          ↑              ↑
# "성공!"    socket에 데이터 추가  count를 0으로 초기화
end
```

`socket`은 LiveView의 핵심이에요. 서버와 브라우저 사이의 "연결 상태 + 데이터 보관함"이에요.
`assign(socket, count: 0)` → socket에 `count = 0` 데이터를 저장해요.

#### (4) `def render(assigns)` + `{@count}`
화면에 보여줄 HTML을 반환하는 함수예요.

```elixir
<p class="text-8xl">{@count}</p>
#                    ↑
#         socket에 저장된 count 값을 여기 출력!
#         assign(socket, count: 0) 으로 저장한 바로 그 값
```

`@count`는 "socket에 저장된 count 값을 가져와서 보여줘"라는 뜻이에요.

```
assign(socket, count: 0)  → 저장
{@count}                  → 꺼내서 화면에 표시
```

#### (5) `phx-click="increment"` + `handle_event`
버튼의 `phx-click="increment"`는 "이 버튼을 클릭하면 서버의 `handle_event("increment", ...)`를 호출해!"라는 뜻이에요.

```
버튼 클릭
    ↓
phx-click="increment"  →  WebSocket으로 "increment" 이벤트 전송
    ↓
handle_event("increment", _params, socket)  ←  서버에서 수신
    ↓
update(socket, :count, &(&1 + 1))  →  count 값을 1 증가
    ↓
변경된 부분만 브라우저로 전송 → 화면 자동 업데이트!
```

`update(socket, :count, &(&1 + 1))`는 조금 어려워 보이는데,
"socket 안의 count 값을 현재 값(`&1`) + 1 로 바꿔줘"라는 뜻이에요.

**router.ex** 에 추가:
```elixir
live "/counter", CounterLive
# ↑               ↑
# live 라우트 선언  연결할 LiveView 모듈
# (get 대신 live 를 써요!)
```

### ✅ 확인 방법
`http://localhost:4000/counter` 접속 → 버튼 클릭해보기

> 💡 페이지 새로고침 없이 숫자가 바뀌는 게 LiveView의 마법이에요!
> 개발자 도구(F12)의 Network 탭을 보면 HTTP 요청이 아닌 **WebSocket** 통신을 볼 수 있어요.

---

### 🌐 심화: 다른 브라우저에서도 실시간 반영하기 (PubSub)

#### 현재 상태의 문제

지금 카운터는 **각 브라우저(탭)마다 독립된 상태**를 가져요.
크롬에서 +1을 눌러도 엣지 브라우저에서는 숫자가 안 바뀌죠.

```
크롬 탭    → 자기만의 count = 5
엣지 탭    → 자기만의 count = 0  (따로 놀아요!)
```

#### Phoenix PubSub이란?

**PubSub** = **Pub**lish(발행) + **Sub**scribe(구독)

라디오 방송국처럼 생각하면 쉬워요:
- **방송국(Publish)**: "숫자가 바뀌었어요!" 라고 전파를 쏨
- **청취자(Subscribe)**: 연결된 모든 브라우저가 방송을 듣고 화면 업데이트

```
크롬에서 버튼 클릭
       ↓
서버에서 count 변경
       ↓
PubSub으로 "count_updated" 이벤트 전파 (방송!)
       ↓
┌──────────┐  ┌──────────┐  ┌──────────┐
│  크롬 탭  │  │  엣지 탭  │  │  파폭 탭  │
│  count:5 │  │  count:5 │  │  count:5 │  ← 모두 동시 업데이트!
└──────────┘  └──────────┘  └──────────┘
```

#### 코드 수정 방법

**`lib/phoenix_hello_web/live/counter_live.ex`** 를 다음과 같이 수정하세요:

```elixir
defmodule PhoenixHelloWeb.CounterLive do
  use PhoenixHelloWeb, :live_view

  # PubSub 토픽 이름 (방송 채널 이름 같은 것)
  @topic "counter:global"

  def mount(_params, _session, socket) do
    # 이 LiveView가 시작될 때 "counter:global" 채널을 구독(청취 시작)
    if connected?(socket) do
      Phoenix.PubSub.subscribe(PhoenixHello.PubSub, @topic)
    end

    {:ok, assign(socket, count: 0)}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="text-center py-20">
        <h1 class="text-4xl font-bold mb-8">실시간 카운터 (전체 공유)</h1>

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

  # 버튼 클릭 시 → 새 count 계산 → 전체 채널에 방송!
  def handle_event("increment", _params, socket) do
    new_count = socket.assigns.count + 1
    Phoenix.PubSub.broadcast(PhoenixHello.PubSub, @topic, {:count_updated, new_count})
    {:noreply, assign(socket, count: new_count)}
  end

  def handle_event("decrement", _params, socket) do
    new_count = socket.assigns.count - 1
    Phoenix.PubSub.broadcast(PhoenixHello.PubSub, @topic, {:count_updated, new_count})
    {:noreply, assign(socket, count: new_count)}
  end

  def handle_event("reset", _params, socket) do
    Phoenix.PubSub.broadcast(PhoenixHello.PubSub, @topic, {:count_updated, 0})
    {:noreply, assign(socket, count: 0)}
  end

  # 다른 브라우저에서 방송(broadcast)이 오면 이 함수가 실행됨!
  def handle_info({:count_updated, new_count}, socket) do
    {:noreply, assign(socket, count: new_count)}
  end
end
```

#### 코드 핵심 포인트 3가지

**① 구독 (Subscribe) — 방송 채널 청취 시작**
```elixir
if connected?(socket) do
  Phoenix.PubSub.subscribe(PhoenixHello.PubSub, @topic)
end
# connected?(socket) → WebSocket이 실제로 연결됐을 때만 구독해요.
# (처음 HTTP로 HTML 받을 때는 구독 안 함, WebSocket 연결 후에 구독)
```

**② 방송 (Broadcast) — 이벤트를 채널 전체에 전파**
```elixir
Phoenix.PubSub.broadcast(PhoenixHello.PubSub, @topic, {:count_updated, new_count})
#                         ↑                    ↑         ↑
#                    PubSub 서버           채널 이름    전달할 데이터
```

**③ 수신 (handle_info) — 방송을 받았을 때 처리**
```elixir
def handle_info({:count_updated, new_count}, socket) do
  {:noreply, assign(socket, count: new_count)}
end
# handle_event 는 클릭 등 브라우저 이벤트
# handle_info  는 서버 내부 메시지 수신 (PubSub 방송 등)
```

#### ✅ 확인 방법
1. `http://localhost:4000/counter` 를 **크롬**에서 열기
2. 같은 URL을 **엣지** 또는 **다른 탭**에서도 열기
3. 크롬에서 버튼 클릭 → 엣지 화면도 **동시에 바뀌는 것** 확인!

> 🎉 이게 바로 Phoenix가 채팅앱, 실시간 대시보드, 협업 툴 만들기에 강한 이유예요!
> Discord 같은 서비스도 이 방식으로 실시간 업데이트를 구현해요.

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
