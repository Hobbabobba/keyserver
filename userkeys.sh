#!/usr/bin/env bash
set -euo pipefail

# Konfiguration
CONNECT_TIMEOUT=2
MAX_TIME=2

URLS=(
  "https://git.nauheimtech.de/StefanMewes/keyserver/raw/branch/main/$1/keys"
  "https://raw.githubusercontent.com/Hobbabobba/keyserver/refs/heads/main/$1/keys"
)

pids=()
tmpfiles=()

# Curl-Requests parallel starten, Output in Tempfiles
for url in "${URLS[@]}"; do
  tmp=$(mktemp)
  tmpfiles+=("$tmp")
  (
    if curl -fsS --connect-timeout "$CONNECT_TIMEOUT" --max-time "$MAX_TIME" \
        "$url" >"$tmp" 2>/dev/null; then
      echo "$tmp"  # signalisiert Erfolg
    fi
  ) &
  pids+=($!)
done

# Auf den ersten erfolgreichen Job warten
while ((${#pids[@]})); do
  if wait -n; then
    # Erfolgreichen Output suchen
    for tmp in "${tmpfiles[@]}"; do
      if [[ -s "$tmp" ]]; then
        cat "$tmp"
        rm -f "${tmpfiles[@]}"
        # Restprozesse beenden & aufräumen
        for pid in "${pids[@]}"; do kill "$pid" 2>/dev/null || true; done
        wait || true
        exit 0
      fi
    done
  fi
done

# Falls keiner erfolgreich war
rm -f "${tmpfiles[@]}"
echo "❌ Keine Keys abrufbar (URLs: ${URLS[*]})" >&2
exit 1
