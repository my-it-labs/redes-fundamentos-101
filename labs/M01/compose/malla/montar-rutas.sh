#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

run() {
  docker compose exec -T "$1" bash -c "$2"
}

limpiar_host_routes() {
  local nodo=$1
  run "$nodo" '
    ip route show table main | while read -r dst _ via gw _ dev iface _; do
      [[ "$dst" =~ ^10\.20\.[0-9]+\.[0-9]+$ ]] || continue
      ip route del "$dst" via "$gw" dev "$iface" 2>/dev/null || true
    done
  '
}

for n in sede-1 sede-2 sede-3; do
  limpiar_host_routes "$n"
done

# Solo prefijos /29; los vecinos L2 quedan en rutas connected del kernel.
run sede-1 "ip route replace 10.20.2.0/29 via 10.20.1.3"
run sede-3 "ip route replace 10.20.1.0/29 via 10.20.3.2"

fallos=0
for prueba in "sede-1:10.20.2.3" "sede-1:10.20.3.3" "sede-2:10.20.1.2"; do
  origen=${prueba%%:*}
  destino=${prueba##*:}
  if docker compose exec -T "$origen" ping -c 1 -W 3 "$destino" >/dev/null 2>&1; then
    echo "  OK  $origen -> $destino"
  else
    echo "  FALLO  $origen -> $destino"
    fallos=$((fallos + 1))
  fi
done

if [[ "$fallos" -gt 0 ]]; then
  echo "ERROR: la malla no responde. Ejecuta: docker compose down -v && docker compose up -d && ./montar-rutas.sh" >&2
  exit 1
fi

echo "Rutas de la malla (triángulo) aplicadas y verificadas."
