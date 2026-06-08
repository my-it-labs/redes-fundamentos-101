#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

cid="$(docker compose ps -q nodo-b)"
if [[ -z "$cid" ]]; then
  echo "ERROR: levanta la maqueta antes (docker compose up -d)." >&2
  exit 1
fi

net="$(docker network ls --format '{{.Name}}' | grep '_bc$' | head -1)"
if [[ -z "$net" ]]; then
  echo "ERROR: no encuentro la red *_bc del anillo." >&2
  exit 1
fi

docker network connect "$net" "$cid"
sleep 1
exec ./montar-rutas.sh
