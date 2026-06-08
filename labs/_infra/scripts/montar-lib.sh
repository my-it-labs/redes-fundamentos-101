# Funciones compartidas para scripts montar-*.sh de maquetas con routers.
# Uso: source "$(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)/../../../_infra/scripts/montar-lib.sh"

run() {
  docker compose exec -T "$1" bash -c "$2"
}

configurar_host_docker() {
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
    for iface in /sys/class/net/eth*; do
      name="${iface##*/}"
      iptables -t nat -A POSTROUTING -o "$name" -j MASQUERADE 2>/dev/null || true
    done
    test "$(cat /proc/sys/net/ipv4/ip_forward)" = "1"
  ' || {
    echo "ERROR: no se pudo activar reenvío en $nodo." >&2
    echo "  docker compose down && docker compose up -d --force-recreate" >&2
    exit 1
  }
}

verificar_ping() {
  local origen=$1 destino=$2
  docker compose exec -T "$origen" ping -c 1 -W 3 "$destino" >/dev/null 2>&1
}
