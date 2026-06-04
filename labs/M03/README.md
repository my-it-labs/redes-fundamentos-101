# M03 — Servicios básicos de red

[← Página anterior](../M02/M02-03-ipv6-basico.md) · [Siguiente página →](M03-01-dns.md)

## Qué aprenderás

- Resolver nombres con DNS (A, AAAA, CNAME, MX, PTR).
- Entender DHCP: asignación, reservas y opciones.
- Comparar FTP/SFTP/FTPS y usar ICMP para diagnóstico.

## Contexto

- Servicios en maquetas aisladas (`192.168.52.x`, `.53.x`, etc.).
- En cada guion: **levantar la maqueta** → **acceder al sistema** → comandos **dentro del sistema**.

## Ejercicios

| ID | Guion | Maqueta |
|----|-------|---------|
| M03-01 | [DNS](M03-01-dns.md) | `compose/dns` (`dnsmasq.conf`) |
| M03-02 | [DHCP](M03-02-dhcp.md) | `compose/dhcp` (`dnsmasq-dhcp.conf`) |
| M03-03 | [FTP y SFTP](M03-03-ftp-sftp.md) | `compose/sftp` |
| M03-04 | [SMTP e ICMP](M03-04-smtp-icmp.md) | `compose/correo` |

Conceptos: [Glosario de términos](../../docs/glosario-terminos.md) · Comandos: [Glosario de herramientas](../../docs/glosario-herramientas.md).

## Antes de seguir

- Completa M02 (gateway e IPv6 básico).
- Debes poder usar `dig @IP`, `dhclient` y `sftp` desde el cliente de cada maqueta.
- Los **retos** al final de cada guion son iteraciones cortas; la solución va en un bloque desplegable.
