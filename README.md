# Sample Rust Core · Flutter SDK

[한국어](README.ko.md)

The Flutter SDK lets an iOS or Android app fetch the signed-in user's profile with `account.getMe()`. Rust Inside builds the Rust library for both platforms and bundles the native binaries in the `sample_rust_core_flutter` Dart package. [Rust implementation](https://github.com/Rust-Inside/sample-rust-core/blob/v0.2.0/src/api.rs)

## Add the package to pubspec.yaml

Add the Git dependency to your app's `pubspec.yaml`. The package is in the `flutter` directory at tag `v0.2.0`. [Release v0.2.0](https://github.com/Rust-Inside/sample-flutter-sdk/releases/tag/v0.2.0)

```yaml
dependencies:
  sample_rust_core_flutter:
    git:
      url: https://github.com/Rust-Inside/sample-flutter-sdk.git
      ref: v0.2.0
      path: flutter
```

Run `flutter pub get` from the app root. The package supports Flutter 3.38 or later and Dart 3.10 or later within the 3.x series. The minimum deployment targets are iOS 18 and Android API 23.

On Android, declare `<uses-permission android:name="android.permission.INTERNET" />` in `android/app/src/main/AndroidManifest.xml` so the app can fetch the profile. [Flutter networking guide](https://docs.flutter.dev/data-and-backend/networking)

## Read the profile name

Pass the API server's origin as `baseUrl` and the full `Authorization` header value as `authorization`. Include the `Bearer` prefix if your server uses it. The Rust library sends that header with `GET /v1/me`.

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

`getMe()` returns a `Me` with `id`, `handle`, and `displayName`. If the request fails, awaiting `getMe()` throws a `StateError`. To share a client across screens, create it at sign-in and call `close()` at sign-out.

## License

[MIT](LICENSE)
