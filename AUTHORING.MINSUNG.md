# AUTHORING.MINSUNG.md
# 최민성의 Claude Code 활용 패턴

버전: v1.0.0

---

## 1. 이 파일의 목적

이 프로젝트에서 Claude Code (AI Agent)를 활용한 방식과 노하우를 정리한다.
다음 프로젝트에서 동일한 실수를 반복하지 않고, 잘 통한 패턴을 재사용하기 위함이다.

---

## 2. 단계별 프롬프트 흐름

### Step 1 — 기획

```
나는 [주제]를 만들고 싶다.
1) 비전과 목표를 .planning/00-vision.md에 작성
2) 핵심 사용자 시나리오 3개를 .planning/01-requirements.md에 작성
3) 기능을 MoSCoW로 분류
4) 모호한 부분은 선택형 질문으로 물어본 후 작성
```

### Step 2 — WBS·일정

```
.planning/00-vision.md 와 01-requirements.md 를 읽고
1) WBS를 3단계 깊이로 .planning/02-wbs.md에 작성
2) 6주 일정을 .planning/04-schedule.md에 작성
3) 위험 요소 5개와 대응 방안 작성
```

### Step 3 — 설계

```
요구사항을 기반으로
1) docs/architecture.md 아키텍처 작성 (Mermaid 포함)
2) 핵심 결정은 .planning/decisions/ADR-*.md 로 분리
```

### Step 4 — 구현

```
[기능명]을 구현해줘.
- 파일 위치: lib/screens/xxx.dart
- 연관 Provider: XxxProvider
- 다국어 키 추가 필요: app_strings.dart
```

### Step 5 — 문서화

```
구현된 내용을 기반으로
docs/setup.md, docs/deploy.md, docs/testing.md 작성
신입 개발자가 5분 안에 따라할 수 있는 수준으로
```

---

## 3. 잘 통한 프롬프트 패턴

### 선택형 질문 먼저 받기
모호한 결정(플랫폼, 로그인 방식 등)은 AI에게 선택지를 받아 직접 결정.
→ "A, B, C 중 선택해" 방식이 "알아서 해줘"보다 결과 품질이 높음

### 파일 경로 명시
"home_screen.dart를 수정해줘" 보다
"lib/screens/home_screen.dart의 _TerminalPickerSheet를 수정해줘"가 정확함

### 에러 메시지 그대로 붙여넣기
flutter analyze 결과나 빌드 오류를 그대로 붙여넣으면 바로 해결됨

---

## 4. 실패 사례와 교훈

### 사례 1 — 순환 import
home_screen.dart에서 main_screen.dart를 import하려 했으나 순환 참조 발생.
→ Navigator.push로 우회. import 전에 의존 방향을 먼저 물어볼 것.

### 사례 2 — 경기광주 지역 분류 오류
공공 API cityName이 "광주"여서 경기도 터미널이 광주광역시로 분류됨.
→ 터미널명 prefix로 지역을 보정하는 _resolveRegion() 추가로 해결.
→ API 데이터를 맹신하지 말고 실제 출력값을 먼저 확인할 것.

### 사례 3 — 컨텍스트 초과
대화가 길어지면 이전 코드를 잊어버림.
→ 중요한 파일은 대화 시작 시 다시 읽어달라고 명시적으로 요청할 것.

---

## 5. 모델별 특성 (Claude Code 기준)

- 파일을 직접 읽고 수정하는 능력이 뛰어남
- 긴 파일도 한 번에 처리 가능
- "flutter analyze 실행해줘" 같은 터미널 명령도 직접 실행
- 한국어로 지시해도 코드는 영어로 작성됨 (의도된 동작)

---

## 6. 다음 프로젝트에서 할 것

- [ ] 프로젝트 시작 시 이 파일 먼저 Claude Code에 읽힌 후 시작
- [ ] ADR을 처음부터 `.planning/decisions/` 에 분리해서 작성
- [ ] 핵심 함수마다 주석 달기 습관화 (발표 대비)
