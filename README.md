# Contractor

Flutter frontend for SLT contractor service operations. The initial feature is staff-ID sign-in using the existing service API. Backend development is handled separately.

## Run locally

Developed with Flutter 3.32.8 and Dart 3.8.1. Android is the initial target.

```sh
flutter pub get
flutter devices
flutter run -d <android-device-id>
```

Use an Android emulator or connect a phone with USB debugging enabled. Check the local toolchain with `flutter doctor`; resolve any Android SDK or licence issues it reports.

## Sign-in API

`POST https://serviceportal.slt.lk/ApiGisCon/public/api/getUserData`

Headers: `Content-Type: application/json; charset=UTF-8` and `Accept: application/json`.

```json
{
  "sid": "<staff-id>",
  "appversion": "1.0.0"
}
```

SID is a string so leading zeroes are preserved. The UI currently validates non-empty, numeric SIDs; no fixed length has been specified.

The following response shapes were verified against the service on 10 November 2026. All profile values below are synthetic.

```json
{
  "error": false,
  "message": "LOGIN SUCCESS",
  "data": [
    {
      "SID": "001234",
      "CON_NAME": "Example Services",
      "USER_ROLE": "Test Role",
      "NAME": "Test Contractor",
      "RTOM": "Test RTOM"
    }
  ]
}
```

An invalid SID returns:

```json
{
  "error": true,
  "message": "NOT AUTHORIZED"
}
```

Both outcomes return **HTTP 201**. Sign-in checks `error == false`, one profile record, and an exact SID match. Optional profile fields are displayed when available. Unexpected responses, timeouts, connection failures and service errors leave the user on the login screen with a retryable error. Requests time out after 25 seconds.

For another environment, override the base URL, including the trailing slash:

```sh
flutter run --dart-define=API_BASE_URL=https://example.com/api/
```

The current endpoint performs SID-based access and returns profile data without a token. Account state is held in memory and cleared on sign-out or app restart. Microsoft Entra/Azure OAuth, token storage, session restoration and server-side logout are not part of this API contract. Add them when the backend team supplies those requirements. Keep `AppConfig.version` aligned with the application version in `pubspec.yaml`.

## Project structure

```text
lib/
  app/                     App setup and dependency wiring
  core/
    config/                API configuration and app version
    network/               Typed failures and user-facing messages
    theme/                 Shared colours, typography and spacing
    ui/                    Shared widgets
  features/
    auth/
      data/                HTTP service, response decoder and repository
      models/              Immutable account model
      presentation/        Login state, validation, screen and widgets
    account/
      presentation/        Verified account details and sign-out
test/
  features/auth/           API, response, controller and widget tests
  support/                 Test repositories
```

Widgets handle presentation, `LoginController` manages state, and the repository handles data access. Dependencies are passed through constructors. Add new features under `features/` and reuse the shared theme.

## Checks and build

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug
```

Tests use synthetic profiles and mock HTTP clients; they do not call the live API. Coverage includes the API's HTTP 201 rejection case, SID matching, malformed responses, request failures, duplicate submissions, retry, sign-out and small-screen layouts with larger text.

Debug APKs are written to `build/app/outputs/flutter-apk/app-debug.apk`. The generated release configuration currently uses the debug signing key; set up the production application ID and signing configuration before distribution.

## Commit convention

Use Conventional Commits, for example `feat(auth): add staff ID sign-in`, `fix(auth): handle rejected profiles`, or `docs: update setup instructions`.
