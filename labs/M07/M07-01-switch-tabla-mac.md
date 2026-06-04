# Laboratorio M07-01 — Switch y tabla MAC

[← Página anterior](../M06/README.md) · [Siguiente página →](M07-02-router-modem-ap.md)

## Objetivo del laboratorio

Al terminar debes poder:

- Explicar qué hace un **switch L2** (reenvío por MAC, dominio de broadcast).
- Ver la **tabla de vecinos** (`ip neigh`) en un segmento compartido.
- Relacionar **ping** con aprendizaje de direcciones MAC en el segmento.

En cada paso: **levantar la maqueta** → **acceder al sistema** → comandos **dentro del sistema**.

Conceptos: [Glosario de términos](../../docs/glosario-terminos.md) · Comandos: [Glosario de herramientas](../../docs/glosario-herramientas.md).

---

### Paso 1 — Tres equipos en el mismo segmento

**Aprende:** en una LAN L2, cada host tiene IP (capa 3) y MAC (capa 2). El switch aprende qué MAC está detrás de cada puerto.

**Levantar la maqueta:**

```bash
cd labs/M07/compose/segmento-l2
docker compose up -d
```

**Acceder al sistema `pc-1`:**

```bash
docker compose exec -it pc-1 bash
```

**Dentro del sistema `pc-1`:**

```bash
ip link show eth0
ip -4 addr show dev eth0
ip neigh show dev eth0
```

**Deberías ver:**

- Interfaz `eth0` con MAC propia y IP `192.168.58.11`.
- Tabla de vecinos vacía o solo entradas incompletas (aún no has hablado con nadie).

**Por qué:** `ip neigh` en Linux es la **tabla ARP/neighbor** del host; equivale a “lo que el equipo cree del segmento”, no la tabla interna del switch físico (que no ves desde aquí).

**Dentro del sistema:** `exit`

---

### Paso 2 — Ping y aprendizaje de vecinos

**Aprende:** el primer paquete hacia una IP dispara **ARP** (¿quién tiene esta IP?); la respuesta guarda la MAC.

**Acceder al sistema `pc-1`:**

```bash
docker compose exec -it pc-1 bash
```

**Dentro del sistema `pc-1`:**

```bash
ping -c 2 pc-2
ping -c 2 192.168.58.13
ip neigh show dev eth0
```

**Deberías ver:**

- `ping` con 0 % pérdida hacia `pc-2` y hacia `192.168.58.13` (`pc-3`).
- Entradas `REACHABLE` con MAC distintas para `.12` y `.13`.

**Por qué:** el switch de la maqueta reenvía tramas unicast por MAC aprendida; el broadcast ARP solo lo necesitan hosts que aún no conocen la MAC destino.

**Dentro del sistema:** `exit`

---

### Paso 3 — Ver el otro lado (pc-2)

**Aprende:** la tabla es simétrica en concepto: cada extremo aprende la MAC del otro tras el intercambio.

**Acceder al sistema `pc-2`:**

```bash
docker compose exec -it pc-2 bash
```

**Dentro del sistema `pc-2`:**

```bash
ip neigh flush dev eth0
ping -c 1 192.168.58.11
ip neigh show dev eth0
```

**Deberías ver:**

- Tras el flush, la primera entrada hacia `.11` pasa por `STALE`/`REACHABLE` tras el ping.
- MAC de `pc-1` distinta de la de `pc-2`.

**Por qué:** si dos MAC iguales aparecieran en el segmento (conflicto), verías comportamiento errático; en la maqueta cada contenedor tiene MAC única.

**Dentro del sistema:** `exit`

---

### Paso 4 — “Caída” de un extremo

**Aprende:** si un host deja de responder, las entradas vecinas envejecen; el switch deja de recibir tramas de ese MAC.

**En tu terminal (maqueta):**

```bash
docker compose stop pc-3
```

**Acceder al sistema `pc-1`:**

```bash
docker compose exec -it pc-1 bash
```

**Dentro del sistema `pc-1`:**

```bash
ping -c 2 192.168.58.13
ip neigh show | grep 58.13 || echo "sin entrada útil"
```

**Deberías ver:**

- `ping` sin respuesta.
- Entrada ARP posiblemente `STALE` o ausente tras el fallo.

**Por qué:** en un switch real, el puerto del host caído deja de verse en la **tabla MAC del switch** tras timeout; aquí observas el efecto desde el host que intenta hablar.

**Dentro del sistema:** `exit`

**En tu terminal (maqueta):**

```bash
docker compose start pc-3
docker compose down
```

---

## Antes de seguir

### Pon el foco en

- **Switch** = L2, un dominio de broadcast (salvo VLAN, M08).
- **Router** = L3, une subredes distintas (M07-02).
- `ip neigh` diagnostica problemas “hay IP pero no hay MAC”.

### Reto

**1. Cuarto equipo** — Añade `pc-4` con IP `192.168.58.14` en `segmento-l2` y comprueba que `pc-1` aprende su MAC con un solo `ping`.

<details>
<summary>Ver solución</summary>

En `docker-compose.yaml`, servicio `pc-4` con `ipv4_address: 192.168.58.14` en red `segmento`.

**Levantar:** `up -d`. **Dentro de `pc-1`:** `ping -c 1 192.168.58.14` y `ip neigh show | grep 58.14`.

</details>

**2. Vecino equivocado** — Borra la entrada de `pc-2` en `pc-1` (`ip neigh del`) y haz `ping` de nuevo. ¿Qué ocurre?

<details>
<summary>Ver solución</summary>

ARP se repite; nueva entrada `REACHABLE` con la misma MAC correcta de `pc-2`. Si la MAC fuera errónea (ataque ARP), el tráfico iría al host equivocado — tema de seguridad L2.

</details>
