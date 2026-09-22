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

tmpdir=$(mktemp -d)
pids=()
trap 'kill "${pids[@]}" 2>/dev/null || true; rm -rf "$tmpdir"' EXIT

# Jeder Download schreibt in eine .part-Datei, die erst nach erfolgreichem curl
# umbenannt wird – so wird nie eine noch laufende oder abgebrochene Teilantwort ausgeliefert.
for i in "${!URLS[@]}"; do
  (
    curl -fsS --connect-timeout "$CONNECT_TIMEOUT" --max-time "$MAX_TIME" \
        "${URLS[$i]}" >"$tmpdir/$i.part" 2>/dev/null \
      && mv "$tmpdir/$i.part" "$tmpdir/$i.ok" 2>/dev/null
  ) &
  pids+=($!)
done

# Nur Antworten mit mindestens einer Key-Zeile zählen (keine Fehler-/HTML-Seiten)
is_keyfile() {
  grep -Eq '^(ssh-|ecdsa-|sk-)' "$1"
}

remaining=${#pids[@]}
while ((remaining > 0)); do
  wait -n || true
  ((remaining--)) || true
  # Reihenfolge in URLS = Priorität, falls mehrere gleichzeitig fertig sind
  for i in "${!URLS[@]}"; do
    ok="$tmpdir/$i.ok"
    if [[ -f "$ok" ]] && is_keyfile "$ok"; then
      cat "$ok"
      exit 0
    fi
  done
done

echo "❌ Keine Keys abrufbar (URLs: ${URLS[*]})" >&2
exit 1
