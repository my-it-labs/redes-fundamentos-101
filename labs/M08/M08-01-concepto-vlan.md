# Laboratorio M08-01 — Concepto de VLAN

[← Página anterior](../M07/README.md) · [Siguiente página →](M08-02-access-trunk.md)

## Objetivo del laboratorio

Al terminar debes poder:

- Explicar una **VLAN** como subred lógica L2 separada (dominio de broadcast distinto).
- Demostrar que dos hosts en **VLAN distintas** no se alcanzan por IP sin un **router L3**.
- Preparar el escenario `departamentos` (ventas vs RRHH) antes de rutear entre VLANs.

En cada paso: **levantar la maqueta** → **acceder al sistema** → comandos **dentro del sistema**.  
**No ejecutes** `./montar-rutas.sh` hasta el final del paso 3 (comparación antes/después).

Conceptos: [Glosario de términos](../../docs/glosario-terminos.md).

---

### Paso 1 — Dos redes sin routing entre VLANs

**Aprende:** en la maqueta, cada “VLAN” es una red Docker distinta (`vlan-ventas`, `vlan-rrhh`). Sin router, es como dos switches aislados.

**Levantar la maqueta:**

```bash
cd labs/M08/compose/departamentos
docker compose up -d
```

**Acceder al sistema `pc-ventas`:**

```bash
docker compose exec -it pc-ventas bash
```

**Dentro del sistema `pc-ventas`:**

```bash
ip -4 addr show
ip route show
ping -c 2 10.80.20.10
```

**Deberías ver:**

- IP `10.80.10.10` en la VLAN ventas.
- Ruta por defecto hacia `10.80.10.254` (router presente en la topología, pero aún **sin** rutas inter-VLAN en el router si no corriste el script).
- `ping` a `10.80.20.10` (**pc-rrhh**) **sin respuesta**.

**Por qué:** aunque exista el contenedor `router-vlan`, hasta que tenga **reenvío y rutas** entre interfaces, las VLANs siguen aisladas a efectos L3.

**Dentro del sistema:** `exit`

---

### Paso 2 — Misma VLAN sí comunica

**Aprende:** dentro de una VLAN el comportamiento es el de un switch (M07-01): misma subred, ARP, ping directo.

**Acceder al sistema `pc-rrhh`:**

```bash
docker compose exec -it pc-rrhh bash
```

**Dentro del sistema `pc-rrhh`:**

```bash
ping -c 2 10.80.20.254
ip neigh show
```

**Deberías ver:**

- `ping` al gateway `10.80.20.254` con respuesta.
- Vecino MAC del gateway en la tabla.

**Por qué:** el gateway es alcanzable en **la misma** VLAN; eso no implica que ventas alcance RRHH.

**Dentro del sistema:** `exit`

---

### Paso 3 — Activar routing entre VLANs

**Aprende:** el **router-on-a-stick** (un router, dos VLANs) une subredes con rutas y `ip_forward`.

**En tu terminal (maqueta):**

```bash
./montar-rutas.sh
```

**Acceder al sistema `pc-ventas`:**

```bash
docker compose exec -it pc-ventas bash
```

**Dentro del sistema `pc-ventas`:**

```bash
ping -c 2 10.80.20.10
traceroute -n -m 4 10.80.20.10 2>/dev/null || true
```

**Deberías ver:**

- `ping` con 0 % pérdida hacia RRHH.
- Traceroute (si disponible) pasa por `10.80.10.254`.

**Por qué:** la VLAN segmenta broadcast; el **router** es quien permite políticas L3 entre departamentos (ACL, firewall, etc.).

**Dentro del sistema:** `exit`

**En tu terminal (maqueta):** `docker compose down`

---

## Antes de seguir

### Pon el foco en

- VLAN = **segmentación L2**, no sustituye IP ni rutas.
- Sin router (o firewall L3), VLAN distinta = **sin ping** entre subredes.
- En físico, 802.1Q etiqueta tramas en **trunks** (M08-02).

### Reto

**1. Dibujo** — Dibuja ventas y RRHH como dos nubes L2 y un router con dos patas; marca dónde falla el ping antes de `montar-rutas.sh`.

<details>
<summary>Ver solución</summary>

Antes del script: paquete llega al gateway en ventas pero el router no reenvía a RRHH (falta ruta o forward). Después: forward + rutas en `router-vlan`.

</details>

**2. Quitar default** — En `pc-ventas`, borra la ruta por defecto y deja solo ruta hacia `10.80.20.0/24` vía `10.80.10.254`. ¿Sigue el ping a RRHH? ¿Llega a internet ficticia?

<details>
<summary>Ver solución</summary>

```bash
ip route del default
ip route add 10.80.20.0/24 via 10.80.10.254
ping -c 2 10.80.20.10
```

Ping inter-VLAN OK; sin default no hay salida “internet” — enseña rutas específicas vs default.

</details>
