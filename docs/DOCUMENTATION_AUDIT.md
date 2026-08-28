# Documentation-to-Code Audit

**Audit target:** `manus/flutter-preview`  
**Audit date:** 28 August 2026  
**Audited implementation:** `mobile/lib/main.dart`, `mobile/pubspec.yaml`, `mobile/web/`, `mobile/android/gradle.properties`, `.github/workflows/deploy-web.yml`, and `docs/PROJECT_DOCUMENTATION.md`

## Executive conclusion

The documentation now matches the current Flutter implementation and repository configuration. One discrepancy was found and corrected: the architecture document previously described `ChangeNotifierProvider`, but the app does not use the `provider` package. The actual implementation passes `PracticeController` through screen constructors and uses `AnimatedBuilder` at the screens and shared surfaces that need to rebuild.

No other material mismatches were found in the documented routes, state fields, persistence keys, assets, fonts, brand colors, web workflow, Android build fallback, or known deployment constraints.

## Audit matrix

| Documented claim | Current implementation evidence | Result |
|---|---|---|
| Flutter/Dart toolchain is Flutter 3.47 / Dart 3.13 | `mobile/pubspec.yaml` requires Dart `^3.13.2`; the recorded successful validation used Flutter 3.47.2 and Dart 3.13.2. | Confirmed |
| State uses one `PracticeController extends ChangeNotifier` | `mobile/lib/main.dart` defines `PracticeController extends ChangeNotifier`. | Confirmed |
| State propagation uses constructor injection and `AnimatedBuilder` | Screens accept `PracticeController controller`; `AnimatedBuilder` appears on the welcome, completion, record, and index surfaces. No `provider` dependency or `ChangeNotifierProvider` symbol exists. | Confirmed after documentation correction |
| Saved practice fields are `unlockedDay`, `firstPracticeAt`, `responses`, and `commitments` | `SavedPractice` defines exactly these fields and serializes them through `toJson` / `fromJson`. | Confirmed |
| Hive stores one JSON record | `PracticeStorage` opens Hive box `powerlines_practice`, uses record key `saved_practice`, and stores `jsonEncode(state.toJson())`. | Confirmed |
| SharedPreferences stores the start flag | `PracticeController.hasStarted` reads `powerlines_has_started`; commit and reset update/remove the same key. | Confirmed |
| Initialization occurs before the router is used | `main()` initializes Flutter, disables runtime font fetching, initializes Hive, opens storage, loads SharedPreferences, initializes the controller, then calls `runApp`. | Confirmed |
| There are exactly eight routed screen surfaces | `PowerlinesApp` defines eight `GoRoute` entries: `/`, six day-stage routes, and `/record`. | Confirmed |
| Day routing is parameterized and clamped to 1–10 | `_dayParam` parses `:day` and clamps it to the range 1–10. | Confirmed |
| The practice has ten explicit day records | `days` is a `const List<DayContent>` with ten entries, each containing a Secret, story title, story, lessons, questions, and move. | Confirmed |
| The practice index only opens unlocked days | `showPracticeIndex` sets `open = day <= controller.unlockedDay` and disables `onTap` for locked entries. | Confirmed |
| Power Move commits unlock the next day | `commitPowerMove` increments `unlockedDay` only when committing the current unlocked day and when the current day is below the final day. | Confirmed |
| Commitments use UTC storage and local display | `commitPowerMove` stores `DateTime.now().toUtc().toIso8601String()`; `displayTimestamp` parses and converts to local time. | Confirmed |
| Streak calculation uses local dates with a noon anchor | `_dateKey` converts stored timestamps to local calendar dates; `calculateStreak` compares parsed `T12:00:00` values. | Confirmed |
| Brand colors match the specification | `main.dart` defines `#0A0A0A`, `#C0001A`, and `#F5F5F3` as the principal color constants. | Confirmed |
| Typography is bundled for offline use | `pubspec.yaml` registers Bebas Neue and Poppins TTF assets; `main()` sets `GoogleFonts.config.allowRuntimeFetching = false`. | Confirmed |
| The three specified images are bundled | `pubspec.yaml` registers the mark PNG, hero JPG, and completion-field JPG under `assets/images/`; all files exist. | Confirmed |
| GitHub Pages builds from the Flutter branch | The workflow triggers on `manus/flutter-preview`, runs from `mobile/`, builds with the project-site base href, and publishes `mobile/build/web` to `gh-pages`. | Confirmed |
| GitHub Pages uses the repository-path base href | The workflow uses `--base-href "/powerlines-10-day-prototype/"`, matching the repository's Pages URL. | Confirmed |
| Android fallback is ARM64-only and memory constrained | `gradle.properties` disables the daemon, limits workers to one, disables parallelism, and caps JVM memory; the documented fallback uses `--target-platform android-arm64`. | Confirmed |
| The React server is outside the Flutter runtime boundary | Flutter source imports only Flutter and the four declared Dart packages; no tRPC, OAuth, Supabase, or server module is imported. | Confirmed |

## Documentation changes made during the audit

The state-management section of `docs/PROJECT_DOCUMENTATION.md` was corrected to describe explicit controller constructor injection and `AnimatedBuilder`. The stale provider-based wording was removed. This audit report was added so future contributors can repeat the comparison against the same source locations.

## Recommended re-audit triggers

Repeat this audit whenever a new state-management package is added, route count changes, persistence keys or serialized fields change, the GitHub Pages workflow changes, the Android build strategy changes, or the React and Flutter implementations are reconciled again. A dependency update alone does not require rewriting the architecture document unless it changes runtime behavior or the supported build workflow.
