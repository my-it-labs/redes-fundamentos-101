#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

run() {
  docker compose exec -T "$1" bash -c "$2"
}

habilitar_router() {
  local nodo=$1
  run "$nodo" '
    echo 1 > /proc/sys/net/ipv4/ip_forward
    for f in /proc/sys/net/ipv4/conf/*/rp_filter; do
      echo 0 > "$f" 2>/dev/null || true
    done
    iptables -P FORWARD ACCEPT 2>/dev/null || true
    iptables -P INPUT ACCEPT 2>/dev/null || true
    iptables -P OUTPUT ACCEPT 2>/dev/null || true
    test "$(cat /proc/sys/net/ipv4/ip_forward)" = "1"
  ' || {
    echo "ERROR: no se pudo activar ip_forward en $nodo." >&2
    echo "  Ejecuta: docker compose down && docker compose up -d --force-recreate" >&2
    echo "  (Los contenedores deben crearse con privileged: true del compose actual.)" >&2
    exit 1
  }
}

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

iface_en_red() {
  local nodo=$1 prefijo=$2
  docker compose exec -T "$nodo" bash -c \
    "ip -4 -o addr show | awk -v p='$prefijo' '\$4 ~ \"^\"p {print \$2; exit}'"
}

for n in nodo-a nodo-b nodo-c nodo-d; do
  habilitar_router "$n"
  limpiar_host_routes "$n"
done

A_AB="$(iface_en_red nodo-a 10.10.1.)"
B_BC="$(iface_en_red nodo-b 10.10.2.)"
C_BC="$(iface_en_red nodo-c 10.10.2.)"
C_CD="$(iface_en_red nodo-c 10.10.3.)"
D_DA="$(iface_en_red nodo-d 10.10.4.)"

run nodo-a "ip route replace 10.10.2.0/29 via 10.10.1.3 dev ${A_AB}; ip route replace 10.10.3.0/29 via 10.10.1.3 dev ${A_AB}"
run nodo-b "ip route replace 10.10.3.0/29 via 10.10.2.3 dev ${B_BC}; ip route replace 10.10.4.0/29 via 10.10.2.3 dev ${B_BC}"
run nodo-c "ip route replace 10.10.4.0/29 via 10.10.3.3 dev ${C_CD}; ip route replace 10.10.1.0/29 via 10.10.2.2 dev ${C_BC}"
run nodo-d "ip route replace 10.10.1.0/29 via 10.10.4.2 dev ${D_DA}; ip route replace 10.10.2.0/29 via 10.10.4.2 dev ${D_DA}"

verificar() {
  docker compose exec -T "$1" ping -c 1 -W 3 "$2" >/dev/null 2>&1
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
  echo "ERROR: el anillo no responde."
  echo "  git pull"
  echo "  docker compose down && docker compose up -d --force-recreate"
  echo "  ./montar-rutas.sh"
  echo ""
  echo "--- Diagnóstico nodo-b ---"
  docker compose exec -T nodo-b bash -c '
    echo "ip_forward=$(cat /proc/sys/net/ipv4/ip_forward)"
    echo "rp_filter all=$(cat /proc/sys/net/ipv4/conf/all/rp_filter)"
    ip -4 route show
    ip -4 -o addr show
  '
  exit 1
fi

echo "Rutas del anillo aplicadas y verificadas."
