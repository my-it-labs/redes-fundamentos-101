#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

run() {
  docker compose exec -T "$1" bash -c "$2"
}

# Docker (Codespace) descarta paquetes reenviados cuya IP origen no pertenece
# a la subred del bridge de salida. NAT en cada router lo evita.
configurar_host() {
  if command -v sudo >/dev/null 2>&1; then
    sudo sysctl -w net.bridge.bridge-nf-call-iptables=0 >/dev/null 2>&1 || true
    sudo iptables -I DOCKER-USER -j ACCEPT >/dev/null 2>&1 || true
  fi
  sysctl -w net.bridge.bridge-nf-call-iptables=0 >/dev/null 2>&1 || true
  iptables -I DOCKER-USER -j ACCEPT >/dev/null 2>&1 || true
}

habilitar_router() {
  local nodo=$1
  run "$nodo" '
    echo 1 > /proc/sys/net/ipv4/ip_forward
    echo 1 > /proc/sys/net/ipv4/conf/all/forwarding
    for f in /proc/sys/net/ipv4/conf/*/forwarding; do
      echo 1 > "$f" 2>/dev/null || true
    done
    for f in /proc/sys/net/ipv4/conf/*/rp_filter; do
      echo 0 > "$f" 2>/dev/null || true
    done
    iptables -P FORWARD ACCEPT 2>/dev/null || true
    iptables -F FORWARD 2>/dev/null || true
    iptables -A FORWARD -j ACCEPT 2>/dev/null || true
    iptables -t nat -F POSTROUTING 2>/dev/null || true
    for iface in eth0 eth1; do
      [ -d "/sys/class/net/$iface" ] || continue
      iptables -t nat -A POSTROUTING -o "$iface" -j MASQUERADE
    done
    test "$(cat /proc/sys/net/ipv4/ip_forward)" = "1"
  ' || {
    echo "ERROR: no se pudo configurar $nodo. Recrea contenedores:" >&2
    echo "  docker compose down && docker compose up -d --force-recreate" >&2
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

configurar_host

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
  echo ""
  echo "ERROR: ejecuta ./diagnostico.sh y pega la salida."
  exit 1
fi

echo "Rutas del anillo aplicadas y verificadas."
