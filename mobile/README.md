# Powerlines — 10-Day Practice

For the full architecture, coding decisions, development workflow, deployment procedure, and gotchas, see [`docs/PROJECT_DOCUMENTATION.md`](../docs/PROJECT_DOCUMENTATION.md).

This is a **Flutter 3.47 / Dart 3.13** mobile-first implementation of the Powerlines 10-Day Practice. It contains no backend, account service, or remote data dependency. Diagnostic answers and Power Move commitments are stored only on the active device using Hive and SharedPreferences.

## Included practice flow

The app implements eight routed screens: welcome, Secret, Story, Power Lessons, Power Quiz, Power Move, completion, and private reflection record. It includes the 10-day index overlay, linear day unlocking, a noon-anchored streak calculation, saved diagnostic answers, and committed Power Moves.

## Local build

```bash
flutter config --enable-web
flutter analyze
flutter pub get
flutter build web --release
flutter build apk --release --split-per-abi
```

The Android arm64 artifact is available at `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` after the release build. The included assets and locally bundled Bebas Neue and Poppins files keep the practice usable without a backend or runtime font fetch.

## Published web build

The GitHub Pages workflow in `.github/workflows/deploy-web.yml` publishes the Flutter Web release whenever `manus/flutter-preview` changes. The verified site URL is:

`https://samueladewoye.github.io/powerlines-10-day-prototype/`
