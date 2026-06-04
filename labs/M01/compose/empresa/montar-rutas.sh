#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

run() {
  docker compose exec -T "$1" bash -c "$2"
}

run pc-oficina "ip route replace default via 192.168.10.254"
run pc-sucursal-1 "ip route replace default via 192.168.20.254"
run pc-sucursal-2 "ip route replace default via 192.168.30.254"

run gw-oficina "ip route add 192.168.20.0/24 via 10.255.0.12; ip route add 192.168.30.0/24 via 10.255.0.13"
run gw-sucursal-1 "ip route add 192.168.10.0/24 via 10.255.0.11; ip route add 192.168.30.0/24 via 10.255.0.13"
run gw-sucursal-2 "ip route add 192.168.10.0/24 via 10.255.0.11; ip route add 192.168.20.0/24 via 10.255.0.12"

echo "Rutas empresa aplicadas."
