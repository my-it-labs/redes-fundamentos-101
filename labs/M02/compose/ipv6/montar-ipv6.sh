#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
run() { docker compose exec -T "$1" bash -c "$2"; }

# Las direcciones /64 vienen del compose; el script solo fija rutas por defecto de práctica.
run nodo-v6-a "ip -6 route replace default via 2001:db8:101::1 dev eth0 2>/dev/null || true"
run nodo-v6-b "ip -6 route replace default via 2001:db8:101::1 dev eth0 2>/dev/null || true"

echo "IPv6 de laboratorio listo (::10 y ::20 en la misma /64)."
