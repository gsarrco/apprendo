# Apprendo

Apprendo is an offline-first language-learning flashcard app for Android.
It pulls images and native-speaker pronunciation straight from Wikimedia
Commons to build the front and back of your cards, schedules reviews with
spaced repetition, and lets you study multiple decks in a single session.

Built with Flutter, with a relational SQLite database (Drift) and a
native Material 3 UI.

## Features

- 🖼️ **Auto-illustrated cards** — fetches images and audio pronunciation
  from Wikimedia Commons.
- 📴 **Fully offline** — all data lives on-device in SQLite; attachments
  can be downloaded for offline use.
- 🧠 **FSRS scheduling** — reviews are timed by the FSRS
  (Free Spaced Repetition Scheduler) algorithm, a modern algorithm that
  models each card's difficulty and memory stability to predict the exact
  moment you're about to forget it. It's the same algorithm available as
  an official (opt-in) scheduler option in Anki.
- 📚 **Multi-deck sessions** — study several decks together in one
  sitting.
- 🏷️ **Study tags** — group decks into study sessions by tag.
- 📤 **Export/import** — portable `apprendo-export` v1 JSON archives,
  byte-compatible with the archives of the previous web app.

## Architecture

- **Framework**: Flutter (Dart), Material 3 via `material_ui`.
- **Data layer**: [Drift](https://drift.simonbinder.eu) over SQLite
  (`lib/data/`), with reactive query streams for the UI.
- **Scheduling**: FSRS ported directly from `ts-fsrs` 5.4.1
  (`lib/fsrs/`), verified against golden vectors generated from the
  original TypeScript implementation.
- **Media**: Wikimedia Commons API client (`lib/services/commons_api.dart`),
  offline attachment storage, `just_audio` playback.

Project layout:

```
lib/main.dart         Entry point (demo data seeding via SEED_DEMO)
lib/app.dart          App widget + appDb singleton
lib/data/             Drift schema, database, generated code
lib/domain/           Domain models (Deck, CardDoc, …)
lib/fsrs/             FSRS scheduler port + date mappers
lib/export/           apprendo-export v1 encode/parse/restore
lib/services/         Commons API, languages, audio, offline storage
lib/seed/             Demo data for development builds
lib/ui/               Pages and widgets (one feature per file)
test/                 Unit, database, export-round-trip and widget tests
scripts/dev.sh        Device + build + install workflow
```

## Getting started

Requires the Flutter SDK, a JDK (Gradle), and the Android SDK, all on
`PATH` (with `JAVA_HOME` and `ANDROID_HOME` set).

```bash
flutter pub get
flutter analyze
flutter test
```

## Development workflow

`scripts/dev.sh` is the one-command loop for this repo. It listens for
Android phones in Wi-Fi debugging mode for up to 10 seconds, takes the
first one it finds, builds the debug APK (applicationId
`study.apprendo.debug`, demo data seeded when the database is empty),
and installs and launches it on the device:

```bash
scripts/dev.sh            # find device + build + install + launch
scripts/dev.sh status      # list wireless-debugging devices / app state
scripts/dev.sh logs        # follow Flutter logs from the app
```

The phone needs Wireless debugging enabled (Settings → Developer
options → Wireless debugging) and must be paired to this computer
once — under Wireless debugging → *Pair device with pairing code*:

```bash
adb pair <ip:port> <code>
```

After pairing, the device is discovered automatically over mDNS
whenever it is on the same network with Wireless debugging on. If no
device shows up within 10 seconds, the script fails and says why.

## Building the APK

```bash
flutter build apk --release --target-platform=android-arm64
```

Debug builds with demo data (seeds only if the database is empty):

```bash
flutter build apk --debug --target-platform=android-arm64 --dart-define=SEED_DEMO=true
```

### ARM64 Linux hosts

Building on an ARM64 Linux host needs two quirks, configured via
`~/.gradle/gradle.properties`:

- `android.aapt2FromMavenOverride` in `~/.gradle/gradle.properties`
  pointing at a native aapt2 — the aapt2 AGP fetches from Maven is
  x86-64 only.
- `path_provider_android` is pinned to 2.2.23 in `pubspec.yaml`; 2.3.x
  pulls in the `jni` package, whose native CMake build cannot run on
  ARM64 hosts.

## Export format

Exports are `apprendo-export` v1 JSON archives (decks, cards, review
logs, study tags, attachments). They are byte-compatible with the
archives produced by the previous web app, so data moves freely between
the two. Round-trip compatibility is enforced by tests in
`test/database_test.dart` and `test/format_test.dart`.

## License

MIT — see [LICENSE](LICENSE).
