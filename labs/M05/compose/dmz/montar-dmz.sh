#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
run() { docker compose exec -T "$1" bash -c "$2"; }

run pc-interno "ip route replace default via 10.70.1.254"
run servidor-dmz "ip route replace default via 10.70.2.254"
run atacante-internet "ip route replace default via 10.70.100.254"

run firewall "sysctl -w net.ipv4.ip_forward=1"
run firewall "iptables -F; iptables -P FORWARD DROP"
run firewall "iptables -A FORWARD -i eth0 -o eth1 -j ACCEPT"
run firewall "iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT"
run firewall "iptables -A FORWARD -i eth2 -o eth1 -p tcp -d 10.70.2.10 --dport 8080 -j ACCEPT"
run firewall "iptables -A FORWARD -i eth1 -o eth2 -p tcp -s 10.70.2.10 --sport 8080 -j ACCEPT"

echo "DMZ montada: LAN interna <-> DMZ; internet -> DMZ:8080 permitido."
