# GIS Contractor

Flutter frontend for SLT contractor field operations. Sign in with a service ID, open the network map, load a plan and inspect its equipment. Backend development is handled separately.

## Run locally

Developed with Flutter 3.32.8 and Dart 3.8.1. Android is the mobile target, with a web preview for inspecting the interface on this machine.

### Run or build for Android

```sh
flutter pub get
flutter devices
flutter run -d <android-device-id> --dart-define-from-file=.local/maps.json
flutter build apk --debug --dart-define-from-file=.local/maps.json
```

Use an Android emulator or connect a phone with USB debugging enabled. Check the local toolchain with `flutter doctor`; resolve any Android SDK or licence issues it reports.

On the currently configured Pixel emulator, use `flutter run -d emulator-5554 --dart-define-from-file=.local/maps.json`. In VS Code, select the Android device in the status bar, choose **GIS Contractor (Android)**, then press F5. Press `r` for hot reload, `R` to restart, or `q` to stop a terminal run. Changing build-time configuration requires stopping and running again.

Login always verifies the entered service ID using the supplied API. Leading zeroes are preserved. Rejected IDs remain on the login screen; there is no temporary bypass or additional sign-in provider.

Maps requires Android API 24 or newer. Enable **Maps SDK for Android** for an Android build, or **Maps JavaScript API** for the browser preview, in the key's Google Cloud project. The key's application restrictions must allow the intended Android package/signing certificate or local preview origin. No Maps key is stored in source.

### Maps key for development and handover

A developer-owned Google Cloud project and Maps key can be used during development. Enable billing and **Maps SDK for Android** in that project. Restrict the key to Android apps using package `lk.contractor.contractor_app` and the SHA-1 of the certificate signing the APK. Follow Google's [Android Maps setup guide](https://developers.google.com/maps/documentation/android-sdk/get-api-key) for the Cloud settings.

Create the local `.local/maps.json` file:

```json
{
  "GOOGLE_MAPS_API_KEY": "<your-google-maps-key>"
}
```

This file stays outside Git. The Android build command above reads the key from it. Changing the key requires rebuilding the APK.

At handover, the receiving team creates this configuration with its own Android-authorized key and builds the app. The key's Android restrictions must match the final package name and signing certificate. Switching keys does not require Dart, Gradle or manifest source edits.

## Sign-in API

`POST https://serviceportal.slt.lk/ApiGisCon/public/api/getUserData`

Headers: `Content-Type: application/json; charset=UTF-8` and `Accept: application/json`.

```json
{
  "sid": "<service-id>",
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

The endpoint performs service-ID access and returns profile data without a token. This is the complete login requirement. Account state is held in memory and cleared on sign-out or app restart; no server logout endpoint or session token has been supplied. Keep `AppConfig.version` aligned with the application version in `pubspec.yaml`.

The login profile's `RTOM` field is not used to populate the map selector.

## Equipment and RTOM map

`POST https://serviceportal.slt.lk/ApiGisCon/public/api/getEquipmentView`

```json
{
  "plevntno": "FTTH_Civilect Zone_2024_049_20261103104951"
}
```

The verified response is HTTP 200 with boolean `error: false` and a `data` list. Each record contains `RTOM`, `LOCATION`, `TYPE`, `LATITUDE`, `LONGITUDE`, `DISTANCE`, `OCCUPIED`, `FREE`, `DISCRIPTION`, `INDEX`, `LEA` and `STATUS`. Coordinates arrive as strings. The model handles the service's `DISCRIPTION` spelling at the data boundary.

The supplied plan returned 347 equipment records, all in RTOM `R-AD`, when checked on 11 November 2026. RTOM and equipment-type choices come only from the equipment response. Counts reflect the current filter. Selecting a marker or list item opens its details. Map/satellite switching and fitting the camera to the filtered equipment are supported. Invalid coordinates are skipped and the skipped count is shown.

The response provides equipment points tagged with an RTOM code. It does not provide RTOM boundary polygons; no boundaries or sample city markers are fabricated.

`MH` is displayed as **MH (Manhole)**, as confirmed by the project team. Other equipment type codes are displayed exactly as received.

The map uses `google_maps_flutter` on Android and web. The web loader uses the maintained Maps JavaScript version without the old `drawing` library. Google [retired that library in May 2026](https://developers.google.com/maps/deprecations#drawing-library); drawing tools are outside the current read-only map scope.

The supplied key rejected the local browser origin with `RefererNotAllowedMapError` during verification. Its owner would need to allow `http://127.0.0.1:8080/*` for that preview. Android requires a key enabled for Maps SDK for Android and the correct Android application restriction; a website-restricted key cannot be reused unchanged for Android. Equipment remains accessible even if the base map cannot be authorised. Visual testing is currently focused on Android.

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
    home/
      presentation/        Post-login workspace and map action
    map/
      data/                Plan equipment repository
      models/              Equipment and dataset models
      platform/            Browser Maps script loading
      presentation/        Map state, screen, filters and equipment details
test/
  features/                Auth/map API, controller and widget tests
  support/                 Test repositories
tool/                      Local browser preview tooling
web/                       Flutter browser bootstrap
```

Widgets handle presentation, `LoginController` manages state, and the repository handles data access. Dependencies are passed through constructors. Add new features under `features/` and reuse the shared theme.

## Checks and build

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build web --dart-define-from-file=.local/maps.json
flutter build apk --debug --dart-define-from-file=.local/maps.json
```

Tests use synthetic profiles and mock HTTP clients; they do not call the live API. Coverage includes the API's HTTP 201 rejection case, SID matching, malformed responses, request failures, duplicate submissions, retry, sign-out and small-screen layouts with larger text.

Debug APKs are written to `build/app/outputs/flutter-apk/app-debug.apk`. The generated release configuration currently uses the debug signing key; set up the production application ID and signing configuration before distribution.

## Commit convention

Use Conventional Commits, for example `feat(auth): add service ID sign-in`, `fix(auth): handle rejected profiles`, or `docs: update setup instructions`.

## Optional browser preview

Install Flutter and Python, then configure `.local/maps.json` as described above with a key authorized for Maps JavaScript API and the local preview origin. In PowerShell, from the project folder:

```powershell
flutter pub get
powershell -ExecutionPolicy Bypass -File tool/preview.ps1
```

Open **http://127.0.0.1:8080** in Chrome. Keep the terminal open; press Ctrl+C to stop. The first screen is login. Use an authorised service ID, then choose **Network map**. To serve an existing web build without rebuilding, run `python tool/preview_server.py`.

The supplied SLT APIs currently lack the CORS response headers that browsers require. The local preview helper forwards only the two known API requests to SLT, binds to `127.0.0.1`, and stores no account data. Android calls SLT directly. This helper is for development; a deployed web app would need the API team to enable CORS.
