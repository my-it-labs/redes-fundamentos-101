# Laboratorio M04-01 — TCP, UDP y puertos

[← Página anterior](README.md) · [Siguiente página →](M04-02-sockets.md)

## Objetivo del laboratorio

Al terminar debes poder:

- Listar puertos en **escucha** con `ss -tuln` en el servidor.
- Probar un servicio **TCP** (HTTP en 8080) con `curl`.
- Enviar datagramas **UDP** al puerto 9999 con `nc`.

En cada paso: **levantar la maqueta** → **acceder al sistema** → comandos **dentro del sistema**.

Conceptos: [Glosario de términos](../../docs/glosario-terminos.md) (puerto, TCP/UDP) · Comandos: [Glosario de herramientas](../../docs/glosario-herramientas.md).

---

## Mapa mental (antes de tocar comandos)

```text
servidor (192.168.56.10)
  ├── TCP 8080  →  python3 http.server
  └── UDP 9999  →  socat (eco de datagramas)
cliente (192.168.56.20)
```

| Puerto | Protocolo | Servicio en la maqueta |
|--------|-----------|-------------------------|
| 8080 | TCP | HTTP de laboratorio |
| 9999 | UDP | Socat UDP-LISTEN |

---

### Paso 1 — Levantar y ver sockets en escucha

**Aprende:** un servidor **escucha** en una IP:puerto antes de aceptar conexiones (TCP) o recibir datagramas (UDP).

**Levantar la maqueta:**

```bash
cd labs/M04/compose/servicios
docker compose up -d
```

**Acceder al sistema `servidor`:**

```bash
docker compose exec -it servidor bash
```

**Dentro del sistema `servidor`:**

```bash
ss -tuln
```

**Deberías ver:** líneas con `0.0.0.0:8080` (TCP) y `0.0.0.0:9999` (UDP).

**Dentro del sistema:** `exit`

---

### Paso 2 — HTTP por TCP (curl)

**Aprende:** HTTP usa **TCP** confiable; `curl` establece la conexión, envía la petición y muestra la respuesta.

**Acceder al sistema `cliente`:**

```bash
docker compose exec -it cliente bash
```

**Dentro del sistema `cliente`:**

```bash
curl -s -o /dev/null -w "%{http_code}\n" http://192.168.56.10:8080/
curl -s http://192.168.56.10:8080/ | head -5
```

**Deberías ver:** código `200` y listado HTML del directorio servido por Python.

**Por qué:** el cliente abre socket TCP hacia `192.168.56.10:8080`; el servidor acepta y responde.

---

### Paso 3 — UDP con netcat

**Aprende:** **UDP** no garantiza entrega ni orden; cada `echo | nc -u` es un datagrama.

**Dentro del sistema `cliente`:**

```bash
echo hola-udp | nc -u -w 2 192.168.56.10 9999
```

**Deberías ver:** eco `hola-udp` (socat devuelve el contenido recibido).

Repite con otro mensaje:

```bash
echo prueba-m04 | nc -u -w 2 192.168.56.10 9999
```

**Dentro del sistema:** `exit`

---

### Paso 4 — Conexiones establecidas (TCP)

**Aprende:** mientras `curl` o `nc` TCP están activos, `ss -tn` muestra el estado **ESTAB**.

**Acceder al sistema `servidor`:**

```bash
docker compose exec -it servidor bash
```

En otra sesión de maqueta, desde `cliente`, deja una conexión larga (opcional) o repite `curl`.

**Dentro del sistema `servidor`:**

```bash
ss -tn state established
```

**Deberías ver:** entradas hacia `:8080` durante la petición HTTP.

**Dentro del sistema:** `exit`

**En tu terminal (maqueta):** `docker compose down`

---

## Antes de seguir

### Pon el foco en

| Protocolo | Característica | Ejemplo en el lab |
|-----------|----------------|-------------------|
| TCP | Confiable, conexión | HTTP 8080 |
| UDP | Sin conexión, bajo overhead | Eco 9999 |
| Puertos | Multiplexan servicios en una IP | `ss -tuln` |

### Reto

**1. Puerto TCP cerrado** — Desde `cliente`, `curl` a `http://192.168.56.10:9090/`.

<details>
<summary>Ver solución</summary>

**Dentro de `cliente`:**

```bash
curl -v --connect-timeout 2 http://192.168.56.10:9090/
```

**Deberías ver:** fallo de conexión (no hay listener en 9090).

</details>

**2. Clasifica puertos** — ¿8080 y 9999 son bien conocidos, registrados o dinámicos/ephemeral?

<details>
<summary>Ver solución</summary>

8080 es **alternativo** habitual para HTTP de prueba (a veces clasificado como registro HTTP alt). 9999 suele usarse como puerto de aplicación/lab, no es un “well-known” clásico como 80/443. Los puertos origen del cliente son **efímeros** (>1023 típicamente).

</details>

**3. Segundo servicio UDP** — Añade otro `socat UDP-LISTEN:9998` en el `command` del servidor y prueba desde el cliente.

<details>
<summary>Ver solución</summary>

Amplía el `command` en `docker-compose.yaml`, recrea el servicio, `ss -uln` debe mostrar 9998, y:

```bash
echo test | nc -u -w 2 192.168.56.10 9998
```

</details>
