#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

run() {
  docker compose exec -T "$1" bash -c "$2"
}

run sede-1 "ip route add 10.20.2.0/29 via 10.20.1.3; ip route add 10.20.2.3 via 10.20.1.3; ip route add 10.20.3.3 via 10.20.3.1"
run sede-2 "ip route add 10.20.3.0/29 via 10.20.2.3; ip route add 10.20.3.3 via 10.20.2.3; ip route add 10.20.1.2 via 10.20.2.3"
run sede-3 "ip route add 10.20.1.0/29 via 10.20.3.2; ip route add 10.20.1.2 via 10.20.3.2; ip route add 10.20.1.3 via 10.20.2.2"

echo "Rutas de la malla (triángulo) aplicadas."
