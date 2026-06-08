#!/usr/bin/env bash
# Atajo: ejecuta el validador global (incluye las 6 maquetas M01).
set -euo pipefail
exec bash "$(cd "$(dirname "$0")/../.." && pwd)/validar-todos.sh"
