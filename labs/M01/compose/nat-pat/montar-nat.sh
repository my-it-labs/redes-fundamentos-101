#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

run() {
  docker compose exec -T "$1" bash -c "$2"
}

run gateway-nat "iptables -t nat -A POSTROUTING -s 10.200.1.0/24 -j MASQUERADE"
run cliente-1 "ip route replace default via 10.200.1.254"
run cliente-2 "ip route replace default via 10.200.1.254"

echo "PAT (MASQUERADE) activo en gateway-nat."
