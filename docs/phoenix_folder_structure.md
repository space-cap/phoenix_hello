# 📁 Phoenix 프로젝트 폴더 구조 완전 해설

> `phoenix_hello` 프로젝트의 모든 폴더와 파일을 친절하게 설명합니다!

---

## 전체 구조 한눈에 보기

```
phoenix_hello/                  ← 프로젝트 루트 (최상위 폴더)
├── 📁 _build/                  ← 컴파일 결과물 (자동 생성, 건드리지 마세요)
├── 📁 assets/                  ← CSS, JavaScript 소스
├── 📁 config/                  ← 환경별 설정 파일
├── 📁 deps/                    ← 외부 라이브러리 (자동 생성, 건드리지 마세요)
├── 📁 docs/                    ← 우리가 만든 문서 폴더 📝
├── 📁 lib/                     ← 핵심 애플리케이션 코드 ⭐
├── 📁 priv/                    ← DB 마이그레이션, 정적 파일
├── 📁 test/                    ← 테스트 코드
├── 📄 mix.exs                  ← 프로젝트 설정 파일 (package.json 같은 것)
├── 📄 mix.lock                 ← 의존성 버전 고정 파일 (자동 생성)
├── 📄 .gitignore               ← Git에서 무시할 파일 목록
└── 📄 README.md                ← 프로젝트 소개문서
```

---

## 📁 `lib/` — 핵심 코드 폴더 ⭐ 가장 중요!

우리가 실제로 코드를 작성하는 곳이에요. 두 개의 하위 폴더로 나뉘어요.

```
lib/
├── 📄 phoenix_hello.ex         ← 앱 시작점 (거의 건드릴 일 없음)
├── 📄 phoenix_hello_web.ex     ← 웹 모듈 설정 (건드릴 일 드묾)
├── 📁 phoenix_hello/           ← 비즈니스 로직 (핵심 데이터 처리)
│   ├── application.ex          ← 앱 프로세스 시작 설정
│   ├── mailer.ex               ← 이메일 발송 설정
│   └── repo.ex                 ← DB 연결 설정
└── 📁 phoenix_hello_web/       ← 웹(HTTP) 관련 코드 ⭐
    ├── endpoint.ex             ← HTTP 서버 진입점
    ├── router.ex               ← URL 라우팅 ⭐ 자주 수정!
    ├── gettext.ex              ← 다국어 지원 설정
    ├── telemetry.ex            ← 성능 측정 설정
    ├── 📁 components/          ← 재사용 UI 컴포넌트
    │   ├── core_components.ex  ← 버튼, 폼, 테이블 등 기본 컴포넌트
    │   └── layouts.ex          ← 레이아웃(헤더/푸터 포함 전체 틀)
    └── 📁 controllers/         ← 컨트롤러 & 뷰 & 템플릿 ⭐ 자주 수정!
        ├── hello_controller.ex ← HelloController
        ├── hello_html.ex       ← HelloHTML (뷰)
        └── 📁 hello_html/
            └── index.html.heex ← 실제 HTML 템플릿
```

### `lib/phoenix_hello/` vs `lib/phoenix_hello_web/` 차이

| 폴더 | 역할 | 비유 |
|------|------|------|
| `phoenix_hello/` | 비즈니스 로직, DB 쿼리 | 주방 (요리 담당) |
| `phoenix_hello_web/` | HTTP 처리, HTML 렌더링 | 홀 (서빙 담당) |

> 예) 쇼핑몰이라면:
> - `phoenix_hello/` → 상품 조회, 재고 계산, 결제 처리
> - `phoenix_hello_web/` → 상품 목록 페이지 표시, 버튼 클릭 처리

---

## 📁 `config/` — 환경별 설정 폴더

```
config/
├── 📄 config.exs           ← 모든 환경에 공통으로 적용되는 설정
├── 📄 dev.exs              ← 개발 환경 설정 (mix phx.server 실행 시)
├── 📄 test.exs             ← 테스트 환경 설정 (mix test 실행 시)
├── 📄 prod.exs             ← 프로덕션(배포) 환경 기본 설정
├── 📄 runtime.exs          ← 실행 시간에 동적으로 읽는 설정 (환경변수 처리)
└── 📄 dev.secret.exs       ← 🔒 로컬 비밀정보 (GitHub에 올라가지 않음!)
```

### 각 설정 파일이 언제 읽히나요?

```
mix phx.server  →  config.exs + dev.exs (+ dev.secret.exs)
mix test        →  config.exs + test.exs
배포 서버        →  config.exs + prod.exs + runtime.exs
```

### ⚠️ 주의사항
| 파일 | GitHub 업로드 | 이유 |
|------|-------------|------|
| `config.exs` | ✅ 올라감 | 민감정보 없음 |
| `dev.exs` | ✅ 올라감 | 기본값만 있어야 함 |
| `test.exs` | ✅ 올라감 | 민감정보 없음 |
| `prod.exs` | ✅ 올라감 | 민감정보 없음 |
| `runtime.exs` | ✅ 올라감 | 환경변수로 처리 |
| `dev.secret.exs` | ❌ 안 올라감 | 실제 비밀번호 있음! |

---

## 📁 `assets/` — CSS & JavaScript 소스 폴더

```
assets/
├── 📁 css/
│   └── app.css         ← 전체 스타일시트 (Tailwind CSS 설정 포함)
├── 📁 js/
│   ├── app.js          ← 메인 JavaScript (LiveView 설정 포함)
│   └── hooks/          ← LiveView JS 훅 파일들
└── 📁 vendor/          ← 외부 JS 라이브러리
```

> 💡 `assets/` 안의 파일들은 빌드 도구(esbuild, Tailwind)가 자동으로 처리해서
> `priv/static/assets/` 폴더에 최종 파일을 생성해요. 직접 `priv/static`을 수정하면 안 돼요!

---

## 📁 `priv/` — 앱이 사용하는 정적 리소스

```
priv/
├── 📁 repo/
│   └── migrations/     ← DB 테이블 변경 내역 파일들 ⭐
├── 📁 gettext/         ← 다국어 번역 파일
└── 📁 static/          ← 빌드된 CSS/JS, 이미지 등 (자동 생성)
    ├── assets/         ← esbuild/Tailwind가 만들어 낸 파일 (자동)
    ├── favicon.ico
    └── robots.txt
```

### `priv/repo/migrations/` 이 중요한 이유!
DB 테이블을 만들거나 변경할 때마다 마이그레이션 파일이 생성돼요.

```bash
mix ecto.gen.migration create_users  # → 파일 자동 생성
mix ecto.migrate                     # → 파일을 DB에 실제 적용
```

이 파일들은 **반드시 GitHub에 올려야** 해요. 다른 팀원이나 서버에서도 같은 DB 구조를 만들 수 있어야 하니까요!

---

## 📁 `test/` — 테스트 코드 폴더

```
test/
├── 📁 phoenix_hello_web/   ← 웹(HTTP/LiveView) 테스트
│   ├── controllers/        ← 컨트롤러 테스트
│   └── live/               ← LiveView 테스트
├── 📁 support/             ← 테스트 도우미 함수들
└── 📄 test_helper.exs      ← 테스트 전역 설정
```

```bash
mix test              # 전체 테스트 실행
mix test test/phoenix_hello_web/  # 특정 폴더만 테스트
```

---

## 📁 `deps/` — 외부 라이브러리 폴더 (건드리지 마세요!)

```
deps/
├── phoenix/           ← Phoenix 프레임워크 소스
├── ecto/              ← Ecto DB 라이브러리
├── tailwind/          ← Tailwind CSS
└── ...                ← 기타 수십 개의 라이브러리
```

> ⚠️ 이 폴더는 `mix deps.get` 명령으로 자동 생성돼요.
> 직접 수정하면 안 되고, GitHub에도 올리지 않아요. (`.gitignore`에 등록됨)

---

## 📁 `_build/` — 컴파일 결과물 폴더 (건드리지 마세요!)

코드를 컴파일하면 `.beam` 파일들이 여기 쌓여요.
> ⚠️ 직접 수정 절대 금지! GitHub에도 올리지 않아요.

---

## 📄 주요 루트 파일들

### `mix.exs` — 프로젝트 설정 파일
Node.js의 `package.json`과 같은 역할이에요.

```elixir
# 이런 정보들이 담겨 있어요:
def project do
  [
    app: :phoenix_hello,      # 앱 이름
    version: "0.1.0",         # 버전
    elixir: "~> 1.14",        # 필요한 Elixir 버전
    ...
  ]
end

defp deps do
  [
    {:phoenix, "~> 1.8.0"},   # 사용하는 외부 라이브러리 목록
    {:ecto_sql, "~> 3.10"},
    ...
  ]
end
```

### `mix.lock` — 의존성 버전 고정 파일
`package-lock.json`과 같아요. 팀원 모두가 같은 버전의 라이브러리를 쓰도록 보장해요.
> ✅ GitHub에 꼭 올려야 해요!

### `.gitignore` — Git 무시 목록
GitHub에 올리면 안 되는 파일들을 지정해요.

---

## 🗂️ 폴더별 수정 빈도 요약

| 폴더/파일 | 수정 빈도 | 설명 |
|-----------|----------|------|
| `lib/phoenix_hello_web/controllers/` | ⭐⭐⭐⭐⭐ | 가장 자주 수정! |
| `lib/phoenix_hello_web/router.ex` | ⭐⭐⭐⭐ | 페이지 추가할 때마다 |
| `lib/phoenix_hello_web/live/` | ⭐⭐⭐⭐ | LiveView 파일들 |
| `lib/phoenix_hello/` | ⭐⭐⭐ | DB 쿼리, 비즈니스 로직 |
| `priv/repo/migrations/` | ⭐⭐⭐ | DB 변경할 때마다 |
| `assets/css/app.css` | ⭐⭐ | 스타일 수정 |
| `config/` | ⭐⭐ | 설정 변경 시 |
| `deps/`, `_build/` | ❌ | 절대 직접 수정 금지! |

---

> 💬 처음에는 `router.ex`와 `controllers/` 폴더만 집중하면 돼요.
> 나머지는 개발하면서 자연스럽게 익히게 됩니다! 😊
