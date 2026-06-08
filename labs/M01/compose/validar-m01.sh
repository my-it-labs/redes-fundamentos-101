#!/usr/bin/env bash
# Valida todas las maquetas M01 desde cero. Uso: labs/M01/compose/validar-m01.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
PASS=0
FAIL=0

ok()   { echo "✓ $1"; PASS=$((PASS + 1)); }
bad()  { echo "✗ $1 — $2"; FAIL=$((FAIL + 1)); }

check_ping() {
  local dir=$1 script=$2 origen=$3 destino=$4 label=$5
  cd "$ROOT/$dir"
  docker compose down -v >/dev/null 2>&1 || true
  docker compose up -d >/dev/null
  sleep 3
  [[ -n "$script" ]] && "./$script" >/dev/null
  if docker compose exec -T "$origen" ping -c 1 -W 3 "$destino" >/dev/null 2>&1; then
    ok "$label"
  else
    bad "$label" "ping $origen -> $destino"
  fi
  docker compose down -v >/dev/null 2>&1 || true
}

echo "=== Validación M01 (entorno limpio) ==="

check_ping estrella "" pc-a 172.31.10.4 "estrella pc-a -> pc-d"
check_ping bus "" nodo-1 nodo-4 "bus nodo-1 -> nodo-4"
check_ping anillo montar-rutas.sh nodo-a 10.10.2.3 "anillo nodo-a -> nodo-c"
check_ping malla montar-rutas.sh sede-1 10.20.3.3 "malla sede-1 -> sede-3"
check_ping empresa montar-rutas.sh pc-oficina 192.168.30.10 "empresa oficina -> sucursal-2"
check_ping nat-pat montar-nat.sh cliente-1 10.200.100.10 "nat-pat cliente -> wan"

echo ""
echo "=== $PASS OK / $FAIL FALLOS ==="
[[ "$FAIL" -eq 0 ]]
