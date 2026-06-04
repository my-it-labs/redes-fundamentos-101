#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
run() { docker compose exec -T "$1" bash -c "$2"; }

run pc-red-a "ip route replace default via 192.168.100.62"
run pc-red-b "ip route replace default via 192.168.100.126"

echo "Rutas M02 dos-subredes aplicadas."
