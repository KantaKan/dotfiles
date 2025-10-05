#!/usr/bin/env bash

set -euo pipefail

ACTION=${1:-status}

print_json() {
  local icon="$1"; shift
  local tooltip="$1"; shift
  local class="$1"; shift
  printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' "$icon" "$tooltip" "$class"
}

get_pamix_id() {
  # Prefer default source; fallback to first source
  if pactl info >/dev/null 2>&1; then
    local def
    def=$(pactl info | awk -F": " '/Default Source:/{print $2}')
    if [[ -n "${def}" ]]; then
      pactl list sources short | awk -v d="$def" '$2==d {print $1; found=1} END{ if(!found) exit 1 }' || true
    fi
    if [[ -z "${def}" ]]; then
      pactl list sources short | awk 'NR==1{print $1}'
    fi
  fi
}

get_muted() {
  # Try PulseAudio/PipeWire via pactl
  if pactl list sources >/dev/null 2>&1; then
    local def
    def=$(pactl info | awk -F": " '/Default Source:/{print $2}')
    if [[ -n "$def" ]]; then
      pactl list sources | awk -v d="$def" 'BEGIN{RS="Source #"} $0 ~ d { if($0 ~ /Mute:\s+yes/) print "yes"; else print "no" }'
      return
    fi
  fi
  # Fallback to arecord busy detection (heuristic)
  if fuser -v /dev/snd/* 2>/dev/null | grep -q "F....M"; then
    echo "no"
  else
    echo "yes"
  fi
}

toggle_mic() {
  if command -v pactl >/dev/null 2>&1; then
    local src
    src=$(get_pamix_id || true)
    if [[ -n "${src:-}" ]]; then
      pactl set-source-mute "$src" toggle
      return 0
    fi
    # If no id, try default
    pactl set-source-mute @DEFAULT_SOURCE@ toggle 2>/dev/null || true
  fi
  return 0
}

status() {
  local muted
  muted=$(get_muted)
  if [[ "$muted" == "yes" ]]; then
    print_json "🔇" "Microphone muted" "muted"
  else
    print_json "🎤" "Microphone active" "active"
  fi
}

case "$ACTION" in
  toggle)
    toggle_mic
    ;;
  *) ;;
esac

status


