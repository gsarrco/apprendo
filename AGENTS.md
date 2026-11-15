# AGENTS.md

## Tech stack

Flutter + Dart, targeting Android. UI is **Material 3** via the
`material_ui` package. Data layer is **Drift** (relational SQLite) with
reactive query streams. Spaced repetition is a direct Dart port of
`ts-fsrs` 5.4.1 in `lib/fsrs/fsrs.dart` — do not swap it for the `fsrs`
pub package; exact parity with the original algorithm is the contract.

## Required checks

Always run the following before considering work done. Fix any errors.
Both finish in seconds.

```bash
flutter analyze && flutter test
```

The user wants tests fast: never introduce long-running tests or
hardcoded multi-minute timeouts. The FSRS golden test
(`test/fsrs_golden_test.dart`) compares against vectors generated from
the real `ts-fsrs` (`test/fixtures/golden.json`) — if a test and the
implementation disagree, the **web app in git history is the behavioral
spec**: fix whichever deviates from it, never just make red tests green.

## Emulator and dev workflow

`scripts/dev.sh` builds the debug APK, boots the Android 17 Cuttlefish
emulator (QEMU/KVM, arm64) if needed, installs and launches the app, and
opens a VNC window (the WebRTC operator UI cannot show video — its frame
source is crosvm-only; use the VNC viewer at `localhost:6444`).

```bash
scripts/dev.sh        # build + boot if needed + install + open screen
scripts/dev.sh down   # graceful stop, app data is kept
scripts/dev.sh status # state of emulator / adb / app
```

The script applies two required host-side patches at boot (RIL fields in
the cuttlefish config, `androidboot.boot_devices` in the bootconfig). If
the emulator fails to boot, read `~/Android/cf/work/run_cvd.out` and
`cuttlefish/instances/cvd-1/kernel.log` — do not remove those patches.

## Data layer (Drift)

- Schema lives in `lib/data/tables.dart`; `database.g.dart` is
  **generated** by build_runner — never hand-edit it. After changing the
  schema run:

    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```

- `schemaVersion` is 1 with an `onUpgrade` scaffold; future schema
  changes must bump it and add migrations.
- `AppDatabase` is a singleton via the `appDb` getter in `lib/app.dart`.
  Never construct `AppDatabase` directly outside tests — drift warns
  about two instances sharing one file (race/corruption risk).
- Drift `watch` streams are cached as broadcast streams inside
  `AppDatabase`. Do not create new streams per `build`, and do not
  `.map()` cached streams per build (causes infinite rebuild loops) —
  transform inside a `StreamBuilder`/builder instead.
- `ReviewLogs` intentionally has **no foreign key** to cards (matches
  the web app: review history survives card deletion).

## Domain conventions

- The domain `Card` model is named `CardDoc` (`lib/domain/models.dart`)
  to avoid clashing with Flutter's `Card` widget.
- Dates crossing the FSRS boundary are ISO-8601 UTC strings via
  `toIsoUtc`/`parseIso` (`lib/fsrs/mappers.dart`).
- Export/import must stay byte-compatible with `apprendo-export` v1
  (`lib/export/export_file.dart`). The encoder/decoder round-trip and
  the web app's fixtures (`test/fixtures/web_*.json`) are the spec.

## Style

- Material 3 widgets from `material_ui`; icons from Flutter's `Icons`
  class. No custom font/icon work.
- Color palette: indigo accent. State colors: amber (learning), emerald
  (review/ok), red (relearning/again).
- Do not add comments unless explicitly requested.
- Do not commit machine-local config: `android/local.properties`,
  keystores, or the aapt2 override (that lives in
  `~/.gradle/gradle.properties`).

## ARM64 Linux host quirks

- `path_provider_android` is pinned to `2.2.23` (2.3.x pulls `jni`,
  whose CMake build cannot run on ARM64 hosts). Keep the pin.
- Gradle needs JDK 25 (`~/.jdk/jdk-25.0.5+8`); env vars are set in
  `~/.bashrc.d/dev-tools.sh`.
- If Gradle fails with an aapt2 exec error, check
  `~/.gradle/gradle.properties` still has `android.aapt2FromMavenOverride`
  pointing at the native build-tools aapt2.

## Project layout

- `lib/main.dart` — entry point; `SEED_DEMO` seeds demo data when the
  database is empty (dev builds only).
- `lib/app.dart` — app widget, routes, `appDb` singleton.
- `lib/data/` — Drift tables, database, generated code.
- `lib/domain/` — domain models.
- `lib/fsrs/` — FSRS port + mappers.
- `lib/export/` — export/import format.
- `lib/services/` — Commons API, languages, audio, offline attachments.
- `lib/ui/` — pages and widgets (one feature per file).
- `test/` — golden/DB/format/widget tests.
- `scripts/dev.sh` — emulator + build workflow.
