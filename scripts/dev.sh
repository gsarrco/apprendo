#!/usr/bin/env bash
set -euo pipefail

REPO=$(cd "$(dirname "$0")/.." && pwd)
ADB_BIN="${ANDROID_HOME:-$HOME/Android/Sdk}/platform-tools/adb"
APK="$REPO/build/app/outputs/flutter-apk/app-debug.apk"
APP_ID="study.apprendo.debug"
LAUNCH_COMPONENT="$APP_ID/study.apprendo.android.MainActivity"
FIND_TIMEOUT="${FIND_TIMEOUT:-10}"
BUILD_LOG="$REPO/build/dev-build.log"
INSTALL_LOG="$REPO/build/dev-install.log"

T0=$SECONDS
STEP=0
TOTAL=0
STEP_T0=0
DEVICE=""

usage() {
  cat <<EOF
Usage: scripts/dev.sh [command]

Commands:
  up        (default) find a Wi-Fi debugging device, build the debug APK, install and launch
  build     build the debug APK only
  status    list visible Wi-Fi debugging devices and the app state
  logs      follow Flutter logs from the app on the device

The phone must have Wireless debugging enabled (Settings -> Developer
options -> Wireless debugging) and be paired to this computer at least
once: adb pair <ip:port> <code>. Paired devices are discovered
automatically over mDNS while the script listens.

Environment:
  FIND_TIMEOUT  seconds to listen for a device before failing (default 10)
  SEED_DEMO     seed demo data when the database is empty (default true)
  VERBOSE=1     stream full build output instead of logging to files
EOF
}

die() { echo "ERROR: $*" >&2; exit 1; }
fmt_t() { local s=$1; if [ "$s" -ge 60 ]; then printf '%dm%02ds' $((s / 60)) $((s % 60)); else printf '%ds' "$s"; fi; }

check_env() {
  command -v flutter > /dev/null || die "flutter not on PATH (see ~/.bashrc.d/dev-tools.sh)"
  [ -n "${JAVA_HOME:-}" ] || die "JAVA_HOME not set (see ~/.bashrc.d/dev-tools.sh)"
  [ -x "$ADB_BIN" ] || die "adb not found at $ADB_BIN (set ANDROID_HOME)"
}

adb() { "$ADB_BIN" -s "$DEVICE" "$@"; }

wireless_devices() {
  "$ADB_BIN" devices | awk -F'\t' '$2 == "device" && $1 ~ /:[0-9]+$|_adb-tls/ {print $1}'
}

step_begin() {
  STEP=$1
  printf '[%d/%d] %s... ' "$STEP" "$TOTAL" "$2"
  STEP_T0=$SECONDS
}

step_done() {
  printf 'done in %s\n' "$(fmt_t $((SECONDS - STEP_T0)))"
}

step_fail() {
  printf 'FAILED\n'
  if [ $# -gt 0 ] && [ "$1" != /dev/null ]; then tail -5 "$1" >&2; fi
  die "step failed${1:+ — last lines above, full log: $1}"
}

run_logged() {
  local log=$1
  shift
  if [ "${VERBOSE:-0}" = 1 ]; then "$@"; else "$@" > "$log" 2>&1; fi
}

device_online() {
  [ -n "$DEVICE" ] && [ "$("$ADB_BIN" -s "$DEVICE" get-state 2> /dev/null)" = "device" ]
}

find_device() {
  "$ADB_BIN" start-server > /dev/null 2>&1 || true
  local t0=$SECONDS
  while :; do
    DEVICE=$(wireless_devices | head -n 1)
    if [ -n "$DEVICE" ]; then
      printf 'found %s\n' "$DEVICE"
      return 0
    fi
    if [ $((SECONDS - t0)) -ge "$FIND_TIMEOUT" ]; then
      printf 'none\n'
      die "no Android device in Wi-Fi debugging mode found after ${FIND_TIMEOUT}s — enable Wireless debugging (Settings -> Developer options -> Wireless debugging), pair your phone once with 'adb pair <ip:port> <code>', make sure it is on the same network as this computer, and accept the debugging prompt on the phone"
    fi
    printf '.'
    sleep 1
  done
}

build_apk() {
  mkdir -p "$REPO/build"
  step_begin "$1" "Building debug APK (arm64, $APP_ID, SEED_DEMO=${SEED_DEMO:-true})"
  run_logged "$BUILD_LOG" sh -c "cd '$REPO' && flutter build apk --debug --target-platform=android-arm64 --dart-define=SEED_DEMO=${SEED_DEMO:-true}" \
    || step_fail "$BUILD_LOG"
  step_done
}

install_app() {
  if ! device_online; then
    printf 'device lost during the build — listening again\n'
    find_device
  fi
  step_begin "$1" "Installing APK on $DEVICE"
  run_logged "$INSTALL_LOG" adb install -r -d "$APK" || step_fail "$INSTALL_LOG"
  adb shell input keyevent KEYCODE_WAKEUP > /dev/null 2>&1 || true
  adb shell wm dismiss-keyguard > /dev/null 2>&1 || true
  adb shell am start -n "$LAUNCH_COMPONENT" > /dev/null 2>&1 \
    || adb shell monkey -p "$APP_ID" -c android.intent.category.LAUNCHER 1 > /dev/null 2>&1 \
    || true
  step_done
}

cmd_build() { check_env; TOTAL=1; build_apk 1; }

cmd_up() {
  check_env
  TOTAL=3
  step_begin 1 "Listening for Wi-Fi debugging devices (up to ${FIND_TIMEOUT}s)"
  find_device
  step_done
  build_apk 2
  install_app 3
  printf '\nDone in %s.\n' "$(fmt_t $((SECONDS - T0)))"
  echo "Logs: scripts/dev.sh logs"
}

cmd_status() {
  local out pid
  "$ADB_BIN" start-server > /dev/null 2>&1 || true
  out=$("$ADB_BIN" devices | awk -F'\t' 'NR > 1 && $1 ~ /:[0-9]+$|_adb-tls/ {printf "  %-45s %s\n", $1, $2}')
  if [ -z "$out" ]; then
    echo "wi-fi debugging devices: none visible"
    echo "enable Wireless debugging on the phone and pair once with: adb pair <ip:port> <code>"
    return 0
  fi
  echo "wi-fi debugging devices:"
  echo "$out"
  DEVICE=$(printf '%s\n' "$out" | awk '$2 == "device" {print $1; exit}')
  if [ -z "$DEVICE" ]; then
    echo "app ($APP_ID): cannot check (no device online)"
    return 0
  fi
  pid=$(adb shell pidof "$APP_ID" 2> /dev/null | tr -d '[:space:]')
  if [ -n "$pid" ]; then
    echo "app ($APP_ID): running (pid $pid)"
  else
    echo "app ($APP_ID): not running"
  fi
}

cmd_logs() {
  [ -x "$ADB_BIN" ] || die "adb not found at $ADB_BIN (set ANDROID_HOME)"
  if ! device_online; then
    printf 'Looking for a Wi-Fi debugging device (up to %ss)... ' "$FIND_TIMEOUT"
    find_device
  fi
  adb logcat -s flutter
}

case "${1:-up}" in
  up) cmd_up ;;
  build) cmd_build ;;
  status) cmd_status ;;
  logs) cmd_logs ;;
  -h|--help|help) usage ;;
  *) usage; die "unknown command: $1" ;;
esac
