# 빌드 & 배포 가이드

## 사전 준비

```bash
# Flutter 환경 확인
flutter doctor

# 패키지 설치
flutter pub get

# 코드 분석 (경고 0건 확인)
flutter analyze
```

---

## Android 빌드

### Debug APK (개발·테스트용)

```bash
flutter build apk --debug
```

결과물: `build/app/outputs/flutter-apk/app-debug.apk`

### Release APK (배포용)

```bash
flutter build apk --release
```

결과물: `build/app/outputs/flutter-apk/app-release.apk`

### App Bundle (Google Play 제출용)

```bash
flutter build appbundle --release
```

결과물: `build/app/outputs/bundle/release/app-release.aab`

---

## iOS 빌드 (Mac + Xcode 필요)

```bash
# iOS 빌드
flutter build ios --release

# IPA 생성 (Xcode에서 Archive 후 Export)
```

> ⚠️ Windows 환경에서는 iOS 빌드 불가. Mac + Xcode 14 이상 필요.

---

## 기기 직접 설치

### Android

```bash
# USB 연결 후
flutter install

# 또는 APK 직접 설치
adb install build/app/outputs/flutter-apk/app-release.apk
```

### 에뮬레이터 실행

```bash
# 에뮬레이터 목록 확인
flutter emulators

# 에뮬레이터 실행
flutter emulators --launch <emulator_id>

# 앱 실행
flutter run
```

---

## 빌드 전 체크리스트

- [ ] `flutter analyze` 경고 0건
- [ ] `flutter test` 전체 통과
- [ ] `.env` API 키 설정 확인
- [ ] `pubspec.yaml` 버전 업데이트
- [ ] Android `minSdkVersion` 확인 (21 이상)

---

## 졸업 작품 제출용 빌드

```bash
# 1. 최종 분석
flutter analyze

# 2. Release APK 빌드
flutter build apk --release

# 3. 결과물 확인
# build/app/outputs/flutter-apk/app-release.apk
```

제출 파일: `app-release.apk` (약 20~30MB)
