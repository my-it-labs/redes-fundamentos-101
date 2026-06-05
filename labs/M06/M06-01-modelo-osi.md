# Laboratorio M06-01 — Modelo OSI en un fallo real

[← Página anterior](../M05/README.md) · [Siguiente página →](M06-02-tcpip-vs-osi.md)

## Objetivo del laboratorio

Al terminar debes poder:

- Asociar **`ping`**, **`ip`**, **`ss`** y **`curl`** con la **capa OSI** (o TCP/IP) que están probando.
- Acotar un fallo: ¿es enlace, red, transporte o aplicación?
- Leer un escenario “HTTP no funciona pero la red responde” sin mezclar capas.

En cada paso: **levantar la maqueta** → **acceder al sistema** → comandos **dentro del sistema**.

Conceptos: [Glosario de términos](../../docs/glosario-terminos.md) · Comandos: [Glosario de herramientas](../../docs/glosario-herramientas.md).

---

### Paso 1 — Línea base: todo funciona

**Aprende:** cuando el servicio responde, puedes recorrer de abajo arriba: L2 (vecino), L3 (IP), L4 (puerto), L7 (HTTP).

#### Maqueta `compose/capas` — qué levantas

| Qué aparece | Detalle |
|-------------|---------|
| **Sistemas** | `servidor-web` (HTTP :80), `cliente-capas` |
| **Red** | `capas` → `192.168.57.0/24` |
| **IPs** | Servidor `.10`, cliente `.20` |
| **Uso** | Diagnosticar fallos capa por capa (`ping` → `ss` → `curl`) |

```mermaid
flowchart LR
  CLI[cliente-capas .20] -->|"L3 ping / L4 puerto / L7 curl"| SRV[servidor-web .10 :80]
```

**Levantar la maqueta:**

```bash
cd labs/M06/compose/capas
docker compose up -d
```

**Acceder al sistema `cliente-capas`:**

```bash
docker compose exec -it cliente-capas bash
```

**Dentro del sistema `cliente-capas`:**

```bash
ip -4 addr show
ping -c 2 192.168.57.10
ip neigh show
ss -tn | head -5
curl -sS -m 3 -o /dev/null -w "%{http_code}\n" http://192.168.57.10/
```

**Deberías ver:**

- IP propia en `192.168.57.0/24`.
- `ping` con 0 % pérdida hacia `192.168.57.10`.
- Entrada de vecino (MAC) hacia el servidor tras el ping.
- `curl` con código **200**.

**Por qué:**

| Comando | Capa principal | Qué valida |
|---------|----------------|------------|
| `ip -4 addr` | 3 (Red) | Direccionamiento local |
| `ping` / `ip neigh` | 2–3 | Alcance IP y resolución MAC en el segmento |
| `ss -tn` | 4 (Transporte) | Sockets TCP locales (antes/después de `curl`) |
| `curl` | 7 (Aplicación) | HTTP sobre TCP |

**Dentro del sistema:** `exit`

---

### Paso 2 — Fallo en capa de aplicación (servidor parado)

**Aprende:** si L3 responde pero L7 no, no “arregles rutas”; mira el proceso que escucha.

**En tu terminal (maqueta):**

```bash
docker compose stop servidor-web
```

**Acceder al sistema `cliente-capas`:**

```bash
docker compose exec -it cliente-capas bash
```

**Dentro del sistema `cliente-capas`:**

```bash
ping -c 2 192.168.57.10
curl -sS -m 3 http://192.168.57.10/ || echo "curl falló"
nc -z -w2 192.168.57.10 80 && echo "puerto abierto" || echo "puerto cerrado"
```

**Deberías ver:**

- `ping` **OK** (la red L3 sigue viva).
- `curl` **falla** (conexión rechazada o timeout).
- `nc` indica puerto **cerrado**.

**Por qué:** el diagnóstico se queda en **transporte/aplicación** (nada escucha en 80), no en cable ni IP.

**Dentro del sistema:** `exit`

**En tu terminal (maqueta):** `docker compose start servidor-web`

---

### Paso 3 — Fallo en capa de red (destino incorrecto)

**Aprende:** un error tipográfico en IP falla antes que HTTP; `ping` es la prueba rápida de alcance L3.

**Acceder al sistema `cliente-capas`:**

```bash
docker compose exec -it cliente-capas bash
```

**Dentro del sistema `cliente-capas`:**

```bash
ping -c 2 192.168.57.99
curl -sS -m 3 http://192.168.57.99/ || echo "curl falló"
```

**Deberías ver:**

- `ping` sin respuesta (host inexistente en la subred).
- `curl` falla sin llegar a negociar HTTP.

**Por qué:** no tiene sentido revisar DNS ni cabeceras HTTP si la IP no pertenece a un host activo en el segmento.

**Dentro del sistema:** `exit`

---

### Paso 4 — Fallo en transporte (puerto equivocado)

**Aprende:** la IP puede ser correcta y aun así el servicio no estar en el puerto esperado.

**Acceder al sistema `servidor-web`:**

```bash
docker compose exec -it servidor-web bash
```

**Dentro del sistema `servidor-web`:**

```bash
ss -tlnp | grep -E '80|8080'
exit
```

**Acceder de nuevo a `cliente-capas`:**

```bash
docker compose exec -it cliente-capas bash
```

**Dentro del sistema `cliente-capas`:**

```bash
ping -c 1 192.168.57.10
curl -sS -m 3 -o /dev/null -w "%{http_code}\n" http://192.168.57.10:8080/ || echo "8080 falló"
curl -sS -m 3 -o /dev/null -w "%{http_code}\n" http://192.168.57.10/ || echo "80 OK o falló"
```

**Deberías ver:**

- `ping` OK.
- Servidor escuchando en **80** (no en 8080 salvo que lo cambies).
- `curl` al puerto correcto **200**; al **8080** falla.

**Por qué:** TCP debe encontrar un listener; es capa **4**, aunque el síntoma lo veas con `curl` (capa 7).

**Dentro del sistema:** `exit`

**En tu terminal (maqueta):** `docker compose down`

---

## Antes de seguir

### Pon el foco en

- Diagnóstico **de abajo arriba**: ¿hay IP? ¿hay vecino/MAC? ¿abre el puerto? ¿responde la app?
- Un solo comando rara vez “prueba todo el OSI”; combina herramientas.
- En tickets reales, separar “no hay red” de “no hay servicio” ahorra tiempo.

### Reto

**1. Ficha de capas** — Para el escenario del paso 2 (servidor parado), rellena: síntoma, comando que lo demuestra, capa OSI, siguiente paso de reparación.

<details>
<summary>Ver solución</summary>

Síntoma: HTTP no carga. `ping` OK → capas 2–3 bien. `nc`/`curl` puerto 80 cerrado → capa 4–7. Reparación: levantar el proceso (`docker compose start servidor-web` o reiniciar el listener en el servidor).

</details>

**2. Orden de comandos** — Si un usuario dice “no entra a la web”, ordena: `ping`, `ip route`, `nc -z IP 80`, `curl -v`. Justifica el orden por capas.

<details>
<summary>Ver solución</summary>

Primero alcance L3 (`ping`, rutas con `ip route`). Luego puerto TCP (`nc`). Por último HTTP (`curl -v` muestra TLS/cabeceras si aplica). Saltar a `curl` sin `ping` mezcla síntomas de capas distintas.

</details>
