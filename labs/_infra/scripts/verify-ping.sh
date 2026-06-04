#!/usr/bin/env bash
# Uso: verify-ping.sh <servicio-compose> <ip-o-hostname>
set -euo pipefail

SERVICE="${1:?servicio}"
TARGET="${2:?destino}"

docker compose exec -T "$SERVICE" ping -c 2 -W 3 "$TARGET" >/dev/null
echo "OK: ${SERVICE} -> ${TARGET}"
