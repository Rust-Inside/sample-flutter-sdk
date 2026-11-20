# Sample Rust Core · Flutter SDK

[English](README.md) | [한국어](README.ko.md)

iOS와 Android용 Flutter 앱에서 SDK의 `account.getMe()`를 호출하면 로그인한 사용자의 프로필을 받습니다. Rust Inside는 공통 Rust 라이브러리를 두 플랫폼용으로 빌드해 네이티브 바이너리를 `sample_rust_core_flutter` Dart 패키지에 담아 배포합니다. [Rust 구현](https://github.com/Rust-Inside/sample-rust-core/blob/v0.2.0/src/api.rs)

## pubspec.yaml에 패키지 추가

앱의 `pubspec.yaml`에 Git 의존성을 추가하세요. 패키지는 `v0.2.0` 태그의 `flutter` 디렉터리에 있습니다. [v0.2.0 릴리스](https://github.com/Rust-Inside/sample-flutter-sdk/releases/tag/v0.2.0)

```yaml
dependencies:
  sample_rust_core_flutter:
    git:
      url: https://github.com/Rust-Inside/sample-flutter-sdk.git
      ref: v0.2.0
      path: flutter
```

앱 루트에서 `flutter pub get`을 실행하세요. Flutter 3.38 이상, Dart 3.10 이상 4.0 미만을 지원합니다. 최소 배포 버전은 iOS 18, Android API 23입니다.

Android에서 프로필을 조회하려면 `android/app/src/main/AndroidManifest.xml`에 `<uses-permission android:name="android.permission.INTERNET" />`를 선언하세요. [Flutter 네트워크 설정](https://docs.flutter.dev/data-and-backend/networking)

## 프로필 이름 읽기

`baseUrl`에는 API 서버 주소를, `authorization`에는 `Authorization` 헤더 값을 넣으세요. 서버가 Bearer 인증을 쓰면 `Bearer` 접두사까지 전달합니다. Rust 라이브러리는 `GET /v1/me` 요청에 이 헤더를 붙입니다.

```dart
import 'package:sample_rust_core_flutter/sample_rust_core_flutter.dart';

Future<String> profileName(String apiOrigin, String authorization) async {
  final account = AccountClient(baseUrl: apiOrigin, authorization: authorization);
  try {
    final Me me = await account.getMe();
    return me.displayName;
  } finally {
    account.close();
  }
}
```

`getMe()`가 반환하는 `Me`에는 `id`, `handle`, `displayName`이 있습니다. 요청이 실패하면 `await account.getMe()`에서 `StateError`가 발생합니다. 여러 화면에서 클라이언트를 함께 쓴다면 로그인할 때 만들고 로그아웃할 때 `close()`를 호출하세요.

## 라이선스

[MIT](LICENSE)
