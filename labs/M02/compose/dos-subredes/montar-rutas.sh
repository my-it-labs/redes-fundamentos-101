#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
source "$(dirname "$0")/../../../_infra/scripts/montar-lib.sh"

configurar_host_docker
habilitar_router router

run pc-red-a "ip route replace default via 192.168.100.62"
run pc-red-b "ip route replace default via 192.168.100.126"

verificar_ping pc-red-a 192.168.100.74 && verificar_ping pc-red-b 192.168.100.10 || exit 1
echo "Rutas M02 dos-subredes aplicadas y verificadas."
