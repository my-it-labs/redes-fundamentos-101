# M04 — Puertos, TCP/UDP y sockets

[← Página anterior](../M03/M03-04-smtp-icmp.md) · [Siguiente página →](M04-01-tcp-udp-puertos.md)

## Qué aprenderás

- Puertos bien conocidos, registrados y dinámicos.
- Diferencias TCP vs UDP y casos de uso.
- Concepto de socket y comunicación cliente-servidor.

## Contexto

- Una sola maqueta `servicios` con HTTP (TCP 8080) y eco UDP (9999).
- En cada guion: **levantar la maqueta** → **acceder al sistema** → comandos **dentro del sistema**.

## Ejercicios

| ID | Guion | Maqueta |
|----|-------|---------|
| M04-01 | [TCP, UDP y puertos](M04-01-tcp-udp-puertos.md) | `compose/servicios` |
| M04-02 | [Sockets](M04-02-sockets.md) | `compose/servicios` |

Conceptos: [Glosario de términos](../../docs/glosario-terminos.md) · Comandos: [Glosario de herramientas](../../docs/glosario-herramientas.md).

## Antes de seguir

- Completa M03 (SMTP/ICMP y servicios previos).
- Debes poder leer `ss -tuln`, hacer `curl` TCP y `nc -u` hacia el servidor.
- Los **retos** al final de cada guion amplían puertos o conexiones; la solución va en un bloque desplegable.
