#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
run() { docker compose exec -T "$1" bash -c "$2"; }

run nodo-v6-a "ip -6 addr add 2001:db8:101::10/64 dev eth0; ip -6 route add default via 2001:db8:101::1"
run nodo-v6-b "ip -6 addr add 2001:db8:101::20/64 dev eth0; ip -6 route add default via 2001:db8:101::1"

echo "Direcciones IPv6 de laboratorio aplicadas (ULA/doc)."
