#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

run() {
  docker compose exec -T "$1" bash -c "$2"
}

# Quitar rutas /32 de versiones anteriores (rompían ping al vecino L2).
run nodo-a "ip route del 10.10.4.3 via 10.10.1.3 2>/dev/null || true"
run nodo-b "ip route del 10.10.1.2 via 10.10.2.3 2>/dev/null || true"
run nodo-c "ip route del 10.10.2.2 via 10.10.3.3 2>/dev/null || true"
run nodo-d "ip route del 10.10.3.2 via 10.10.4.2 2>/dev/null || true"

# Ida horario: a -> b -> c -> d ...
run nodo-a "ip route replace 10.10.2.0/29 via 10.10.1.3; ip route replace 10.10.3.0/29 via 10.10.1.3"
run nodo-b "ip route replace 10.10.3.0/29 via 10.10.2.3; ip route replace 10.10.4.0/29 via 10.10.2.3"
run nodo-c "ip route replace 10.10.4.0/29 via 10.10.3.3"
# Vuelta del ping a la LAN ab: c -> b -> a (misma ruta inversa; evita rp_filter en Codespace).
run nodo-c "ip route replace 10.10.1.0/29 via 10.10.2.2"
run nodo-d "ip route replace 10.10.1.0/29 via 10.10.4.2; ip route replace 10.10.2.0/29 via 10.10.4.2"

for n in nodo-a nodo-b nodo-c nodo-d; do
  run "$n" "for i in all default eth0 eth1 lo; do sysctl -w net.ipv4.conf.\${i}.rp_filter=0 2>/dev/null || true; done"
done

echo "Rutas del anillo aplicadas."
