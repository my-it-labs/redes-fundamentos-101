#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

run() {
  docker compose exec -T "$1" bash -c "$2"
}

# Sentido horario: a -> b -> c -> d -> a
run nodo-a "ip route add 10.10.2.0/29 via 10.10.1.3; ip route add 10.10.3.0/29 via 10.10.1.3; ip route add 10.10.4.3 via 10.10.1.3"
run nodo-b "ip route add 10.10.3.0/29 via 10.10.2.3; ip route add 10.10.4.0/29 via 10.10.2.3; ip route add 10.10.1.2 via 10.10.2.3"
run nodo-c "ip route add 10.10.4.0/29 via 10.10.3.3; ip route add 10.10.1.0/29 via 10.10.3.3; ip route add 10.10.2.2 via 10.10.3.3"
run nodo-d "ip route add 10.10.1.0/29 via 10.10.4.2; ip route add 10.10.2.0/29 via 10.10.4.2; ip route add 10.10.3.2 via 10.10.4.2"

echo "Rutas del anillo aplicadas."
