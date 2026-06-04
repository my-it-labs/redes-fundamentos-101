# Maquetas del laboratorio — M01

Cada carpeta es una topología lista para levantar. Imagen base: `lab-host:local` (Ubuntu con `ip`, `ping`, `iptables`).

## Requisito previo

Desde la raíz del repo (o tras abrir el Codespace, que construye la imagen al crearse):

```bash
docker build -t lab-host:local -f labs/_infra/Dockerfile.lab-host labs/_infra
```

## Uso habitual

Tres movimientos en los guiones:

1. **Levantar la maqueta** — `docker compose up -d` (+ `./montar-*.sh` si aplica)
2. **Acceder al sistema** — `docker compose exec -it <nombre> bash`
3. **Dentro del sistema** — `ping`, `ip`, `iptables`, etc.

```bash
cd labs/M01/compose/<nombre>
docker compose up -d
./montar-rutas.sh   # si aplica

docker compose exec -it pc-a bash

docker compose down
```

## Qué cubre Compose en este curso

| Arquitectura | Carpeta | Cómo se simula |
|--------------|---------|----------------|
| Estrella | `estrella/` | Un bridge = switch; todos los nodos en la misma red |
| Bus | `bus/` | Medio compartido L2 (misma idea que estrella en la maqueta) |
| Anillo | `anillo/` | Cada nodo en dos redes; rutas estáticas (`montar-rutas.sh`) |
| Malla parcial | `malla/` | Triángulo con tres enlaces y rutas alternativas |
| LAN + WAN (oficina/sucursales) | `empresa/` | Varias LAN + red `wan-mpls`; routers en dos redes |
| PAT / NAT | `nat-pat/` | LAN interna + internet; `MASQUERADE` en el gateway |

## Limitaciones (101)

- No hay switch físico ni etiquetas 802.1Q reales (M08 usará el mismo patrón “una red = un segmento”).
- WiFi y PAN no se emulan; se observan en el host del Codespace cuando aplica.
- No uses la IP `.1` en los sistemas de la maqueta: suele estar reservada; los routers del curso usan `.254`.
