# M05 — Seguridad y zonas de red

[← Página anterior](../M04/README.md) · [Siguiente página →](M05-01-dmz.md)

## Qué aprenderás

- Diseñar una **DMZ** entre LAN interna, servicios expuestos e internet simulada.
- Comprobar con `ping` y `curl` qué alcanza un servidor en el puerto **8080**.
- Endurecer **segmentación** y filtrado con `iptables` en el firewall de la maqueta.

## Contexto

- Continúa la práctica de **sockets y HTTP** de M04; aquí el foco es **dónde** vive el servidor y **quién** puede llegar.
- En cada paso: **levantar la maqueta** → **acceder al sistema** → comandos **dentro del sistema**.
- Maqueta: `compose/dmz` + script `montar-dmz.sh` en tu terminal.

## Ejercicios

| ID | Guion | Maqueta |
|----|-------|---------|
| M05-01 | [DMZ](M05-01-dmz.md) | `compose/dmz` |
| M05-02 | [Segmentación y filtrado](M05-02-segmentacion-filtrado.md) | `compose/dmz` |

Conceptos: [Glosario de términos](../../docs/glosario-terminos.md) · Comandos: [Glosario de herramientas](../../docs/glosario-herramientas.md).

## Antes de seguir

- Debes haber practicado `curl` a un puerto TCP en un servidor (M04).
- Los retos de M05-02 modifican reglas en `firewall`; anota el estado antes de cambiar.
