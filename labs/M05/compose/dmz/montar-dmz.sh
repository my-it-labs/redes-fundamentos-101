#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
source "$(dirname "$0")/../../../_infra/scripts/montar-lib.sh"

configurar_host_docker

run pc-interno "ip route replace default via 10.70.1.254"
run servidor-dmz "ip route replace default via 10.70.2.254"
run atacante-internet "ip route replace default via 10.70.100.254"

habilitar_router firewall

run firewall '
  LAN=$(ip -4 -o addr show | awk "/10.70.1.254/{print \$2; exit}")
  DMZ=$(ip -4 -o addr show | awk "/10.70.2.254/{print \$2; exit}")
  INET=$(ip -4 -o addr show | awk "/10.70.100.254/{print \$2; exit}")
  iptables -F FORWARD
  iptables -P FORWARD DROP
  iptables -A FORWARD -i "$LAN" -o "$DMZ" -j ACCEPT
  iptables -A FORWARD -i "$DMZ" -o "$LAN" -j ACCEPT
  iptables -A FORWARD -i "$INET" -o "$DMZ" -p tcp -d 10.70.2.10 --dport 8080 -j ACCEPT
  iptables -A FORWARD -i "$DMZ" -o "$INET" -p tcp -s 10.70.2.10 --sport 8080 -j ACCEPT
'

verificar_ping pc-interno 10.70.2.10 || exit 1
docker compose exec -T pc-interno curl -sf -m3 http://10.70.2.10:8080/ -o /dev/null || exit 1
docker compose exec -T atacante-internet curl -sf -m3 http://10.70.2.10:8080/ -o /dev/null || exit 1
if docker compose exec -T atacante-internet ping -c1 -W2 10.70.2.10 >/dev/null 2>&1; then exit 1; fi

echo "DMZ montada y verificada."
