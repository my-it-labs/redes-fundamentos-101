#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
run() { docker compose exec -T "$1" bash -c "$2"; }

run pc-ventas "ip route replace default via 10.80.10.254"
run pc-rrhh "ip route replace default via 10.80.20.254"
run router-vlan "ip route add 10.80.20.0/24 via 10.80.20.254 dev eth1; ip route add 10.80.10.0/24 via 10.80.10.254 dev eth0"

echo "Rutas entre VLANs lógicas aplicadas."
