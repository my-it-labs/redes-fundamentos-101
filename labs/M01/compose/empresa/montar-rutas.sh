#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
source "$(dirname "$0")/../../../_infra/scripts/montar-lib.sh"

configurar_host_docker
for gw in gw-oficina gw-sucursal-1 gw-sucursal-2; do
  habilitar_router "$gw"
done

run pc-oficina "ip route replace default via 192.168.10.254"
run pc-sucursal-1 "ip route replace default via 192.168.20.254"
run pc-sucursal-2 "ip route replace default via 192.168.30.254"

run gw-oficina "ip route replace 192.168.20.0/24 via 10.255.0.12; ip route replace 192.168.30.0/24 via 10.255.0.13"
run gw-sucursal-1 "ip route replace 192.168.10.0/24 via 10.255.0.11; ip route replace 192.168.30.0/24 via 10.255.0.13"
run gw-sucursal-2 "ip route replace 192.168.10.0/24 via 10.255.0.11; ip route replace 192.168.20.0/24 via 10.255.0.12"

fallos=0
for prueba in "pc-oficina:192.168.20.10" "pc-oficina:192.168.30.10" "pc-sucursal-1:192.168.10.10"; do
  o=${prueba%%:*}; d=${prueba##*:}
  if verificar_ping "$o" "$d"; then echo "  OK  $o -> $d"; else echo "  FALLO  $o -> $d"; fallos=$((fallos+1)); fi
done

[[ "$fallos" -eq 0 ]] || exit 1
echo "Rutas empresa aplicadas y verificadas."
