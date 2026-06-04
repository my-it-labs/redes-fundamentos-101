# M01 — Introducción y tipos de redes

[← Página anterior](../../README.md) · [Siguiente página →](M01-01-tipos-redes-topologias.md)

## Qué aprenderás

- Clasificar LAN, WAN, MAN y PAN viendo redes reales en Compose y en el host.
- Comparar topologías levantando maquetas (estrella, bus, anillo, malla).
- Diferenciar IP pública y privada con `ip` y `curl`.
- Demostrar PAT y port forwarding con `iptables` en un gateway de la maqueta.

## Contexto

- Cada paso combina **práctica** con **qué observas y por qué**.
- Los diagramas los aporta el repo (`labs/M01/compose/`); tú montas la red y compruebas hipótesis (qué debería fallar y qué no).
- En cada paso: **levantar la maqueta** → **acceder al sistema** → comandos **dentro del sistema** (`ping`, `ip`, …).
- Abre el curso en **Codespace** (recomendado) o en Linux con `docker compose`; ver [.devcontainer/](../../.devcontainer/devcontainer.json).

## Ejercicios

| ID | Guion | Maqueta |
|----|-------|---------|
| M01-01 | [Tipos y topologías](M01-01-tipos-redes-topologias.md) | `compose/estrella`, `bus`, `anillo`, `malla`, `empresa` |
| M01-02 | [IP pública y privada](M01-02-ip-publica-privada.md) | `compose/estrella`, `empresa` + host |
| M01-03 | [NAT y PAT](M01-03-nat-pat.md) | `compose/nat-pat` |

Índice de topologías: [compose/README.md](compose/README.md).  
Conceptos: [Glosario de términos](../../docs/glosario-terminos.md) · Comandos: [Glosario de herramientas](../../docs/glosario-herramientas.md).

## Antes de seguir

- Debes poder levantar `estrella`, entrar en un sistema y hacer `ping` a otro desde dentro.
- Los **retos** al final de cada guion son una iteración corta (añadir un host, un puerto, restaurar el anillo); la solución va en un bloque desplegable.
