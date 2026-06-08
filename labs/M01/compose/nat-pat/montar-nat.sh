#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
source "$(dirname "$0")/../../../_infra/scripts/montar-lib.sh"

configurar_host_docker
habilitar_router gateway-nat

run cliente-1 "ip route replace default via 10.200.1.254"
run cliente-2 "ip route replace default via 10.200.1.254"

verificar_ping cliente-1 10.200.100.10 && verificar_ping cliente-2 10.200.100.10 || exit 1
echo "PAT (MASQUERADE) activo en gateway-nat y verificado."
