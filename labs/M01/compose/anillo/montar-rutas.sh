#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

run() {
  docker compose exec -T "$1" bash -c "$2"
}

# Borra rutas host (/32) hacia 10.10.x.x que rompen el reenvío L2/L3.
limpiar_host_routes() {
  local nodo=$1
  run "$nodo" '
    ip route show table main | while read -r dst _ via gw _ dev iface _; do
      [[ "$dst" =~ ^10\.10\.[0-9]+\.[0-9]+$ ]] || continue
      ip route del "$dst" via "$gw" dev "$iface" 2>/dev/null || true
    done
  '
}

for n in nodo-a nodo-b nodo-c nodo-d; do
  limpiar_host_routes "$n"
done

# Ida horario: a -> b -> c -> d
run nodo-a "ip route replace 10.10.2.0/29 via 10.10.1.3; ip route replace 10.10.3.0/29 via 10.10.1.3"
run nodo-b "ip route replace 10.10.3.0/29 via 10.10.2.3; ip route replace 10.10.4.0/29 via 10.10.2.3"
run nodo-c "ip route replace 10.10.4.0/29 via 10.10.3.3; ip route replace 10.10.1.0/29 via 10.10.2.2"
run nodo-d "ip route replace 10.10.1.0/29 via 10.10.4.2; ip route replace 10.10.2.0/29 via 10.10.4.2"

verificar() {
  local origen=$1 destino=$2
  docker compose exec -T "$origen" ping -c 1 -W 3 "$destino" >/dev/null 2>&1
}

fallos=0
for prueba in "nodo-a:10.10.1.3" "nodo-a:10.10.2.3" "nodo-a:10.10.3.2" "nodo-a:10.10.4.3"; do
  origen=${prueba%%:*}
  destino=${prueba##*:}
  if verificar "$origen" "$destino"; then
    echo "  OK  $origen -> $destino"
  else
    echo "  FALLO  $origen -> $destino"
    fallos=$((fallos + 1))
  fi
done

if [[ "$fallos" -gt 0 ]]; then
  echo ""
  echo "ERROR: el anillo no responde. Prueba:"
  echo "  git pull"
  echo "  docker compose down -v && docker compose up -d"
  echo "  ./montar-rutas.sh"
  echo ""
  echo "Rutas sospechosas en nodo-b (no debe haber /32):"
  docker compose exec -T nodo-b ip route | grep ' via ' | grep -v '/29' || true
  exit 1
fi

echo "Rutas del anillo aplicadas y verificadas."
