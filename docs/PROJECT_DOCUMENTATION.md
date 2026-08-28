# Powerlines 10-Day Practice — Project Documentation

## Purpose and scope

The `mobile/` directory contains the Flutter implementation of the Powerlines 10-Day Practice. It is a mobile-first application with Flutter Web enabled for review and distribution. The product is intentionally **local-first and offline**: a user can complete the 10-day practice without an account, backend, network API, or remote font request.

The app preserves the prior React prototype's practice model and content: ten sequential days, one Secret per day, Story, Power Lessons, Power Quiz, Power Move commitment, completion state, and a private reflection record. The implementation also retains the practice index overlay, rail navigation, day progress dots, saved diagnostic responses, timestamped commitments, and noon-anchored streak behavior.

> **Boundary:** This project is a client-only Flutter application. Do not add Supabase, tRPC, OAuth, a remote database, or server synchronization unless the product requirements explicitly change.

## Repository and directory structure

| Location | Responsibility |
|---|---|
| `mobile/lib/main.dart` | Application entry point, models, controller, router, theme, shared layout primitives, and all practice screens. |
| `mobile/pubspec.yaml` | Flutter SDK constraint, package dependencies, bundled image assets, and bundled font declarations. |
| `mobile/assets/images/` | Offline Powerlines mark, hero, and completion imagery. |
| `mobile/assets/fonts/` | Offline Bebas Neue and Poppins font files. |
| `mobile/web/index.html` | Flutter Web document shell and Powerlines metadata. |
| `mobile/web/manifest.json` | Web app name, description, display mode, and theme metadata. |
| `mobile/android/` | Android platform project and constrained Gradle settings used by the release build. |
| `.github/workflows/deploy-web.yml` | GitHub Actions workflow that builds Flutter Web and publishes `gh-pages`. |
| `mobile/README.md` | Mobile-specific quick start and deployment pointer. |
| `docs/PROJECT_DOCUMENTATION.md` | This detailed architecture, workflow, deployment, and troubleshooting reference. |
| `todo.md` | Historical and current project checklist. |

Generated directories such as `mobile/build/` are release outputs and should not be committed.

## Coding decisions

### Single controller with `ChangeNotifier`

`PracticeController` is the single source of truth for mutable practice state. This deliberately follows the prior React prototype's simple state model instead of introducing Riverpod, Bloc, Redux, or another heavier state framework. Widgets receive the controller through `ChangeNotifierProvider`, read immutable values, and call small intent methods for state changes.

This approach keeps the state vocabulary easy to audit: the controller owns the unlocked day, first-practice timestamp, saved responses, and commitments. It also gives the app one place to enforce day gating and persistence.

### Local-first persistence with two stores

The app uses `hive_flutter` for the structured practice record and `shared_preferences` for a small installation-level flag.

| Data | Store | Representation | Reason |
|---|---|---|---|
| `unlockedDay`, `firstPracticeAt`, `responses`, and `commitments` | Hive box `powerlines_practice` | One JSON-encoded record | Keeps the practice record structured, local, and easy to migrate as one unit. |
| Whether the user has started the practice | SharedPreferences key `powerlines_has_started` | Boolean | Keeps the welcome/start decision lightweight and independent of the record payload. |

The persistence layer is initialized before routing. State mutations update the in-memory model, persist immediately, and notify listeners. No user journal text is sent over the network.

### Route-based screen model

`go_router` provides exactly eight routed screen surfaces. The daily screens are parameterized by `:day`; the route count is not inflated by creating ten copies of the same screen.

| Route | Screen surface | Primary responsibility |
|---|---|---|
| `/` | Welcome | Explain the practice and begin or resume it. |
| `/day/:day/secret` | Secret | Present the day's central Powerline statement. |
| `/day/:day/story` | Story | Provide the day's narrative framing. |
| `/day/:day/lessons` | Power Lessons | Explain the practical lesson. |
| `/day/:day/quiz` | Power Quiz | Capture diagnostic responses. |
| `/day/:day/move` | Power Move | Capture a concrete commitment and timestamp it. |
| `/day/:day/complete` | Completion | Confirm the day and unlock the next day. |
| `/record` | Private reflection record | Review responses, commitments, streak evidence, and progress. |

A shared reading scaffold supplies the rail, top context, day label, progress dots, back/forward affordances, and index overlay. The index can navigate only to days that are already open, preserving the linear practice flow.

### Noon-anchored streak calculation

The streak helper deliberately mirrors the previous React behavior. Stored timestamps are parsed into the user's local calendar date, then compared at `T12:00:00` rather than at midnight. This avoids edge cases where daylight-saving transitions or late-night completion times cause two adjacent practice dates to compare incorrectly.

The streak is evidence-based: it is derived from completed commitment dates, not from page views, a timer, or a fabricated counter. Any change to this algorithm must be checked against the previous implementation before it is released.

### Offline typography and brand system

The visual system uses the Powerlines palette:

| Token | Hex | Use |
|---|---|---|
| Sovereign Black | `#0A0A0A` | Primary dark surfaces and high-contrast text. |
| Reclaim Red | `#C0001A` | Powerline accents, active states, and emphasis. |
| Declaration White | `#F5F5F3` | Paper surfaces and light text. |

Bebas Neue is used for display headlines and Poppins for body copy, labels, buttons, and form text. The font files are declared as Flutter assets and `GoogleFonts.config.allowRuntimeFetching = false` is set so the app does not depend on Google Fonts being reachable at runtime.

### Content fidelity over abstraction

The ten `DayContent` records are kept in the Flutter source in the same conceptual order as the React prototype. The UI uses reusable components for repeated presentation, but the content itself remains explicit and reviewable. This makes editorial comparison straightforward and avoids hiding the practice text in an opaque content service.

## Technology stack

| Layer | Technology | Decision or constraint |
|---|---|---|
| Language | Dart 3.13.x | Matches the installed Flutter stable toolchain and the Dart 3.x requirement. |
| UI/runtime | Flutter 3.47.2 | Flutter Web is enabled for preview; Android is the native delivery target. |
| State | `ChangeNotifier` | Lightweight state propagation matching the React prototype's simple state approach. |
| Routing | `go_router` 16.x | Declarative routing for the eight required screens and day parameters. |
| Structured storage | `hive_flutter` 1.1.0 | Local structured record storage, including Flutter Web IndexedDB support. |
| Preferences | `shared_preferences` 2.5.x | Small persistent boolean for start/resume behavior. |
| Typography | `google_fonts` 6.3.x plus bundled TTF files | Provides the Google Fonts API while disabling runtime network fetching. |
| Design | Material foundation with custom Powerlines theme | The palette, typography, spacing, controls, and reading scaffold are custom branded. |
| Assets | Flutter asset bundle | Images and fonts are packaged with the application for offline use. |
| Quality tooling | `flutter analyze`, `flutter_test`, `flutter_lints` | Static analysis and test-compatible project tooling. |
| Web deployment | GitHub Actions + `peaceiris/actions-gh-pages` | Builds the release bundle and publishes `mobile/build/web` to `gh-pages`. |

The package manifest is the authoritative source for versions. Run `flutter pub get` after changing it rather than editing generated dependency files by hand.

## Development workflow

### Start from the correct branch

All Flutter work belongs on the existing branch `manus/flutter-preview` in `SamuelAdewoye/powerlines-10-day-prototype`. Do not create a new repository or move the app into the React application directory.

```bash
git fetch https://github.com/SamuelAdewoye/powerlines-10-day-prototype.git manus/flutter-preview
git checkout manus/flutter-preview
cd mobile
```

### Make a change

Keep changes scoped to `mobile/`, `.github/workflows/deploy-web.yml`, and documentation unless a requirement explicitly calls for another area. Update `todo.md` before starting a new requested feature or fix. Prefer the existing controller, model, scaffold, and reusable controls before introducing new abstractions.

When changing content or navigation, compare the corresponding React source and verify all eight surfaces end-to-end. When changing persistence, test both a fresh install and a reload with an existing local record.

### Resolve dependencies and validate

Run the standard validation sequence from the repository root:

```bash
cd mobile
flutter pub get
flutter analyze
flutter build web --release
```

For an interactive local browser preview, use the Flutter toolchain or serve the generated release directory:

```bash
flutter run -d chrome
# or, after flutter build web --release:
python3 -m http.server 4173 --directory build/web
```

Check the welcome screen, one complete day, a locked future day, the index overlay, the private record, a saved diagnostic response, a Power Move timestamp, and streak rendering. Browser console errors should be investigated even when the page visually appears to load.

### Commit and push

Use a focused commit message, inspect the diff, and push the existing branch:

```bash
git diff --check
git status --short
git add mobile/ .github/workflows/deploy-web.yml docs/ todo.md
git commit -m "docs(mobile): document Flutter project"
git push user_github manus/flutter-preview
```

The remote name may differ after a sandbox restore. Confirm the configured GitHub remote before pushing, and never force-push over another contributor's changes.

## Deployment workflow

### GitHub Pages Web deployment

`.github/workflows/deploy-web.yml` runs on pushes to `manus/flutter-preview` when `mobile/**` or the workflow changes. It can also be started manually with `workflow_dispatch`.

The workflow performs the following steps:

1. Checks out the repository.
2. Installs the Flutter stable channel.
3. Runs `flutter pub get` inside `mobile/`.
4. Runs `flutter build web --release --base-href "/powerlines-10-day-prototype/"`.
5. Publishes `mobile/build/web` to the `gh-pages` branch using the repository `GITHUB_TOKEN`.

GitHub Pages must be configured to deploy from the `gh-pages` branch at the repository root. The verified project URL is:

`https://samueladewoye.github.io/powerlines-10-day-prototype/`

The `--base-href` is essential for a project site hosted below a repository path. Without it, Flutter's asset and JavaScript URLs resolve from `/` and the site may display a blank or broken shell.

### Manus preview

The release bundle can be served from a temporary sandbox port for live review. The current preview URL is session-dependent and should not be treated as permanent hosting:

`https://4173-ioxah01w0sqfhkj7d2242-5700966c.us2.manus.computer`

If the sandbox is reset, the port or exposed hostname can change. Rebuild the Web release, start a static server on the new port, expose it, and report the new URL rather than assuming the old hostname remains available.

### Android ARM64 release

The requested command is:

```bash
cd mobile
flutter build apk --release --split-per-abi
```

The ARM64 output is expected at:

`mobile/build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`

On the constrained sandbox, the split-ABI Gradle invocation can be killed by the operating system while the Android toolchain is otherwise healthy. The known fallback is an ARM64-only release build with bounded Gradle memory:

```bash
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export GRADLE_OPTS='-Xmx1200m -XX:MaxMetaspaceSize=512m -XX:ReservedCodeCacheSize=192m'
cd mobile
flutter build apk --release --target-platform android-arm64
cp build/app/outputs/flutter-apk/app-release.apk \
  build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

Verify the artifact is non-empty and contains `lib/arm64-v8a/` before distribution. The fallback is an ARM64-only release package, not a claim that all ABI variants were built.

## Known gotchas and recovery guidance

| Gotcha | Symptom | Resolution |
|---|---|---|
| Flutter Web project-path hosting | GitHub Pages loads a shell but assets or `main.dart.js` fail. | Keep the workflow's `--base-href "/powerlines-10-day-prototype/"` aligned with the repository path. |
| Sandbox reset | The workspace returns to the webdev `main` checkout and `mobile/` appears missing. | Fetch and checkout `manus/flutter-preview` again before editing; do not reconstruct or replace the Flutter branch from `main`. |
| Generated release output | `mobile/build/` is large and changes constantly. | Treat it as generated output; rebuild locally or in Actions instead of committing it. |
| Runtime font fetching | Typography changes or fails when offline. | Keep the bundled TTF files registered in `pubspec.yaml` and retain `GoogleFonts.config.allowRuntimeFetching = false`. |
| Hive Web storage | A browser reload appears to lose state when storage is cleared or private browsing is used. | Use a normal browser profile and do not clear site data when testing persistence. Hive Web uses browser storage, not a remote database. |
| Android Gradle memory | `flutter build apk --split-per-abi` terminates with a killed Gradle daemon in a small sandbox. | Use the bounded-memory ARM64 fallback above; do not interpret a sandbox kill as an application compile error. |
| GitHub Pages settings | The workflow succeeds but the site is not reachable. | Confirm the repository is eligible for Pages and set Pages source to `gh-pages` / root. A public repository is required under the applicable free-plan configuration. |
| Transfer service availability | A requested `transfer.sh` upload can fail during TLS negotiation even when the APK is valid. | Preserve the verified APK locally, retry only with a different transport, and disclose any fallback CDN link rather than claiming a transfer.sh URL. |
| Headless Flutter screenshots | A screenshot can appear nearly blank even though the Flutter app has initialized. | Check the page title, Flutter boot marker, browser console, Hive initialization, and interactive browser behavior; do not infer an app failure from one headless CanvasKit capture. |
| React and Flutter project overlap | The repository also contains the earlier React prototype and a server scaffold. | Keep the Flutter task isolated to `mobile/` and its workflow. The Flutter app does not use the React server, database, OAuth, or tRPC layers. |
| Branch drift | A local commit is made on `main` after a restore. | Run `git branch --show-current` before editing and `git status --short` before pushing. Push only `manus/flutter-preview` for this app. |

## Verification record

The implementation was validated with Flutter 3.47.2 and Dart 3.13.2. `flutter pub get`, `flutter analyze`, and `flutter build web --release` completed successfully. The ARM64 Android package was built with the constrained fallback and verified to contain an ARM64 native library. The GitHub Actions Web deployment completed successfully, and the GitHub Pages URL returned the Powerlines page title after Pages was configured to use `gh-pages`.

The verification above confirms build and deployment behavior; it does not replace testing on a physical Samsung A06. Install the ARM64 APK on the target device and check text wrapping, keyboard behavior, safe areas, persistence after force-close, and the complete ten-day navigation flow.

## References

[1]: https://docs.flutter.dev/deployment/web Flutter Web deployment documentation
[2]: https://docs.flutter.dev/deployment/android Android deployment documentation
[3]: https://pub.dev/packages/hive_flutter `hive_flutter` package documentation
[4]: https://pub.dev/packages/shared_preferences `shared_preferences` package documentation
[5]: https://pub.dev/packages/go_router `go_router` package documentation
[6]: https://docs.github.com/en/pages/getting-started-with-github-pages/creating-a-github-pages-site GitHub Pages configuration documentation
[7]: https://github.com/peaceiris/actions-gh-pages `peaceiris/actions-gh-pages` documentation
