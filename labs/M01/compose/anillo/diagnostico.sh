#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

for n in nodo-a nodo-b nodo-c nodo-d; do
  echo "======== $n ========"
  docker compose exec -T "$n" bash -c '
    echo "ip_forward=$(cat /proc/sys/net/ipv4/ip_forward)"
    echo "rp_filter all=$(cat /proc/sys/net/ipv4/conf/all/rp_filter) eth0=$(cat /proc/sys/net/ipv4/conf/eth0/rp_filter 2>/dev/null || echo -) eth1=$(cat /proc/sys/net/ipv4/conf/eth1/rp_filter 2>/dev/null || echo -)"
    ip -4 -o addr show
    ip -4 route show
    iptables -L FORWARD -n 2>/dev/null | head -3 || true
  ' 2>/dev/null || echo "(contenedor $n no está arriba)"
  echo ""
done

echo "======== pings desde nodo-a ========"
for ip in 10.10.1.3 10.10.2.3 10.10.3.2 10.10.4.3; do
  printf '%s: ' "$ip"
  docker compose exec -T nodo-a ping -c1 -W2 "$ip" >/dev/null 2>&1 && echo OK || echo FALLO
done
