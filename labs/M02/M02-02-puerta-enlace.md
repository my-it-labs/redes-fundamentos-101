# Laboratorio M02-02 — Puerta de enlace (default gateway)

[← Página anterior](M02-01-cidr-subredes.md) · [Siguiente página →](M02-03-ipv6-basico.md)

## Objetivo del laboratorio

Al terminar debes poder:

- Explicar el rol del **default gateway** cuando el destino no está en la subred local.
- Hacer `ping` entre dos subredes `/26` unidas por un router.
- Demostrar que un gateway **incorrecto** rompe el tráfico inter-subred.

En cada paso: **levantar la maqueta** → **acceder al sistema** → comandos **dentro del sistema**.

Conceptos: [Glosario de términos](../../docs/glosario-terminos.md) (gateway, tabla de enrutamiento) · Comandos: [Glosario de herramientas](../../docs/glosario-herramientas.md).

---

## Mapa mental (antes de tocar comandos)

```text
192.168.100.0/26 (red A)          192.168.100.64/26 (red B)
  pc-red-a (.10)                      pc-red-b (.74)
       │                                    │
       └──── router (.62 / .126) ──────────┘
```

| Sistema | IP | Gateway correcto |
|---------|-----|------------------|
| `pc-red-a` | `192.168.100.10` | `192.168.100.62` |
| `pc-red-b` | `192.168.100.74` | `192.168.100.126` |
| `router` | `.62` en A, `.126` en B | — (enruta entre redes) |

---

### Paso 1 — Levantar y aplicar rutas

**Aprende:** el script `montar-rutas.sh` pone en cada PC la ruta **default** hacia la IP del router en su subred.

**Levantar la maqueta:**

```bash
cd labs/M02/compose/dos-subredes
docker compose up -d
./montar-rutas.sh
```

**Acceder al sistema `pc-red-a`:**

```bash
docker compose exec -it pc-red-a bash
```

**Dentro del sistema `pc-red-a`:**

```bash
ip route show
```

**Deberías ver:** `default via 192.168.100.62 dev eth0`.

**Dentro del sistema:** `exit`

**Acceder al sistema `router`:**

```bash
docker compose exec -it router bash
```

**Dentro del sistema `router`:**

```bash
ip -4 addr show
sysctl net.ipv4.ip_forward
```

**Deberías ver:** dos interfaces (`eth0` en red A, `eth1` en red B) y `ip_forward = 1`.

**Dentro del sistema:** `exit`

---

### Paso 2 — Ping entre subredes (gateway correcto)

**Aprende:** si el destino no es “local”, el paquete va al **gateway**; el router reenvía hacia la otra subred.

**Acceder al sistema `pc-red-a`:**

```bash
docker compose exec -it pc-red-a bash
```

**Dentro del sistema `pc-red-a`:**

```bash
ping -c 3 192.168.100.74
```

**Deberías ver:** respuestas desde `pc-red-b` (IP `192.168.100.74`).

**Acceder al sistema `pc-red-b` (otra sesión o tras `exit`):**

```bash
docker compose exec -it pc-red-b bash
```

**Dentro del sistema `pc-red-b`:**

```bash
ping -c 3 192.168.100.10
```

**Deberías ver:** respuesta simétrica.

**Por qué:** cada PC envía al router de su LAN; el router tiene rutas a `192.168.100.0/26` y `192.168.100.64/26`.

**Dentro del sistema:** `exit`

---

### Paso 3 — Gateway incorrecto (debe fallar)

**Aprende:** si el default apunta a un equipo que **no enruta** hacia la otra subred, el `ping` inter-red no llega.

**Acceder al sistema `pc-red-a`:**

```bash
docker compose exec -it pc-red-a bash
```

**Dentro del sistema `pc-red-a`:**

```bash
ip route replace default via 192.168.100.20
ping -c 3 192.168.100.74
```

**Deberías ver:** timeouts o “Destination Host Unreachable” (no hay router en `.20`).

**Dentro del sistema `pc-red-a`:**

```bash
ip route replace default via 192.168.100.62
ping -c 2 192.168.100.74
```

**Deberías ver:** de nuevo respuestas correctas.

**Dentro del sistema:** `exit`

---

### Paso 4 — Ruta explícita sin default (opcional)

**Aprende:** además del default, puedes añadir rutas **más específicas** (`ip route add 192.168.100.64/26 via …`).

**Acceder al sistema `pc-red-a`:**

```bash
docker compose exec -it pc-red-a bash
```

**Dentro del sistema `pc-red-a`:**

```bash
ip route del default
ip route add 192.168.100.64/26 via 192.168.100.62
ping -c 2 192.168.100.74
ip route replace default via 192.168.100.62
exit
```

**Deberías ver:** el ping a red B funciona con la ruta específica aunque hayas quitado el default (solo hacia ese prefijo).

**En tu terminal (maqueta):** `docker compose down`

---

## Antes de seguir

### Pon el foco en

| Situación | Qué hace el host |
|-----------|------------------|
| Destino en mi subred | ARP + envío directo |
| Destino en otra subred | Envía al **gateway** de la ruta default (o ruta más específica) |
| Gateway mal configurado | Tráfico inter-red **no** llega aunque el router esté bien |

### Reto

**1. ¿Quién enruta?** — Desde `pc-red-a`, traza mentalmente: paquete a `192.168.100.74` → ¿MAC/IP del siguiente salto en la primera subred?

<details>
<summary>Ver solución</summary>

Capa 3: siguiente salto IP = gateway `192.168.100.62` (interfaz del router en red A). Capa 2: el frame va a la **MAC** de `eth0` del router en la LAN A (resuelta por ARP hacia `.62`).

</details>

**2. Sin ip_forward** — En `router`, desactiva reenvío y repite el ping desde `pc-red-a`.

<details>
<summary>Ver solución</summary>

**Acceder a `router`:** `docker compose exec -it router bash`

**Dentro del sistema:**

```bash
sysctl -w net.ipv4.ip_forward=0
```

**Acceder a `pc-red-a`:** `ping -c 2 192.168.100.74` (debe fallar)

**Dentro de `router`:** `sysctl -w net.ipv4.ip_forward=1`

Vuelve a probar el ping.

</details>

**3. Host nuevo en red B** — Añade `pc-red-c` (`192.168.100.80`), ejecuta `./montar-rutas.sh` (o gateway manual) y haz `ping` desde `pc-red-a`.

<details>
<summary>Ver solución</summary>

Añade el servicio en `docker-compose.yaml` con IP `192.168.100.80` en `red-b`.

Amplía `montar-rutas.sh` o **dentro de `pc-red-c`:**

```bash
ip route replace default via 192.168.100.126
```

**Desde `pc-red-a`:** `ping -c 2 192.168.100.80`

</details>
