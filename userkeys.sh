#!/bin/bash

# Zeitlimits für curl (Sekunden)
CONNECT_TIMEOUT=2
MAX_TIME=2

# Erste URL versuchen
curl -sf --connect-timeout $CONNECT_TIMEOUT --max-time $MAX_TIME \
    https://raw.githubusercontent.com/Hobbabobba/keyserver/refs/heads/main/$1/keys && exit 0

# Falls die erste URL fehlschlägt, zweite URL versuchen
curl -sf --connect-timeout $CONNECT_TIMEOUT --max-time $MAX_TIME \
    https://git.nauheimtech.de/StefanMewes/keyserver/raw/branch/main/$1/keys
