#!/usr/bin/env bash
# Valida todas las maquetas M01–M08. Uso: labs/validar-todos.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
PASS=0
FAIL=0
SKIP=0

ok()   { echo "✓ $1"; PASS=$((PASS + 1)); }
bad()  { echo "✗ $1 — $2"; FAIL=$((FAIL + 1)); }
skip() { echo "○ $1 — $2"; SKIP=$((SKIP + 1)); }

lab_up() {
  local dir=$1
  cd "$ROOT/$dir"
  docker compose down -v >/dev/null 2>&1 || true
  docker compose up -d --force-recreate >/dev/null
  sleep 3
}

lab_down() {
  docker compose down -v >/dev/null 2>&1 || true
}

run_script() {
  local script=$1
  [ -f "./$script" ] && chmod +x "./$script" && "./$script" >/dev/null
}

check_ping() {
  local from=$1 to=$2 label=$3
  if docker compose exec -T "$from" ping -c 1 -W 4 "$to" >/dev/null 2>&1; then
    ok "$label"
  else
    bad "$label" "ping $from -> $to"
  fi
}

check_cmd() {
  local svc=$1 cmd=$2 label=$3
  if docker compose exec -T "$svc" bash -c "$cmd" >/dev/null 2>&1; then
    ok "$label"
  else
    bad "$label" "$cmd"
  fi
}

echo "=== Validación maquetas redes-fundamentos-101 ==="
echo ""

# --- M01 ---
lab_up M01/compose/estrella
check_ping pc-a 172.31.10.4 "M01 estrella pc-a -> pc-d"
lab_down

lab_up M01/compose/bus
check_ping nodo-1 nodo-4 "M01 bus nodo-1 -> nodo-4"
lab_down

lab_up M01/compose/anillo
run_script montar-rutas.sh
check_ping nodo-a 10.10.2.3 "M01 anillo nodo-a -> nodo-c"
check_ping nodo-a 10.10.3.2 "M01 anillo nodo-a -> nodo-c (cd)"
lab_down

lab_up M01/compose/malla
run_script montar-rutas.sh
check_ping sede-1 10.20.3.3 "M01 malla sede-1 -> sede-3"
lab_down

lab_up M01/compose/empresa
run_script montar-rutas.sh
check_ping pc-oficina 192.168.30.10 "M01 empresa oficina -> sucursal-2"
check_ping pc-oficina 192.168.20.10 "M01 empresa oficina -> sucursal-1"
lab_down

lab_up M01/compose/nat-pat
run_script montar-nat.sh
check_ping cliente-1 10.200.100.10 "M01 nat-pat cliente -> internet"
lab_down

# --- M02 ---
lab_up M02/compose/subredes
check_ping host-1 192.168.50.20 "M02 subredes host-1 -> host-2"
lab_down

lab_up M02/compose/dos-subredes
run_script montar-rutas.sh
check_ping pc-red-a 192.168.100.74 "M02 dos-subredes A -> B"
check_ping pc-red-b 192.168.100.10 "M02 dos-subredes B -> A"
lab_down

lab_up M02/compose/ipv6
run_script montar-ipv6.sh
check_cmd nodo-v6-a "ping6 -c1 -W3 2001:db8:101::20" "M02 ipv6 a -> b"
lab_down

# --- M03 ---
lab_up M03/compose/dns
check_cmd cliente-dns "dig @192.168.52.2 intranet.lab +short | grep -q 192.168.52.20" "M03 dns intranet.lab"
check_ping cliente-dns 192.168.52.20 "M03 dns ping servidor-web"
lab_down

lab_up M03/compose/dhcp
sleep 2
check_cmd cliente-dhcp "dhclient -v eth0 2>&1 | tail -1; ip -4 addr show eth0 | grep -q 'inet '" "M03 dhcp dhclient"
check_ping cliente-dhcp 192.168.53.254 "M03 dhcp ping gateway"
lab_down

lab_up M03/compose/sftp
sleep 4
check_cmd servidor-sftp "ss -tlnp | grep -q ':22 '" "M03 sftp puerto 22"
check_cmd cliente-ftp "echo ls | SSHPASS=lab101 sshpass -e sftp -o StrictHostKeyChecking=no -o PreferredAuthentications=password -o PubkeyAuthentication=no alumno@192.168.54.10 | grep -q ejemplo" "M03 sftp login"
lab_down

lab_up M03/compose/correo
sleep 12
check_ping cliente-mail 192.168.55.10 "M03 correo ping smtp"
check_cmd cliente-mail "nc -vz -w3 192.168.55.10 25" "M03 correo puerto 25"
lab_down

# --- M04 ---
lab_up M04/compose/servicios
check_cmd cliente "curl -sf -m3 http://192.168.56.10:8080/ -o /dev/null" "M04 servicios HTTP 8080"
check_cmd cliente "echo test | nc -u -w2 192.168.56.10 9999" "M04 servicios UDP 9999"
lab_down

# --- M05 ---
lab_up M05/compose/dmz
run_script montar-dmz.sh
check_ping pc-interno 10.70.2.10 "M05 dmz LAN -> DMZ"
check_cmd pc-interno "curl -sf -m3 http://10.70.2.10:8080/ -o /dev/null" "M05 dmz curl interno"
check_cmd atacante-internet "curl -sf -m3 http://10.70.2.10:8080/ -o /dev/null" "M05 dmz curl internet"
if docker compose exec -T atacante-internet ping -c1 -W2 10.70.2.10 >/dev/null 2>&1; then
  bad "M05 dmz ping internet bloqueado" "debería fallar"
else
  ok "M05 dmz ping internet bloqueado"
fi
lab_down

# --- M06 ---
lab_up M06/compose/capas
check_ping cliente-capas 192.168.57.10 "M06 capas ping"
check_cmd cliente-capas "curl -sf -m3 http://192.168.57.10/ -o /dev/null" "M06 capas HTTP"
lab_down

# --- M07 ---
lab_up M07/compose/segmento-l2
check_ping pc-1 pc-2 "M07 segmento-l2 pc-1 -> pc-2"
check_ping pc-1 192.168.58.13 "M07 segmento-l2 pc-1 -> pc-3"
lab_down

lab_up M01/compose/empresa
run_script montar-rutas.sh
check_ping pc-sucursal-2 192.168.10.10 "M07 empresa sucursal-2 -> oficina"
lab_down

# --- M08 ---
lab_up M08/compose/departamentos
run_script montar-rutas.sh
check_ping pc-ventas 10.80.20.10 "M08 departamentos ventas -> rrhh"
check_ping pc-ventas pc-rrhh "M08 departamentos ventas -> pc-rrhh"
lab_down

echo ""
echo "=== $PASS OK / $FAIL FALLOS / $SKIP omitidos ==="
[[ "$FAIL" -eq 0 ]]
