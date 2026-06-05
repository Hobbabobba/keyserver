#!/usr/bin/env bash
set -euo pipefail

[[ $# -eq 1 ]] || { echo "Usage: $0 <username>" >&2; exit 1; }
[[ "$1" =~ ^[a-zA-Z0-9_.-]+$ ]] || { echo "Ungültiger Benutzername: $1" >&2; exit 1; }

CONNECT_TIMEOUT=2
MAX_TIME=2
URLS=(
  "https://git.nauheimtech.de/StefanMewes/keyserver/raw/branch/main/$1/keys"
  "https://raw.githubusercontent.com/Hobbabobba/keyserver/refs/heads/main/$1/keys"
)

pids=()
tmpfiles=()
trap 'rm -f "${tmpfiles[@]:-}"' EXIT

for url in "${URLS[@]}"; do
  tmp=$(mktemp)
  tmpfiles+=("$tmp")
  (
    curl -fsS --connect-timeout "$CONNECT_TIMEOUT" --max-time "$MAX_TIME" \
        "$url" >"$tmp" 2>/dev/null
  ) &
  pids+=($!)
done

remaining=${#pids[@]}
while ((remaining > 0)); do
  wait -n || true
  ((remaining--)) || true
  for tmp in "${tmpfiles[@]}"; do
    if [[ -s "$tmp" ]]; then
      cat "$tmp"
      for pid in "${pids[@]}"; do kill "$pid" 2>/dev/null || true; done
      wait 2>/dev/null || true
      exit 0
    fi
  done
done

echo "❌ Keine Keys abrufbar (URLs: ${URLS[*]})" >&2
exit 1
