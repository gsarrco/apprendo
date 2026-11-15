#!/usr/bin/env bash
set -euo pipefail

CF_HOME="$HOME/Android/cf/work"
CF_BIN="$CF_HOME/bin"
REPO=$(cd "$(dirname "$0")/.." && pwd)
ADB_BIN="${ANDROID_HOME:-$HOME/Android/Sdk}/platform-tools/adb"
adb() { "$ADB_BIN" -s 0.0.0.0:6520 "$@"; }
APK="$REPO/build/app/outputs/flutter-apk/app-debug.apk"
APP_ID="study.apprendo.apprendo"
INSTANCE_DIR="$CF_HOME/cuttlefish/instances/cvd-1"
BOOT_TIMEOUT="${BOOT_TIMEOUT:-300}"
BUILD_LOG="$REPO/build/dev-build.log"
BAR_W=24

T0=$SECONDS
STEP=0
TOTAL=0

usage() {
  cat <<EOF
Usage: scripts/dev.sh [command]

Commands:
  up        (default) build debug APK, boot the emulator if needed, install and launch the app
  build     build the debug APK only
  down      stop the emulator gracefully (app data is kept)
  restart   down + up
  status    show emulator and app state
  vnc       open a VNC viewer on the emulator screen
  logs      follow Flutter logs from the app

Set VERBOSE=1 to stream full build/emulator output instead of the progress display.
EOF
}

die() { echo "ERROR: $*" >&2; exit 1; }
fmt_t() { local s=$1; if [ "$s" -ge 60 ]; then printf '%dm%02ds' $((s / 60)) $((s % 60)); else printf '%ds' "$s"; fi; }

check_env() {
  command -v flutter > /dev/null || die "flutter not on PATH (see ~/.bashrc.d/dev-tools.sh)"
  [ -n "${JAVA_HOME:-}" ] || die "JAVA_HOME not set (see ~/.bashrc.d/dev-tools.sh)"
  [ -d "$CF_HOME" ] || die "$CF_HOME missing — the Cuttlefish Android 17 image is not installed"
  sg cvdnetwork -c true 2> /dev/null || die "user not in cvdnetwork group (sudo usermod -aG cvdnetwork \$USER)"
}

is_running() {
  pgrep -f "$CF_BIN/run_cvd" > /dev/null 2>&1
}

adb_online() {
  [ "$(adb get-state 2> /dev/null)" = "device" ]
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
  if [ $# -gt 0 ]; then tail -5 "$1" >&2; fi
  die "step failed${1:+ — last lines above, full log: $1}"
}

run_logged() {
  local log=$1
  shift
  if [ "${VERBOSE:-0}" = 1 ]; then "$@"; else "$@" > "$log" 2>&1; fi
}

boot_label() { printf '[%d/%d] Waiting for Android boot' "$STEP" "$TOTAL"; }

wait_boot() {
  local t0=$SECONDS est=90 seen=0 elapsed fill rest
  while :; do
    elapsed=$((SECONDS - t0))
    if grep -q "Kernel panic" "$INSTANCE_DIR/kernel.log" 2> /dev/null; then
      printf '\n'
      die "guest kernel panicked — see $INSTANCE_DIR/kernel.log"
    fi
    if is_running; then
      seen=1
    elif [ "$seen" = 1 ]; then
      printf '\n'
      die "run_cvd exited during boot — see $CF_HOME/run_cvd.out"
    fi
    if adb_online && [ "$(adb shell getprop sys.boot_completed 2> /dev/null | tr -d '[:space:]')" = "1" ]; then
      printf '\r%s — done in %s%*s\n' "$(boot_label)" "$(fmt_t "$elapsed")" 30 ''
      return 0
    fi
    if [ "$elapsed" -ge "$BOOT_TIMEOUT" ]; then
      printf '\n'
      die "boot did not complete within ${BOOT_TIMEOUT}s"
    fi
    fill=$(( elapsed * BAR_W / est ))
    [ "$fill" -gt "$BAR_W" ] && fill=$BAR_W
    rest=$(( BAR_W - fill ))
    printf '\r%s  [%s%s] %s / est %s%*s' "$(boot_label)" \
      "$(printf '%*s' "$fill" '' | tr ' ' '#')" "$(printf '%*s' "$rest" '' | tr ' ' '.')" \
      "$(fmt_t "$elapsed")" "$(fmt_t "$est")" 3 ''
    sleep 5
  done
}

kill_stale() {
  pkill -9 -f "$CF_BIN/" 2> /dev/null || true
  sleep 2
  for port in 6520 6600 7300 7500 8443 9600; do
    fuser -k "$port/tcp" 2> /dev/null || true
  done
  sleep 1
}

clean_state() {
  rm -rf "$CF_HOME/cuttlefish" "$CF_HOME/.cuttlefish_config.json" \
    "$CF_HOME/cuttlefish_assembly" "$CF_HOME/cuttlefish_runtime"* \
    "$CF_HOME"/*.lock /tmp/cf_avd_1000 /tmp/cf_env_1000 2> /dev/null || true
}

patch_ril() {
  python3 - "$@" <<'EOF'
import json, sys
ril = {
    'ril_ipaddr': '10.0.2.15',
    'ril_prefixlen': 24,
    'ril_gateway': '10.0.2.2',
    'ril_dns': '8.8.8.8',
    'ril_broadcast': '10.0.2.255',
}
for p in sys.argv[1:]:
    cfg = json.load(open(p))
    insts = cfg['instances']
    inst = insts[0] if isinstance(insts, list) else list(insts.values())[0]
    inst.update(ril)
    json.dump(cfg, open(p, 'w'), indent=2)
EOF
}

build_apk() {
  mkdir -p "$REPO/build"
  step_begin "$1" "Building debug APK (arm64)"
  run_logged "$BUILD_LOG" sh -c "cd '$REPO' && flutter build apk --debug --target-platform=android-arm64 --dart-define=SEED_DEMO=${SEED_DEMO:-true}" \
    || step_fail "$BUILD_LOG"
  step_done
}

boot_emulator() {
  step_begin "$1" "Assembling Android 17 CVD"
  ( cd "$CF_HOME" && HOME="$CF_HOME" timeout 120 sg cvdnetwork -c \
    "$CF_BIN/assemble_cvd --vm_manager=qemu_cli --device_external_network=slirp \
     --report_anonymous_usage_stats=n --console=true --start_webrtc=true \
     --display0=width=1080,height=2400,dpi=431,refresh_rate_hz=60 \
     --extra_bootconfig_args=androidboot.boot_devices=3f000000.pcie" ) \
    > "$CF_HOME/assemble.out" 2>&1 || step_fail "$CF_HOME/assemble.out"
  grep -q "boot_devices=3f000000.pcie" "$INSTANCE_DIR/internal/bootconfig" \
    || die "assemble_cvd ignored --extra_bootconfig_args (bootconfig fix missing)"
  patch_ril "$CF_HOME/cuttlefish/assembly/cuttlefish_config.json" \
    "$INSTANCE_DIR/cuttlefish_config.json"
  step_done
  ( cd "$INSTANCE_DIR" && setsid nohup sg cvdnetwork -c \
    "export HOME=$CF_HOME CUTTLEFISH_INSTANCE=1; exec $CF_BIN/run_cvd" \
    > "$CF_HOME/run_cvd.out" 2>&1 < /dev/null & )
  STEP=$2
  wait_boot
}

install_app() {
  step_begin "$1" "Installing APK"
  run_logged /dev/null adb install -r "$APK" || step_fail
  adb shell input keyevent KEYCODE_WAKEUP > /dev/null 2>&1 || true
  adb shell wm dismiss-keyguard > /dev/null 2>&1 || true
  adb shell am start -n "$APP_ID/.MainActivity" > /dev/null 2>&1
  step_done
}

open_screen() {
  if pgrep -f "vncviewer.*6444" > /dev/null 2>&1; then
    echo "Screen: vncviewer already open (localhost:6444)"
    return
  fi
  if command -v vncviewer > /dev/null && [ -n "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ]; then
    setsid nohup vncviewer -AlertOnFatalError=0 localhost:6444 > /dev/null 2>&1 < /dev/null &
    echo "Screen: opened vncviewer (localhost:6444)"
  else
    echo "Screen: run 'vncviewer localhost:6444' to see the device"
  fi
}

cmd_build() { check_env; TOTAL=1; build_apk 1; }

cmd_up() {
  check_env
  TOTAL=4
  build_apk 1
  if is_running; then
    step_begin 2 "Emulator already running"
    step_done
    STEP=3
    wait_boot
  else
    kill_stale
    clean_state
    boot_emulator 2 3
  fi
  install_app "$TOTAL"
  printf '\nDone in %s.\n' "$(fmt_t $((SECONDS - T0)))"
  open_screen
  echo "Logs: scripts/dev.sh logs   |   Stop: scripts/dev.sh down"
}

cmd_down() {
  if is_running; then
    printf 'Stopping CVD (app data is kept)... '
    HOME="$CF_HOME" "$CF_BIN/cvd_internal_stop" > /dev/null || die "stop failed"
    printf 'done\n'
  else
    echo "emulator not running"
  fi
}

cmd_restart() { cmd_down; cmd_up; }

cmd_status() {
  if is_running; then
    echo "emulator: running"
    if adb_online; then
      echo "adb: online ($(adb shell getprop ro.build.version.release 2>/dev/null | tr -d '[:space:]') / API $(adb shell getprop ro.build.version.sdk 2>/dev/null | tr -d '[:space:]'))"
      pid=$(adb shell pidof "$APP_ID" 2> /dev/null | tr -d '[:space:]')
      if [ -n "$pid" ]; then
        echo "app: running (pid $pid)"
      else
        echo "app: not running"
      fi
    else
      echo "adb: offline (still booting?)"
    fi
    echo "screen: vncviewer localhost:6444"
  else
    echo "emulator: stopped"
  fi
}

cmd_vnc() { command -v vncviewer > /dev/null || die "install tigervnc first"; exec vncviewer localhost:6444; }

cmd_logs() { adb_online || die "emulator not online"; adb logcat -s flutter; }

case "${1:-up}" in
  up) cmd_up ;;
  build) cmd_build ;;
  down) cmd_down ;;
  restart) cmd_restart ;;
  status) cmd_status ;;
  vnc) cmd_vnc ;;
  logs) cmd_logs ;;
  -h|--help|help) usage ;;
  *) usage; die "unknown command: $1" ;;
esac
