# Formación redes

[Siguiente página →](labs/M01/README.md)

Formación **100 % práctica** — fundamentos de redes (20 h).

Aprenderás montando topologías en la maqueta del laboratorio y trabajando **dentro de cada sistema** con `ping`, `ip`, `iptables` y el resto de herramientas de red.

---

## Cómo funciona el curso

- Empieza en esta página y avanza con **← Página anterior · Siguiente página →**.
- Cada módulo tiene maquetas en `labs/M0x/compose/` (varios sistemas Linux por ejercicio).
- Cierra cada ejercicio con **Antes de seguir** (foco + retos).

---

## Antes de empezar

| Requisito | Dónde |
|-----------|--------|
| **Codespace** (recomendado) | Botón *Code* → *Create codespace*; incluye Docker ([`.devcontainer/`](.devcontainer/devcontainer.json)) |
| Linux + Docker | `docker build -t lab-host:local -f labs/_infra/Dockerfile.lab-host labs/_infra` (reconstruye si cambia la imagen) |
| Herramientas en cada sistema | `ip`, `ping`, `curl`, `iptables` — ya en la imagen `lab-host` |
| **Glosario de términos** | [Conceptos de red](docs/glosario-terminos.md) (IP, MAC, rutas, NAT, LAN/WAN…) |
| **Glosario de herramientas** | [Comandos](docs/glosario-herramientas.md) (`ip`, `ping`, `dig`, `ss`, etc.) |
| **Cálculo CIDR** | [Rangos de IP por prefijo](docs/calculo-cidr-subredes.md) (red, máscara, broadcast, hosts) |

---

## Módulos (20 h)

| # | Módulo | Horas | Índice | Estado |
|---|--------|-------|--------|--------|
| **M01** | Introducción y tipos de redes | 2,5 h | [labs/M01/](labs/M01/README.md) | publicado |
| **M02** | Direccionamiento IPv4/IPv6 | 3 h | [labs/M02/](labs/M02/README.md) | publicado |
| **M03** | Servicios básicos de red | 3 h | [labs/M03/](labs/M03/README.md) | publicado |
| **M04** | Puertos, TCP/UDP y sockets | 2 h | [labs/M04/](labs/M04/README.md) | publicado |
| **M05** | Seguridad y DMZ | 2,5 h | [labs/M05/](labs/M05/README.md) | publicado |
| **M06** | Modelo OSI y TCP/IP | 2,5 h | [labs/M06/](labs/M06/README.md) | publicado |
| **M07** | Dispositivos de red | 2,5 h | [labs/M07/](labs/M07/README.md) | publicado |
| **M08** | VLAN y trunking | 2 h | [labs/M08/](labs/M08/README.md) | publicado |

---

## Empieza aquí

→ **[M01 — Introducción y tipos de redes](labs/M01/README.md)**  
→ Primer ejercicio: [M01-01 — Tipos de redes y topologías](labs/M01/M01-01-tipos-redes-topologias.md)
