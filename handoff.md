# Powerlines Prototype — AI-Agent Handoff

**Handoff target:** A future AI coding agent or human maintainer  
**Repository:** `SamuelAdewoye/powerlines-10-day-prototype`  
**Primary worktree:** `/home/ubuntu/powerlines-10-day-prototype`  
**Current feature branch:** `manus/flutter-preview`  
**Last audited branch revision before this handoff:** `f0e5979`  
**Handoff date:** 28 August 2026

## 1. Mission and operating rules

The repository contains two related Powerlines implementations. The `main` branch contains the original React/Web prototype. The `manus/flutter-preview` branch contains the native Flutter mobile-first implementation with Flutter Web enabled for review and GitHub Pages distribution.

Treat the two implementations as separate products that share editorial intent and content fidelity. Do not merge the React server scaffold into the Flutter app. Do not introduce a backend, Supabase, tRPC, OAuth, remote database, or remote font dependency into the Flutter branch unless the product requirements explicitly change.

Before editing, confirm the branch and working tree:

```bash
git branch --show-current
git status --short
```

For this handoff, the correct Flutter branch is `manus/flutter-preview`. Keep generated outputs out of Git, avoid force-pushes, and preserve unrelated work from other contributors. Update `todo.md` with an unchecked item before beginning a newly requested feature or fix, then mark it complete immediately after validation.

## 2. Repository map

| Branch or path | Role | Do not confuse it with |
|---|---|---|
| `main` | React/Web prototype and the repository's default branch. | The Flutter mobile application. |
| `manus/flutter-preview` | Flutter 10-Day Practice implementation and its Web deployment workflow. | The earlier React PWA and its server scaffold. |
| `client/src/pages/Home.tsx` on `main` | React practice content, screen state machine, localStorage persistence, rail, progress dots, index overlay, and reflection entry point. | `mobile/lib/main.dart`, which is the Flutter implementation. |
| `client/src/components/ReflectionDashboard.tsx` on `main` | React private reflection dashboard and streak presentation. | A backend dashboard. It is client-side in the current React flow. |
| `mobile/lib/main.dart` on `manus/flutter-preview` | Flutter content, model, controller, routing, screen widgets, shared scaffold, theme, and storage wiring. | The React `Home.tsx` state machine. |
| `.github/workflows/deploy-web.yml` on `manus/flutter-preview` | Flutter Web build and `gh-pages` publisher. | The Manus-hosted React preview. |
| `docs/PROJECT_DOCUMENTATION.md` | Detailed Flutter architecture, stack, workflow, deployment, and gotchas. | A specification for the React server. |
| `docs/DOCUMENTATION_AUDIT.md` | Source-to-documentation audit matrix. | Automated test output. |
| `todo.md` | Historical and active implementation checklist across both prototypes. | A clean-room task list; old items are retained for history. |

## 3. Main branch: current implementation and plan

### 3.1 Current state of `main`

The `main` branch is the original React 19/Tailwind prototype. Its practice is intentionally client-side and local-first even though the repository also contains a Manus full-stack scaffold. The React application keeps the active screen in `useState`, loads and saves `SavedPractice` through `window.localStorage`, and renders the private reflection dashboard from local records.

The React flow has the same editorial core as the Flutter version: ten explicit day records, Secret, Story, Lessons, Quiz, Move, completion, private reflection, a minimal rail, day dots, a day index overlay, gated progression, and a noon-anchored streak helper. The important source files are:

| File | Current responsibility |
|---|---|
| `client/src/App.tsx` | Error boundary, light theme provider, tooltip provider, Home mount, and toaster. |
| `client/src/pages/Home.tsx` | Ten-day content, `SavedPractice`, screen union, localStorage lifecycle, navigation state, day gating, progress rail, and stage rendering. |
| `client/src/components/ReflectionDashboard.tsx` | Saved diagnostic answers, Power Move records, completion evidence, and streak calculation. |
| `client/src/index.css` | Editorial redline visual system and brand styling. |
| `client/index.html` | React/Vite document metadata and PWA shell integration where applicable. |
| `package.json` | pnpm scripts, React/Vite/TypeScript dependencies, Vitest, and full-stack scaffold packages. |
| `server/`, `drizzle/`, `shared/` | Manus capability scaffolding added during an earlier project upgrade. The current Powerlines practice does not need these for local reflection behavior. |

The earlier React prototype was deployed at `https://powerlines-66erprja.manus.space`. Treat that as the React prototype URL, not as proof that the Flutter Web build is deployed there.

### 3.2 Main branch implementation plan

If the next agent is asked to continue the React prototype, use this order:

1. Confirm `main` is checked out and inspect `client/src/pages/Home.tsx`, `client/src/components/ReflectionDashboard.tsx`, and `client/src/index.css` before changing behavior.
2. Preserve the `SavedPractice` shape and the exact ten-day content unless the user explicitly requests editorial changes. Any content change should be mirrored intentionally in the Flutter branch or called out as a deliberate divergence.
3. Keep private reflections local to the browser. Do not wire the React screens to the server database merely because the repository contains database and OAuth scaffolding.
4. Run the React checks appropriate to the installed package state, normally `pnpm install`, `pnpm test`, `pnpm build`, and a browser verification of the complete flow. If the server-backed dev command fails because a scaffold dependency such as `dotenv` is unavailable, diagnose the package lock and scripts before modifying application code.
5. If adding backend features, follow the existing project guidance: update schema first, generate migration SQL, apply schema changes through the managed database workflow, add server helpers/procedures, and write Vitest coverage. Do not use backend work as a shortcut for Flutter persistence.
6. Keep the React deployment and Flutter deployment separately labeled in any handoff, release note, or user-facing response.

### 3.3 Main branch boundaries and risks

The main branch has accumulated full-stack template files from a prior capability update. Those files are infrastructure, not evidence that the current journal UI is server-backed. The React practice currently has no requirement for authentication, cross-device sync, payments, or remote content.

The React and Flutter implementations can drift in subtle ways. The highest-risk drift areas are the day content, `SavedPractice` field names, stage order, day-unlock semantics, timestamp formatting, reset behavior, and streak calculation. When parity matters, compare the React source and Flutter source side by side rather than translating from memory.

## 4. Mobile branch: current implementation and plan

### 4.1 Current state of `manus/flutter-preview`

The mobile branch contains a Flutter 3.47.2 / Dart 3.13.2 implementation under `mobile/`. It is mobile-first, enables Flutter Web for preview, and is fully offline during normal use. The app uses bundled assets and fonts, so it does not need a network connection to fetch visual resources.

The current Flutter app has exactly eight `go_router` routes:

| Route | Surface |
|---|---|
| `/` | Welcome |
| `/day/:day/secret` | Secret |
| `/day/:day/story` | Story |
| `/day/:day/lessons` | Power Lessons |
| `/day/:day/quiz` | Power Quiz |
| `/day/:day/move` | Power Move |
| `/day/:day/complete` | Completion |
| `/record` | Private reflection record |

`SavedPractice` contains `unlockedDay`, `firstPracticeAt`, `responses`, and `commitments`. `PracticeStorage` opens the Hive box `powerlines_practice`, reads and writes the `saved_practice` JSON record, and safely falls back to an empty record if decoding fails. `SharedPreferences` stores the `powerlines_has_started` boolean. `PracticeController extends ChangeNotifier`; screens receive the controller through constructors and use `AnimatedBuilder` where reactive rebuilding is needed. The implementation does not use `provider`, Riverpod, Bloc, or another state container.

Commitment timestamps are stored as UTC ISO-8601 strings and converted to local time for display. The streak helper converts timestamps to local calendar date keys and compares dates at `T12:00:00`, matching the prior React behavior. The index sheet disables locked days, the current commitment unlocks the next day, and the final day routes to the private record.

The brand constants are Sovereign Black `#0A0A0A`, Reclaim Red `#C0001A`, and Declaration White `#F5F5F3`. Bebas Neue and Poppins are bundled in `mobile/assets/fonts/` and declared in `mobile/pubspec.yaml`. The three bundled images are in `mobile/assets/images/` and are also explicitly registered in `pubspec.yaml`.

### 4.2 Mobile branch implementation plan

For a future Flutter change, follow this sequence:

1. Fetch and checkout `manus/flutter-preview`. Confirm that `mobile/` exists and that the branch is not accidentally based on `main`.
2. Read `mobile/lib/main.dart` and the relevant sections of `docs/PROJECT_DOCUMENTATION.md` and `docs/DOCUMENTATION_AUDIT.md` before changing architecture, persistence, routes, or content.
3. Add a new unchecked `todo.md` item before implementation. Reuse `DayContent`, `SavedPractice`, `PracticeStorage`, `PracticeController`, `PracticeShell`, and existing typography/button primitives where applicable.
4. Preserve the eight route surfaces and linear practice order. If a new product requirement needs another surface, update the route plan and documentation explicitly instead of silently changing the count.
5. For content changes, compare against `main`'s React content and update both branches deliberately when parity is required.
6. For persistence changes, test a fresh install, reload, force-close/reopen, reset, and a browser reload. Confirm that no reflection text leaves the device.
7. Run `flutter pub get`, `flutter analyze`, and `flutter build web --release`. Test the Web flow and at least one complete day interactively.
8. For Android delivery, use the split-ABI command first. If the constrained sandbox kills Gradle, use the documented ARM64-only fallback, verify `lib/arm64-v8a/`, and label it accurately as ARM64-only.
9. Inspect the diff, update the documentation and checklist, commit with a focused message, and push only `manus/flutter-preview`.

### 4.3 Mobile files that matter

| File or directory | Why the next agent should inspect it |
|---|---|
| `mobile/lib/main.dart` | Entire current app; the source is intentionally centralized for this prototype. |
| `mobile/pubspec.yaml` | Authoritative package, SDK, font, and image declarations. |
| `mobile/pubspec.lock` | Resolved package versions; regenerate with `flutter pub get`, do not hand-edit. |
| `mobile/assets/images/` | Offline Powerlines imagery. |
| `mobile/assets/fonts/` | Offline Bebas Neue and Poppins files. |
| `mobile/web/index.html` | Web title, theme metadata, and manifest link. |
| `mobile/web/manifest.json` | Flutter Web PWA metadata. |
| `mobile/android/gradle.properties` | Memory-bounded Gradle settings used in the sandbox. |
| `.github/workflows/deploy-web.yml` | Flutter Web build and Pages publisher. |
| `docs/PROJECT_DOCUMENTATION.md` | Detailed implementation and operations guide. |
| `docs/DOCUMENTATION_AUDIT.md` | Current documentation-to-source verification. |

## 5. Build and validation commands

### Flutter Web

```bash
cd /home/ubuntu/powerlines-10-day-prototype/mobile
flutter config --enable-web
flutter pub get
flutter analyze
flutter build web --release
```

The GitHub Actions build adds the project-site base path:

```bash
flutter build web --release --base-href "/powerlines-10-day-prototype/"
```

The base path must remain aligned with the repository name. A correct build can still appear broken on GitHub Pages if the base href points to `/` instead of `/powerlines-10-day-prototype/`.

### Android

```bash
cd /home/ubuntu/powerlines-10-day-prototype/mobile
flutter build apk --release --split-per-abi
```

For the constrained sandbox fallback:

```bash
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export GRADLE_OPTS='-Xmx1200m -XX:MaxMetaspaceSize=512m -XX:ReservedCodeCacheSize=192m'
flutter build apk --release --target-platform android-arm64
cp build/app/outputs/flutter-apk/app-release.apk \
  build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

The fallback is not a successful all-ABI build. It is an ARM64-only release package. Verify the output is non-empty and contains `lib/arm64-v8a/`.

### React/Web

```bash
cd /home/ubuntu/powerlines-10-day-prototype
pnpm install
pnpm test
pnpm build
```

Use the current `package.json` scripts as the source of truth. If the server-backed development script fails, inspect `.manus-logs/` and dependency resolution before changing frontend code.

## 6. Deployment and release handoff

### GitHub Pages

The Flutter workflow triggers on pushes to `manus/flutter-preview` when files under `mobile/**` or the workflow itself change. Documentation-only commits do not trigger the Flutter deployment workflow. It can be run manually through GitHub Actions when a documentation change needs a fresh release check.

The workflow installs the Flutter stable channel, runs `flutter pub get`, builds with `--base-href "/powerlines-10-day-prototype/"`, and publishes `mobile/build/web` to `gh-pages` using `peaceiris/actions-gh-pages@v4`. GitHub Pages must be configured to serve the `gh-pages` branch at repository root.

Verified Flutter Pages URL from the prior release:

`https://samueladewoye.github.io/powerlines-10-day-prototype/`

### Manus preview

The prior release was exposed through a temporary static server at:

`https://4173-ioxah01w0sqfhkj7d2242-5700966c.us2.manus.computer`

This hostname is session-dependent. After a sandbox reset, do not assume it remains active. Rebuild or re-serve `mobile/build/web`, expose the new port, and report the new URL.

### Android distribution

The prior ARM64 APK was verified locally and uploaded to a temporary CDN fallback because `transfer.sh` failed TLS negotiation in the sandbox. Temporary file links are not source control and should not be treated as permanent release hosting. Before distributing a new APK, verify the checksum, architecture, package metadata, and target-device installation.

## 7. Known gotchas for the next agent

| Gotcha | What can go wrong | Correct response |
|---|---|---|
| Branch confusion after sandbox restore | The restored workspace may open on `main` and appear to have no `mobile/` directory. | Fetch and checkout `manus/flutter-preview` before editing. |
| Documentation-only Flutter commit | A documentation push may not trigger the Web workflow because its path filter is `mobile/**` plus the workflow file. | Trigger Actions manually if deployment verification is needed. |
| Flutter SDK absence | A restored sandbox may not retain `/home/ubuntu/flutter/bin/flutter`. | Install/configure Flutter stable again, then verify `flutter --version`; do not claim a new local analysis run without the executable. |
| Flutter Web base path | Pages returns a shell or broken asset URLs. | Keep the workflow `--base-href` equal to `/powerlines-10-day-prototype/`. |
| Generated build output | `mobile/build/` is large and disposable. | Do not commit it; rebuild locally or in Actions. |
| Offline fonts | Removing bundled fonts or enabling runtime fetch creates offline typography failures. | Keep TTF assets registered and runtime fetching disabled. |
| Hive browser state | Clearing browser storage or private browsing makes a reload look like data loss. | Test in a normal profile without clearing site data. |
| Gradle resource limits | Split-ABI Gradle can be killed by the small sandbox. | Use the memory-bounded ARM64 fallback and label the artifact honestly. |
| React full-stack scaffold | The presence of `server/`, `drizzle/`, and OAuth files can invite unnecessary backend work. | Keep current local-first behavior; use backend only for an explicit new requirement. |
| Parity drift | React and Flutter can show different content or stage behavior. | Compare `Home.tsx` and `main.dart` whenever parity is requested. |
| Temporary download URLs | Transfer/CDN links can expire or fail independently of the APK. | Preserve the local artifact, verify it, and create a new release link when needed. |
| Raw Git operations | Pushing to the wrong remote or branch can overwrite unrelated work. | Check `git branch --show-current`, `git remote -v`, `git status --short`, and push the intended branch only. |

## 8. Suggested next actions

The handoff is complete for the current implementation. A future agent should first verify the remote branch and read this file, then choose one of these bounded paths:

| Situation | First action |
|---|---|
| Documentation or maintenance only | Edit `docs/PROJECT_DOCUMENTATION.md`, `docs/DOCUMENTATION_AUDIT.md`, or this file; run `git diff --check`; push `manus/flutter-preview`. |
| Flutter feature request | Add a `todo.md` item, inspect `mobile/lib/main.dart`, implement within the existing offline architecture, run Flutter validation, and update the audit report. |
| React feature request | Stay on `main`, inspect `Home.tsx` and the React dashboard, preserve localStorage behavior, and run pnpm checks. |
| New cross-branch content | Establish the React version as the source text, update Flutter deliberately, then compare routes, labels, and behavior on both branches. |
| New backend or sync requirement | Stop and confirm the requirement. This changes the current offline boundary and needs a separate architecture plan, schema plan, credential review, and tests. |
| New release | Validate Web and Android artifacts, verify Pages source and base href, record exact commit and URLs, and distinguish temporary previews from durable hosting. |

## 9. Completion record

At handoff creation, the audited Flutter documentation is on the `manus/flutter-preview` branch. The prior audit corrected the stale provider wording and confirmed the current route count, state model, storage keys, assets, fonts, streak algorithm, Pages workflow, and Android fallback. This file is intended to be read before any future implementation work so that the next agent does not repeat the branch discovery, architecture audit, or deployment investigation.

## References

[1]: https://github.com/SamuelAdewoye/powerlines-10-day-prototype/tree/main Main branch
[2]: https://github.com/SamuelAdewoye/powerlines-10-day-prototype/tree/manus/flutter-preview Flutter branch
[3]: https://github.com/SamuelAdewoye/powerlines-10-day-prototype/blob/manus/flutter-preview/docs/PROJECT_DOCUMENTATION.md Flutter project documentation
[4]: https://github.com/SamuelAdewoye/powerlines-10-day-prototype/blob/manus/flutter-preview/docs/DOCUMENTATION_AUDIT.md Documentation-to-code audit
[5]: https://docs.github.com/en/pages/getting-started-with-github-pages/creating-a-github-pages-site GitHub Pages documentation
