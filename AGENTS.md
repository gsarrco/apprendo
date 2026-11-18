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

## Device and dev workflow

Development runs on a physical Android phone over Wi-Fi (wireless)
debugging — there is no emulator on this machine. `scripts/dev.sh`
listens for wireless-debugging devices for up to 10 seconds
(`FIND_TIMEOUT`), takes the first one found, builds the debug APK
(arm64, applicationId `study.apprendo.debug`, demo data seeded via the
`SEED_DEMO` dart-define, default true), and installs and launches it on
that device. If no device appears within the timeout it fails with the
reason. The phone must have Wireless debugging enabled and have been
paired to this computer once (`adb pair <ip:port> <code>`);
paired devices are discovered automatically over mDNS.

```bash
scripts/dev.sh        # find device + build + install + launch
scripts/dev.sh build  # build the debug APK only
scripts/dev.sh status # list wireless-debugging devices + app state
scripts/dev.sh logs   # follow Flutter logs from the phone
```

## Data layer (Drift)

- Schema lives in `lib/data/tables.dart`; `database.g.dart` is
  **generated** by build_runner — never hand-edit it. After changing the
  schema run:

    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```

- `schemaVersion` is 2 (v1→v2 migrated attachments to raw bytes and
  dropped the per-deck "save attachments" flag); future schema changes
  must bump it and add migrations.
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
- Export/import uses the `apprendo-export` v2 format
  (`lib/export/export_file.dart`): attachments carry raw bytes only
  (`mime_type` + base64 `content`); there is no url field, and the format
  is not compatible with the original web app's v1 files (url-only
  attachments are skipped on import). The encoder/decoder round-trip and
  the old fixtures (`test/fixtures/web_*.json`) exercise both paths.

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
- Release/profile builds need `gen_snapshot` (AOT compiler), which
  Flutter does not ship for linux-arm64 hosts. A wrapper script at
  `~/flutter-sdk/bin/cache/artifacts/engine/android-arm64-release/linux-arm64/gen_snapshot`
  runs the x86-64 binary via `qemu-x86_64 -L ~/x86-sysroot` (a minimal
  x86-64 glibc sysroot). FEX cannot run it: gen_snapshot's bundled
  jemalloc aborts on the host's 16 KB page size. A Flutter SDK upgrade
  wipes the wrapper — recreate it after upgrading.
- If a release APK suddenly balloons from ~21 MB to ~180 MB, the NDK's
  `llvm-strip` symlink was reset by an NDK upgrade (the x86-64 binary
  fails silently under FEX, so AGP packages `libflutter.so` unstripped —
  the Flutter 3.50.0 release engine ships with ~158 MB of DWARF debug
  info). Fix: relink
  `~/Android/Sdk/ndk/<version>/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-strip`
  to `/usr/bin/llvm-strip`, delete
  `build/app/intermediates/stripped_native_libs`, and rebuild.

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
- `scripts/dev.sh` — device discovery + build + install workflow.
