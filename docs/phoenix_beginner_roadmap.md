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

### 🔧 심화2: 새 브라우저가 접속해도 현재 값 유지하기 (Agent)

#### 문제 발견! 🤔

PubSub을 적용했지만, 한 가지 문제가 남아있어요.
크롬에서 카운터를 5로 올린 뒤, **새 브라우저(엣지)로 처음 접속**하면 숫자가 0으로 시작해요.

```
크롬:  count = 5  (버튼 클릭해서 올림)
엣지:  count = 0  (새로 접속 → 처음부터 시작 😢)
```

**왜 이런 일이 생기나요?**
현재 코드의 `mount`를 보면:
```elixir
{:ok, assign(socket, count: 0)}  # 항상 0으로 시작!
```
새 브라우저가 접속할 때마다 무조건 0으로 초기화하기 때문이에요.

PubSub은 "방송을 실시간으로 전달"하지만, **방송 이전에 접속한 사람은 이전 값을 알 수 없어요.**
마치 라디오 방송을 중간부터 켰을 때, 앞에서 무슨 말을 했는지 모르는 것처럼요.

#### 해결책: Agent로 현재 값 기억시키기

**Agent**는 서버 메모리에 값을 계속 보관해두는 "메모장"이에요.

```
Agent (서버 메모장)
├── 크롬에서 +1 누름 → 5 저장
├── 엣지 새로 접속 → "현재 값이 뭐야?" → 5 응답
└── 파폭에서 접속 → "현재 값이 뭐야?" → 5 응답
```

#### 새 파일: `lib/phoenix_hello/counter_agent.ex`

```elixir
defmodule PhoenixHello.CounterAgent do
  use Agent

  def start_link(_opts) do
    # 서버 시작 시 0으로 초기화된 Agent 프로세스를 시작
    Agent.start_link(fn -> 0 end, name: __MODULE__)
  end

  # 현재 값 읽기
  def get do
    Agent.get(__MODULE__, & &1)
  end

  # 새 값 저장
  def set(value) do
    Agent.update(__MODULE__, fn _ -> value end)
  end
end
```

#### `lib/phoenix_hello/application.ex` 수정

Agent를 앱 시작 시 자동으로 켜지도록 등록해요:

```elixir
children = [
  PhoenixHello.Repo,
  {Phoenix.PubSub, name: PhoenixHello.PubSub},
  PhoenixHello.CounterAgent,   # ← 이 줄 추가!
  PhoenixHelloWeb.Endpoint
]
```

#### `counter_live.ex` 수정

**mount**: 접속 시 Agent에서 현재 값 읽기
```elixir
def mount(_params, _session, socket) do
  if connected?(socket) do
    Phoenix.PubSub.subscribe(PhoenixHello.PubSub, @topic)
  end

  # 0 대신 → Agent에서 현재 공유 값을 읽어옴!
  current_count = PhoenixHello.CounterAgent.get()
  {:ok, assign(socket, count: current_count)}
end
```

**handle_event**: 값 변경 시 Agent에도 저장
```elixir
def handle_event("increment", _params, socket) do
  new_count = socket.assigns.count + 1
  PhoenixHello.CounterAgent.set(new_count)  # ← Agent에 저장!
  Phoenix.PubSub.broadcast(PhoenixHello.PubSub, @topic, {:count_updated, new_count})
  {:noreply, assign(socket, count: new_count)}
end
```

#### 전체 흐름 (완성판)

```
[처음 접속]
새 브라우저 접속
    ↓
mount() 실행
    ↓
CounterAgent.get() → 현재 값(예: 5) 읽기
    ↓
화면에 5 표시 ✅

[버튼 클릭]
+1 클릭
    ↓
new_count = 6
    ↓
CounterAgent.set(6)    → Agent 메모장에 6 저장
PubSub.broadcast(...)  → 모든 브라우저에 6 전파
    ↓
모든 브라우저 화면이 6으로 업데이트 ✅
```

> ⚠️ **주의**: Agent는 서버 메모리에 저장해요. 서버를 재시작하면 값이 0으로 초기화돼요.
> 재시작 후에도 값을 유지하려면 **5단계의 Ecto(DB)**를 사용해야 해요!

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

지금까지 배운 것들의 문제점:
- **3단계 카운터(Agent)**: 서버 재시작하면 값이 사라짐
- **4단계 메시지 보드**: 서버 재시작하면 메시지가 모두 사라짐

**Ecto**는 Elixir에서 **데이터베이스(PostgreSQL)와 대화**하는 도구예요.
DB에 저장하면 서버를 재시작해도 데이터가 남아있어요!

```
Agent (메모리)  →  서버 재시작하면 사라짐 💨
DB (PostgreSQL) →  영구 저장! 서버 재시작해도 남아있음 💾
```

---

### ❓ 이 명령어가 뭘 하는 건가요?

```bash
mix phx.gen.live Todos Todo todos title:string done:boolean
```

이 명령어를 **단어 하나하나 분해**해서 살펴볼게요:

| 부분 | 의미 |
|------|------|
| `mix` | Elixir의 빌드/작업 도구 (Node의 npm과 비슷) |
| `phx.gen.live` | "Phoenix의 LiveView CRUD 코드를 자동 생성해줘" |
| `Todos` | **컨텍스트(Context)** 이름 — 관련 기능을 묶는 폴더 이름 |
| `Todo` | **스키마(Schema)** 이름 — DB 테이블 1개를 나타내는 Elixir 구조체 |
| `todos` | **테이블 이름** — PostgreSQL DB에 실제로 생성될 테이블 이름 |
| `title:string` | `title` 컬럼, 타입은 문자열(VARCHAR) |
| `done:boolean` | `done` 컬럼, 타입은 참/거짓(BOOLEAN) |

> 💡 **컨텍스트(Context)란?**
> 관련 기능을 한 폴더에 묶어두는 개념이에요.
> 쇼핑몰이라면 `Accounts`(회원), `Products`(상품), `Orders`(주문) 같은 단위로 분리해요.
> `Todos`는 "할 일 관련 기능 모음"이 되는 거예요.

> 💡 **스키마(Schema) vs 테이블?**
>
> | | 스키마(Todo) | 테이블(todos) |
> |--|-------------|---------------|
> | 위치 | Elixir 코드 안 | PostgreSQL DB 안 |
> | 역할 | DB 데이터를 Elixir 구조체로 표현 | 실제 데이터가 저장되는 곳 |
> | 관계 | 테이블을 코드로 표현한 것 | 스키마가 참조하는 실제 저장소 |

---

### 생성된 파일 전체 목록

이 명령어 한 번으로 **총 8개 파일**이 자동 생성됐어요!

```
phoenix_hello/
├── lib/
│   ├── phoenix_hello/
│   │   ├── todos.ex                    ← ① 컨텍스트 (DB 쿼리 함수 모음)
│   │   └── todos/
│   │       └── todo.ex                 ← ② 스키마 (테이블 구조 정의)
│   └── phoenix_hello_web/
│       └── live/
│           └── todo_live/
│               ├── index.ex            ← ③ 목록 페이지 LiveView
│               ├── show.ex             ← ④ 상세 페이지 LiveView
│               └── form.ex             ← ⑤ 생성/수정 폼 LiveView
├── priv/
│   └── repo/
│       └── migrations/
│           └── 20260505081141_create_todos.exs  ← ⑥ DB 마이그레이션
└── test/                               ← ⑦⑧ 테스트 파일들
```

---

### 각 파일 상세 설명

#### ① `lib/phoenix_hello/todos.ex` — 컨텍스트

```elixir
defmodule PhoenixHello.Todos do
  def list_todos do       # 전체 목록 조회
    Repo.all(Todo)
  end

  def get_todo!(id) do   # ID로 특정 항목 조회 (없으면 에러)
    Repo.get!(Todo, id)
  end

  def create_todo(attrs) do  # 새 TODO 생성
    %Todo{}
    |> Todo.changeset(attrs)
    |> Repo.insert()
  end

  def update_todo(todo, attrs) do  # TODO 수정
    todo
    |> Todo.changeset(attrs)
    |> Repo.update()
  end

  def delete_todo(todo) do   # TODO 삭제
    Repo.delete(todo)
  end
end
```

이 파일이 **DB와의 실제 대화**를 담당해요.
LiveView 파일들이 직접 DB에 접근하지 않고, 무조건 이 파일을 통해 접근해요.

```
LiveView → Todos 컨텍스트 → Ecto (Repo) → PostgreSQL DB
```

#### ② `lib/phoenix_hello/todos/todo.ex` — 스키마

```elixir
defmodule PhoenixHello.Todos.Todo do
  use Ecto.Schema

  schema "todos" do        # "todos" 테이블과 연결
    field :title, :string  # title 컬럼 (문자열)
    field :done, :boolean, default: false  # done 컬럼 (기본값: false)

    timestamps()           # inserted_at, updated_at 컬럼 자동 추가
  end

  def changeset(todo, attrs) do   # 유효성 검사
    todo
    |> cast(attrs, [:title, :done])         # title, done 필드 허용
    |> validate_required([:title, :done])   # title, done 필수!
  end
end
```

스키마는 **DB 테이블의 Elixir 버전**이에요.
`changeset`은 데이터를 저장하기 전에 유효성을 검사해요 (예: title이 비어있으면 저장 거부).

#### ③④⑤ `lib/phoenix_hello_web/live/todo_live/` — LiveView 3총사

| 파일 | URL | 하는 일 |
|------|-----|---------|
| `index.ex` | `/todos` | TODO 전체 목록 표시 + 삭제 |
| `show.ex` | `/todos/:id` | TODO 하나의 상세 정보 |
| `form.ex` | `/todos/new`, `/todos/:id/edit` | 생성 폼 & 수정 폼 |

#### ⑥ `priv/repo/migrations/20260505081141_create_todos.exs` — 마이그레이션

```elixir
defmodule PhoenixHello.Repo.Migrations.CreateTodos do
  use Ecto.Migration

  def change do
    create table(:todos) do   # "todos" 테이블 생성
      add :title, :string     # title 컬럼 추가
      add :done, :boolean, default: false, null: false  # done 컬럼 추가

      timestamps()            # inserted_at, updated_at 컬럼 자동 추가
    end
  end
end
```

이 파일은 **"DB에 todos 테이블을 만들어라"는 명령서**예요.
파일명 앞의 숫자(`20260505081141`)는 **생성 시각**이에요. 순서를 보장하기 위해 씁니다.

> 💡 마이그레이션 파일은 **절대 직접 수정하거나 삭제하지 마세요!**
> DB 변경 이력이 담겨 있어서, 팀원들이 같은 DB 구조를 유지할 수 있어요.

---

### 실습 순서

#### (1) 명령어 실행 (이미 완료!)

```bash
mix phx.gen.live Todos Todo todos title:string done:boolean
```

#### (2) 마이그레이션 실행 — DB에 테이블 실제 생성

```bash
mix ecto.migrate
```

이 명령을 실행하면:
```
PostgreSQL DB에 다음이 생성됨:

CREATE TABLE todos (
    id BIGSERIAL PRIMARY KEY,      ← ID (자동 증가)
    title VARCHAR,                 ← 제목
    done BOOLEAN DEFAULT false,    ← 완료 여부
    inserted_at TIMESTAMP,         ← 생성 시각
    updated_at TIMESTAMP           ← 수정 시각
);
```

#### (3) router.ex에 경로 추가

명령어 실행 시 터미널에서 이런 안내가 출력돼요:
```
Add the live routes to your browser scope in lib/phoenix_hello_web/router.ex:

    live "/todos", TodoLive.Index, :index
    live "/todos/new", TodoLive.Form, :new
    live "/todos/:id", TodoLive.Show, :show
    live "/todos/:id/edit", TodoLive.Form, :edit
```

이미 `router.ex`에 추가되어 있을 거예요. 없으면 추가하세요!

---

### ✅ 결과 — 완성된 CRUD 기능

| URL | 기능 |
|-----|------|
| `/todos` | TODO 전체 목록 보기 + 삭제 버튼 |
| `/todos/new` | 새 TODO 만들기 (폼) |
| `/todos/:id` | TODO 상세 보기 |
| `/todos/:id/edit` | TODO 수정하기 (폼) |

> 🎉 명령어 단 한 줄이 이 모든 기능을 만들어줬어요!
> 물론 실제 프로젝트에서는 자동 생성 코드를 이해하고 수정하는 능력이 필요해요.



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
