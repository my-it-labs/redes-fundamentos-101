# M02 — Direccionamiento IPv4/IPv6

[← Página anterior](../M01/M01-03-nat-pat.md) · [Siguiente página →](M02-01-cidr-subredes.md)

## Qué aprenderás

- Calcular subredes con máscara y notación CIDR.
- Usar la puerta de enlace (default gateway) en rutas locales.
- Reconocer formatos y tipos básicos de IPv6 (link-local, global, multicast, SLAAC).

## Contexto

- El temario cliente cubre 2.1–2.3: máscara, gateway e introducción IPv6.
- En cada guion: **levantar la maqueta** → **acceder al sistema** → comandos **dentro del sistema**.

## Ejercicios

| ID | Guion | Maqueta |
|----|-------|---------|
| M02-01 | [CIDR y subredes](M02-01-cidr-subredes.md) | `compose/subredes` |
| M02-02 | [Puerta de enlace](M02-02-puerta-enlace.md) | `compose/dos-subredes` + `montar-rutas.sh` |
| M02-03 | [IPv6 básico](M02-03-ipv6-basico.md) | `compose/ipv6` + `montar-ipv6.sh` |

Conceptos: [Glosario de términos](../../docs/glosario-terminos.md) · Comandos: [Glosario de herramientas](../../docs/glosario-herramientas.md).

## Antes de seguir

- Completa M01 (NAT/PAT) antes de continuar.
- Debes poder calcular red/broadcast para `/26` y hacer `ping` entre hosts de la misma subred.
- Los **retos** al final de cada guion amplían la maqueta o el razonamiento; la solución va en un bloque desplegable.
