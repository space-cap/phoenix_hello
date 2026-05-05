# 🦅 Phoenix Framework란 무엇인가?

> Phoenix를 처음 접하는 초보자를 위한 친절한 설명서입니다!

---

## Phoenix가 뭔가요? 🤔

**Phoenix**는 **Elixir** 언어로 만들어진 **웹 프레임워크**예요.

쉽게 말하면:
> "웹사이트나 웹앱을 만들 때 필요한 도구 모음 상자" 📦

혼자서 웹을 만들려면 URL 처리, HTML 렌더링, DB 연결, 보안 처리 등을 모두 직접 짜야 해요.
Phoenix는 이런 것들을 미리 다 준비해뒀어요. 우리는 "비즈니스 로직"(핵심 기능)만 짜면 돼요.

---

## Elixir는 또 뭔가요? 🤔

Phoenix를 이해하려면 **Elixir** 언어를 알아야 해요.

```
Elixir → Phoenix를 만드는 언어
Phoenix → Elixir로 만든 웹 프레임워크
```

Elixir의 특징:
- **💪 동시 처리에 엄청 강함** — 수백만 명이 동시에 접속해도 안정적
- **🔥 Erlang VM 위에서 실행** — 30년 역사의 통신 시스템용 VM (카카오톡 같은 서비스)
- **🧩 함수형 프로그래밍** — 데이터를 변환하고 흘려보내는 방식
- **😊 Ruby처럼 읽기 쉬운 문법**

---

## Phoenix의 핵심 특징 5가지

### 1. ⚡ 빠른 속도
다른 유명 웹 프레임워크(Rails, Django, Laravel)보다 훨씬 빠릅니다.
밀리초(ms) 단위로 응답해요.

### 2. 🔴 LiveView — 가장 강력한 기능!
JavaScript 없이 실시간 UI를 만들 수 있어요.

```
기존 방식:  브라우저(JS) ↔ API ↔ 서버
LiveView:   브라우저 ↔ WebSocket ↔ 서버(Elixir 코드만!)
```

채팅, 실시간 검색, 라이브 대시보드 등을 Elixir만으로 만들 수 있어요.

### 3. 🗄️ Ecto — DB 연동 도구
PostgreSQL, MySQL 등과 쉽게 연결할 수 있어요.
SQL을 직접 쓰지 않아도 Elixir 코드로 DB를 다룰 수 있어요.

### 4. 🛡️ 기본 보안 내장
- CSRF 공격 방어
- XSS 방어
- SQL Injection 방어
등이 기본으로 설정되어 있어요.

### 5. 🔄 핫 코드 리로딩
코드를 수정하면 서버 재시작 없이 바로 반영돼요!
(`mix phx.server` 실행 중 파일을 저장하면 자동 반영)

---

## 다른 프레임워크와 비교

| | Phoenix | Ruby on Rails | Django (Python) | Express (Node.js) |
|--|---------|--------------|-----------------|-------------------|
| 언어 | Elixir | Ruby | Python | JavaScript |
| 속도 | ⚡⚡⚡⚡⚡ | ⚡⚡⚡ | ⚡⚡⚡ | ⚡⚡⚡⚡ |
| 실시간 | LiveView 내장 ✅ | 추가 설정 필요 | 추가 설정 필요 | Socket.io 필요 |
| 동시 접속 | 매우 강함 | 보통 | 보통 | 강함 |
| 배우기 쉬움 | 보통 | 쉬움 | 쉬움 | 보통 |
| 사용 기업 | Discord, Bleacher Report | GitHub, Shopify | Instagram | Netflix, Uber |

---

## 요청이 처리되는 흐름 (Request Lifecycle)

브라우저에서 `http://localhost:4000/hello` 를 입력하면 어떤 일이 일어날까요?

```
┌──────────────┐
│   브라우저    │  ← 사용자가 URL 입력
└──────┬───────┘
       │ HTTP 요청
       ▼
┌──────────────┐
│   Endpoint   │  ← 요청 수신 (endpoint.ex)
│              │  ← 보안 검사, 로깅 등 처리
└──────┬───────┘
       │
       ▼
┌──────────────┐
│    Router    │  ← URL 패턴 매칭 (router.ex)
│              │  ← "/hello" → HelloController로 보냄
└──────┬───────┘
       │
       ▼
┌──────────────┐
│  Controller  │  ← 비즈니스 로직 처리 (hello_controller.ex)
│              │  ← DB 조회, 데이터 준비
└──────┬───────┘
       │
       ▼
┌──────────────┐
│  View/Template│ ← HTML 생성 (.html.heex 파일)
│              │  ← 데이터를 HTML에 끼워 넣기
└──────┬───────┘
       │ HTTP 응답 (HTML)
       ▼
┌──────────────┐
│   브라우저    │  ← 화면에 표시!
└──────────────┘
```

---

## LiveView의 흐름 (실시간 업데이트)

LiveView는 일반 요청과 다르게 **WebSocket**을 사용해요.

```
┌──────────────┐
│   브라우저    │
│  (LiveView)  │ ← 처음엔 일반 HTTP로 HTML 렌더링
└──────┬───────┘
       │ WebSocket 연결 (지속 연결!)
       ▼
┌──────────────┐
│  LiveView    │ ← 서버에서 상태(state) 관리
│   Process    │ ← 클릭/입력 이벤트 수신
│              │ ← 변경된 부분만 브라우저로 전송
└──────────────┘

버튼 클릭 → 서버 이벤트 처리 → 변경된 HTML 조각만 전송 → 화면 업데이트!
```

---

## Phoenix 프로젝트 생성 방법

```bash
# 1. Phoenix 설치 (처음 한 번만)
mix archive.install hex phx_new

# 2. 새 프로젝트 생성
mix phx.new my_app

# 3. 프로젝트 폴더로 이동
cd my_app

# 4. DB 생성
mix ecto.create

# 5. 개발 서버 실행
mix phx.server
```

---

## 자주 쓰는 Mix 명령어 모음

| 명령어 | 설명 |
|--------|------|
| `mix phx.server` | 개발 서버 시작 (http://localhost:4000) |
| `mix ecto.create` | DB 생성 |
| `mix ecto.migrate` | DB 마이그레이션 실행 |
| `mix ecto.rollback` | 마이그레이션 되돌리기 |
| `mix test` | 테스트 실행 |
| `mix deps.get` | 의존성 패키지 설치 |
| `iex -S mix` | 대화형 Elixir 셸 실행 |
| `mix phx.gen.live` | LiveView CRUD 자동 생성 |

---

## 📌 핵심 요약

```
Phoenix = Elixir로 만든 웹 프레임워크
       = 빠르고 + 실시간(LiveView) + 안정적
       = 현대적인 웹앱에 최적화

배움의 순서:
Elixir 기초 → Phoenix 라우터 → 컨트롤러/뷰 → LiveView → Ecto(DB)
```

> 💬 Phoenix를 배우는 가장 좋은 방법은 **직접 코드를 써보는 것**이에요.
> 에러가 나도 괜찮아요! Phoenix의 에러 메시지는 매우 친절하답니다. 😊
