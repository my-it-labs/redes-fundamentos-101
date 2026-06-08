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
    done < <(ip route show table main | grep -E "^10\.10\.[0-9]+\.[0-9]+ via ")
  '
}

configurar_host_docker
for n in nodo-a nodo-b nodo-c nodo-d; do
  habilitar_router "$n"
  limpiar_host_routes "$n"
done

run nodo-a "ip route replace 10.10.2.0/29 via 10.10.1.3; ip route replace 10.10.3.0/29 via 10.10.1.3"
run nodo-b "ip route replace 10.10.3.0/29 via 10.10.2.3; ip route replace 10.10.4.0/29 via 10.10.2.3"
run nodo-c "ip route replace 10.10.4.0/29 via 10.10.3.3; ip route replace 10.10.1.0/29 via 10.10.2.2"
run nodo-d "ip route replace 10.10.1.0/29 via 10.10.4.2; ip route replace 10.10.2.0/29 via 10.10.4.2"

fallos=0
for prueba in "nodo-a:10.10.1.3" "nodo-a:10.10.2.3" "nodo-a:10.10.3.2" "nodo-a:10.10.4.3"; do
  o=${prueba%%:*}; d=${prueba##*:}
  if verificar_ping "$o" "$d"; then echo "  OK  $o -> $d"; else echo "  FALLO  $o -> $d"; fallos=$((fallos+1)); fi
done

[[ "$fallos" -eq 0 ]] || { echo "ERROR: ./diagnostico.sh"; exit 1; }
echo "Rutas del anillo aplicadas y verificadas."
