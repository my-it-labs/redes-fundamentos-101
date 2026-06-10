# M08 — VLAN y trunking

[← Página anterior](../M07/README.md) · [Siguiente página →](M08-01-concepto-vlan.md)

## Qué aprenderás

- **VLAN** como dominio de broadcast separado (ventas vs RRHH).
- Puertos **access** vs **trunk** y router entre VLANs (`departamentos`).
- Caso **voz + datos** añadiendo red `vlan-voz` y filtrado en el router.

## Contexto

- La maqueta usa dos redes Docker como VLANs lógicas + `router-vlan`.
- Script `montar-rutas.sh` activa routing inter-VLAN (comparar antes/después en M08-01).
- Cierra el curso: tras M08-03, [índice general del curso](../../README.md).

## Ejercicios

| ID | Guion | Maqueta |
|----|-------|---------|
| M08-01 | [Concepto VLAN](M08-01-concepto-vlan.md) | `compose/departamentos` |
| M08-02 | [Access y trunk](M08-02-access-trunk.md) | `compose/departamentos` |
| M08-03 | [Casos prácticos](M08-03-casos-practicos.md) | `compose/departamentos` (+ `pc-voz`) |

Conceptos: [Glosario de términos](../../docs/glosario-terminos.md) · Comandos: [Glosario de herramientas](../../docs/glosario-herramientas.md) · Lectura: [Nginx reverse proxy y PLCs](../../docs/nginx-reverse-proxy-plcs.md).

## Antes de seguir

- Repasa M07 (switch vs router) antes de VLAN.
- M08-03 pide editar `docker-compose.yaml` y `montar-rutas.sh`; haz copia o commit local si trabajas en tu repo.
