# 개발 환경 설정 가이드

## 필수 설치 항목

| 도구 | 버전 | 다운로드 |
|---|---|---|
| Flutter SDK | 3.11.5 이상 | https://flutter.dev |
| Dart | 3.x (Flutter 포함) | Flutter 설치 시 자동 포함 |
| Android Studio | 최신 | https://developer.android.com/studio |
| VS Code | 최신 | https://code.visualstudio.com |
| Git | 최신 | https://git-scm.com |

---

## OS별 Flutter 설치

### Windows

```powershell
# winget으로 설치 (권장)
winget install Google.Flutter

# 또는 공식 zip 다운로드 후 PATH 추가
# C:\flutter\bin 을 시스템 환경변수 PATH에 추가
[System.Environment]::SetEnvironmentVariable(
  "Path",
  $env:Path + ";C:\flutter\bin",
  [System.EnvironmentVariableTarget]::User
)
```

### macOS

```bash
# Homebrew로 설치 (권장)
brew install --cask flutter

# 또는 공식 zip 다운로드 후 PATH 추가
export PATH="$HOME/flutter/bin:$PATH"
# ~/.zshrc 또는 ~/.bash_profile에 위 줄 추가 후 source
```

### Linux (Ubuntu/Debian)

```bash
# snap으로 설치 (권장)
sudo snap install flutter --classic

# 의존 패키지 설치
sudo apt update && sudo apt install -y git curl unzip xz-utils zip libglu1-mesa clang cmake ninja-build pkg-config libgtk-3-dev
```

---

## 1. Flutter 설치 확인

```bash
flutter --version
flutter doctor
```

`flutter doctor` 결과에서 Android SDK, Connected device 항목에 체크 표시 확인

---

## 2. 프로젝트 클론

```bash
git clone https://github.com/minsung6167/Bus_app.git
cd Bus_app
```

---

## 3. 패키지 설치

```bash
flutter pub get
```

`pubspec.yaml` 기준 주요 패키지:

| 패키지 | 용도 |
|---|---|
| `provider` | 전역 상태 관리 |
| `shared_preferences` | 로컬 영구 저장 |
| `http` | 공공 API 호출 |
| `intl` | 날짜·숫자 포맷 |
| `flutter_dotenv` | 환경변수 관리 |

---

## 4. 환경변수 설정

`.env.example`을 복사해서 `.env` 파일 생성:

```bash
# macOS / Linux
cp .env.example .env

# Windows (PowerShell)
Copy-Item .env.example .env
```

`.env` 파일을 열어 실제 키 입력:

```
BUS_API_KEY=발급받은_공공API_키
```

각 키의 의미:
- `BUS_API_KEY` — 공공데이터포털 (data.go.kr) → 시외버스 운행정보 서비스 신청 후 발급

> `.env` 파일은 절대 커밋하지 마세요 (`.gitignore`에 등록됨)

---

## 5. 실행

```bash
# 연결된 기기 확인
flutter devices

# 앱 실행
flutter run

# 특정 기기 지정 실행
flutter run -d <device_id>
```

---

## 6. 빌드

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS (Mac 환경 필요)
flutter build ios --release
```

빌드 결과물 위치:
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

---

## 트러블슈팅

| 문제 | 해결 |
|---|---|
| `flutter doctor` 오류 | Android SDK 라이선스 동의: `flutter doctor --android-licenses` |
| 패키지 충돌 | `flutter clean && flutter pub get` |
| API 데이터 안 불러와짐 | `.env` 키 확인 또는 fallback 모드 동작 중 |
