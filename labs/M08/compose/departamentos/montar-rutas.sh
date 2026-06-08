#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
source "$(dirname "$0")/../../../_infra/scripts/montar-lib.sh"

configurar_host_docker
habilitar_router router-vlan

run pc-ventas "ip route replace default via 10.80.10.254"
run pc-rrhh "ip route replace default via 10.80.20.254"

verificar_ping pc-ventas 10.80.20.10 && verificar_ping pc-rrhh 10.80.10.10 || exit 1
echo "Rutas entre VLANs lógicas aplicadas y verificadas."
