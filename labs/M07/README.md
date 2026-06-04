# M07 — Dispositivos de red

[← Página anterior](../M06/README.md) · [Siguiente página →](M07-01-switch-tabla-mac.md)

## Qué aprenderás

- **Switch L2:** tabla de vecinos, ARP y `ping` en un segmento (`segmento-l2`).
- **Router, módem y AP:** roles con la maqueta [empresa de M01](../M01/compose/empresa).
- **WiFi:** SSID, canal y seguridad leyendo `ip link` / `iw` en tu host (sin radio en muchos Codespaces).

## Contexto

- M07-01 es pura L2 en `compose/segmento-l2`.
- M07-02 reutiliza `labs/M01/compose/empresa` (gateways y WAN simulada).
- M07-03 es conceptual en el **terminal del Codespace o Linux**, no dentro de la maqueta.

## Ejercicios

| ID | Guion | Maqueta / entorno |
|----|-------|-------------------|
| M07-01 | [Switch y tabla MAC](M07-01-switch-tabla-mac.md) | `compose/segmento-l2` |
| M07-02 | [Router, módem y AP](M07-02-router-modem-ap.md) | `../M01/compose/empresa` |
| M07-03 | [WiFi básico](M07-03-wifi-basico.md) | Host (Codespace/Linux) |

Conceptos: [Glosario de términos](../../docs/glosario-terminos.md) · Comandos: [Glosario de herramientas](../../docs/glosario-herramientas.md).

## Antes de seguir

- Debes dominar `ping` e `ip neigh` en un mismo segmento antes de cruzar sedes en M07-02.
