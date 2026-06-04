# M06 — Modelo OSI y TCP/IP

[← Página anterior](../M05/README.md) · [Siguiente página →](M06-01-modelo-osi.md)

## Qué aprenderás

- Ubicar **`ping`**, **`ip`**, **`ss`** y **`curl`** en capas OSI / TCP/IP.
- Diagnosticar un fallo “la red va pero la web no” sin mezclar capas.
- Comparar el modelo **OSI de 7 capas** con **TCP/IP de 4 capas**.

## Contexto

- M06-01 usa la maqueta `capas` (servidor HTTP + cliente).
- M06-02 combina tabla teórica con el mismo escenario para anclar protocolos.
- En cada paso con maqueta: **levantar** → **acceder** → comandos **dentro del sistema**.

## Ejercicios

| ID | Guion | Maqueta |
|----|-------|---------|
| M06-01 | [Modelo OSI en un fallo](M06-01-modelo-osi.md) | `compose/capas` |
| M06-02 | [TCP/IP vs OSI](M06-02-tcpip-vs-osi.md) | `compose/capas` (paso 2) |

Conceptos: [Glosario de términos](../../docs/glosario-terminos.md) · Comandos: [Glosario de herramientas](../../docs/glosario-herramientas.md).

## Antes de seguir

- Repasa M05-02 si quieres relacionar filtrado por puerto con “capa 4”.
- En M06-01 conviene ejecutar los pasos en orden (primero línea base, luego fallos).
