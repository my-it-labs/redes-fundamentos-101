#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
source "$(dirname "$0")/../../../_infra/scripts/montar-lib.sh"

limpiar_host_routes() {
  local nodo=$1
  run "$nodo" '
    while read -r line; do
      dst=$(echo "$line" | awk "{print \$1}")
      gw=$(echo "$line" | awk "{print \$3}")
      iface=$(echo "$line" | awk "{print \$5}")
      ip route del "$dst" via "$gw" dev "$iface" 2>/dev/null || true
    done < <(ip route show table main | grep -E "^10\.20\.[0-9]+\.[0-9]+ via ")
  '
}

configurar_host_docker
for n in sede-1 sede-2 sede-3; do
  habilitar_router "$n"
  limpiar_host_routes "$n"
done

run sede-1 "ip route replace 10.20.2.0/29 via 10.20.1.3"
run sede-3 "ip route replace 10.20.1.0/29 via 10.20.3.2"

fallos=0
for prueba in "sede-1:10.20.2.3" "sede-1:10.20.3.3" "sede-2:10.20.1.2"; do
  o=${prueba%%:*}; d=${prueba##*:}
  if verificar_ping "$o" "$d"; then echo "  OK  $o -> $d"; else echo "  FALLO  $o -> $d"; fallos=$((fallos+1)); fi
done

[[ "$fallos" -eq 0 ]] || exit 1
echo "Rutas de la malla (triángulo) aplicadas y verificadas."
