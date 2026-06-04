# Laboratorio M01-01 — Tipos de redes y topologías

[← Página anterior](README.md) · [Siguiente página →](M01-02-ip-publica-privada.md)

## Objetivo del laboratorio

Al terminar debes poder:

- Relacionar **estrella, bus, anillo y malla** con comportamiento real de conectividad (no solo el dibujo).
- Explicar qué cambia cuando **cae un nodo** o **se rompe un enlace**, y por qué.
- Clasificar tramos como **LAN o WAN** en un escenario con varias sedes.

Montarás cada topología con la maqueta del módulo. El diagrama está en el `docker-compose.yaml` de cada carpeta; tu trabajo es **levantarla, probarla y razonar sobre lo que ves**.

---

## Antes de empezar

**Aprende:** la maqueta simula redes con varios **sistemas** (PCs, routers). En cada paso van por separado: (1) levantar la maqueta, (2) entrar en un sistema, (3) ejecutar ahí `ping`, `ip`, etc.

**Haces (una vez):** preparar la imagen de los equipos del laboratorio:

```bash
docker build -t lab-host:local -f labs/_infra/Dockerfile.lab-host labs/_infra
```

Índice de maquetas: [compose/README.md](compose/README.md).  
Si necesitas definiciones (IP, interfaz, tabla de rutas, MAC…): [Glosario de términos](../../docs/glosario-terminos.md).

En todos los pasos: **levantar la maqueta** → **acceder al sistema** → comandos **dentro del sistema**. Desde tu terminal del Codespace también paras o reinicias la maqueta y ejecutas los scripts de montaje.

**Si falla:** la maqueta no arranca → usa **Codespace** (recomendado) o comprueba que tu entorno pueda ejecutar `docker compose`.

---

### Paso 1 — Topología en estrella

**Aprende:** en una estrella, los nodos no hablan entre sí directamente; dependen de un **punto central** (switch/hub). En la maqueta, ese centro es la red `estrella`.

**Haces:** levantar cuatro PCs en el mismo segmento y comprobar que se alcanzan por nombre (`pc-b`, `pc-d`).

**Levantar la maqueta:**

```bash
cd labs/M01/compose/estrella
docker compose up -d
```

**Acceder al sistema `pc-a`:**

```bash
docker compose exec -it pc-a bash
```

**Dentro del sistema `pc-a`:**

```bash
ip -4 addr show
ping -c 2 pc-b
ping -c 2 pc-d
```

**Deberías ver:**

- Una interfaz con IP en `172.31.10.0/24` (privada).
- `ping` con 0 % de pérdida hacia `pc-b` y `pc-d`.

**Por qué:** al estar en la **misma red L2**, no hace falta router: el switch de la maqueta reenvía tramas entre equipos como en una LAN.

**Haces (fallo de nodo):** deja abierta la sesión en `pc-a` (o vuelve a entrar con `docker compose exec -it pc-a bash`). En **otra terminal** (Codespace, fuera del sistema) apaga un extremo:

**En tu terminal (maqueta):**

```bash
docker compose stop pc-c
```

**Dentro del sistema `pc-a`:**

```bash
ping -c 2 pc-b
ping -c 2 pc-c
```

**Deberías ver:**

- `pc-a` → `pc-b`: **sigue funcionando** (el tercero caído no bloquea a los demás en L2).
- `pc-a` → `pc-c`: **no responde** (el nodo está parado).

**Por qué:** en estrella L2, la caída de **un extremo** aísla solo a ese nodo; el centro de la maqueta sigue activo. En la vida real, si cae el **switch central**, caerían todos; en este paso no apagamos ese centro.

**En tu terminal (maqueta):**

```bash
docker compose start pc-c
docker compose down
```

---

### Paso 2 — Topología en bus (medio compartido)

**Aprende:** en un bus clásico, todos comparten **un mismo medio**; un fallo en el cable troncal puede partir la red en dos. En la maqueta no hay cable físico, pero sí un **único dominio de broadcast** — a nivel L2 el comportamiento es parecido al de la estrella de este laboratorio.

**Haces:** misma prueba de conectividad y misma caída de un nodo intermedio.

**Levantar la maqueta:**

```bash
cd ../bus
docker compose up -d
```

**Acceder al sistema `nodo-1`:**

```bash
docker compose exec -it nodo-1 bash
```

**Dentro del sistema `nodo-1`:**

```bash
ping -c 2 nodo-4
```

**En tu terminal (maqueta):** `docker compose stop nodo-2`

**Dentro del sistema `nodo-1`:**

```bash
ping -c 2 nodo-4
exit
```

**En tu terminal (maqueta):** `docker compose down`

**Deberías ver:** con `nodo-2` parado, `nodo-1` **sigue llegando a `nodo-4`** (en este emulador L2).

**Por qué:** la maqueta une todos los equipos al mismo segmento L2; apagar un sistema no “corta el bus” entre los demás. En un bus **físico** antiguo, un corte en el tramo central sí dejaría sin comunicación a varios equipos — esa diferencia es importante: **la maqueta enseña L2 compartido; el dibujo de bus enseña el riesgo del medio único en cable coaxial/Ethernet viejo**.

**Contraste con el paso 1:** misma observación en ping, distinto **significado en diseño**: estrella concentra fallos en el centro; bus concentra fallos en el **medio**.

---

### Paso 3 — Topología en anillo

**Aprende:** en un anillo, el tráfico entre nodos no vecinos debe **atravesar intermediarios** (capa 3 o reenvío). Por eso hace falta **enrutamiento** además de cables lógicos.

**Haces:** levantar cuatro nodos, cada uno en **dos redes** (dos interfaces), y aplicar rutas con el script.

**Levantar la maqueta:**

```bash
cd ../anillo
docker compose up -d
./montar-rutas.sh
```

**Acceder al sistema `nodo-a`:**

```bash
docker compose exec -it nodo-a bash
```

**Dentro del sistema `nodo-a`:**

```bash
ping -c 2 10.10.2.3
```

**Deberías ver:** respuesta desde `10.10.2.3` (es `nodo-c`), con TTL 63 o similar (cruza saltos).

**Por qué:** `nodo-a` no está en el mismo segmento L2 que `nodo-c`; el paquete va **a → b → c** (o al revés) gracias a `ip_forward` y las rutas estáticas del script.

**Haces (romper el anillo):** quita a `nodo-b` del segmento `bc` — es como cortar un tramo del anillo:

**En tu terminal (maqueta):**

```bash
docker network disconnect anillo_bc nodo-b
```

**Dentro del sistema `nodo-a`** (misma sesión o vuelve a entrar con `exec`):

```bash
ping -c 2 10.10.2.3
```

**Deberías ver:** el `ping` **deja de funcionar** (timeout o unreachable).

**Por qué:** sin `nodo-b` en `bc`, no hay camino L3 entre el tramo `ab` y el tramo `bc`. El anillo deja de ser cerrado.

**Haces (restaurar):**

**En tu terminal (maqueta):**

```bash
docker network connect anillo_bc nodo-b
./montar-rutas.sh
docker compose down
```

---

### Paso 4 — Malla parcial (triángulo)

**Aprende:** una malla tiene **varios caminos** entre nodos; si uno falla, otro puede servir (si las rutas lo permiten). Aquí hay tres sedes y tres enlaces — un triángulo.

**Haces:**

**Levantar la maqueta:**

```bash
cd ../malla
docker compose up -d
./montar-rutas.sh
```

**Acceder al sistema `sede-1`:**

```bash
docker compose exec -it sede-1 bash
```

**Dentro del sistema `sede-1`:**

```bash
ping -c 2 10.20.2.3
ip route get 10.20.2.3
exit
```

**En tu terminal (maqueta):** `docker compose down`

**Deberías ver:**

- Ping correcto hacia `sede-3` (`10.20.2.3`).
- `ip route get` muestra **un** siguiente salto (p. ej. vía `10.20.1.3` = `sede-2`), según las rutas que instaló el script.

**Por qué:** aunque existan caminos alternativos en el dibujo, cada nodo usa la **tabla de rutas que tiene configurada**. La malla “de verdad” en producción reparte o conmuta por varios enlaces; en este 101 ves que **tener cables de más no basta sin rutas o protocolos que los usen**.

---

### Paso 5 — LAN, WAN y sedes (empresa)

**Aprende:** clasificar redes por **alcance y quién las administra**, no por el protocolo. Una LAN es un dominio local (oficina, sucursal); una WAN une sitios lejanos (aquí simulamos MPLS con la red `wan-mpls`).

**Haces:** levantar oficina + dos sucursales + routers; comprobar reachability entre sedes.

**Levantar la maqueta:**

```bash
cd ../empresa
docker compose up -d
./montar-rutas.sh
```

**Acceder al sistema `pc-oficina`:**

```bash
docker compose exec -it pc-oficina bash
```

**Dentro del sistema `pc-oficina`:**

```bash
ping -c 2 192.168.30.10
exit
```

**Deberías ver:** ping OK desde la oficina al PC de sucursal 2 (`192.168.30.10`), TTL bajando (atraviesa gateways).

**Por qué:** cada `lan-*` es una LAN distinta (subred privada). Los `gw-*` tienen **dos interfaces**: una en su LAN y otra en `wan-mpls`. El tráfico entre `192.168.10.0/24` y `192.168.30.0/24` sale de la LAN, entra en la WAN simulada y entra en la otra LAN.

Completa la tabla (no hay una sola respuesta “de libro” en la última columna; debe ser **coherente**):

| Red (maqueta) | Tipo (LAN / WAN) | ¿Por qué? |
|------------|------------------|-----------|
| `lan-oficina` | | |
| `lan-sucursal-1` | | |
| `lan-sucursal-2` | | |
| `wan-mpls` | | |

**Pistas para razonar:**

- Las tres `lan-*` son redes locales de cada sitio (RFC1918, ámbito limitado).
- `wan-mpls` no es la LAN de usuarios: es el **transporte entre routers** (en producción: operador/MPLS; aquí: la red WAN simulada).

**En tu terminal (maqueta):** `docker compose down`

---

## Antes de seguir

### Pon el foco en

- **Topología** = quién conecta con quién y qué pasa cuando algo se rompe, no solo la forma del dibujo.
- **L2** (un solo segmento): `ping` por nombre, sin rutas extra.
- **L3** (anillo, malla, empresa): hace falta **router** (`ip_forward` + rutas).

### Reto

**1. Quinto equipo en la estrella** — Añade el sistema `pc-e` a la red estrella (misma idea que `pc-a`…`pc-d`) y comprueba que el resto le hace `ping`.

<details>
<summary>Ver solución</summary>

Edita `labs/M01/compose/estrella/docker-compose.yaml` y añade:

```yaml
  pc-e:
    image: lab-host:local
    hostname: pc-e
    networks:
      estrella:
```

**Levantar la maqueta:** `cd labs/M01/compose/estrella` y `docker compose up -d`

**Acceder a `pc-a`:** `docker compose exec -it pc-a bash`

**Dentro de `pc-a`:** `ping -c 2 pc-e`

Misma red L2: no hace falta script de rutas. Si falla el nombre, accede a `pc-e`, mira la IP con `ip -4 addr show`, vuelve a `pc-a` y haz ping por IP.

</details>

**2. Nuevo puesto en la oficina** — En la maqueta `empresa`, añade un PC en `lan-oficina` con IP `192.168.10.50` y haz que la oficina central llegue a una sucursal **desde ese PC nuevo** (no solo desde `pc-oficina`).

<details>
<summary>Ver solución</summary>

En `labs/M01/compose/empresa/docker-compose.yaml`:

```yaml
  pc-inventario:
    image: lab-host:local
    hostname: pc-inventario
    cap_add:
      - NET_ADMIN
    networks:
      lan-oficina:
        ipv4_address: 192.168.10.50
```

**Levantar la maqueta:** `cd labs/M01/compose/empresa`, `docker compose up -d`, `./montar-rutas.sh`

**Acceder a `pc-inventario`:** `docker compose exec -it pc-inventario bash`

**Dentro de `pc-inventario`:**

```bash
ip route replace default via 192.168.10.254
ping -c 2 192.168.30.10
```

Usas el mismo gateway y rutas que ya configuró `montar-rutas.sh` para el resto de la sede.

</details>

**3. Cerrar el anillo otra vez** — Con el anillo levantado, repite el corte (`disconnect` de `nodo-b` en `anillo_bc`), confirma que cae el `ping` de `nodo-a` a `10.10.2.3`, y **restaura** la conectividad sin recrear el compose.

<details>
<summary>Ver solución</summary>

**Levantar la maqueta:** `cd labs/M01/compose/anillo`, `up -d`, `./montar-rutas.sh`

**Acceder a `nodo-a`:** `docker compose exec -it nodo-a bash`

**Dentro de `nodo-a`:** `ping -c 2 10.10.2.3` (debe funcionar)

**Maqueta:** `docker network disconnect anillo_bc nodo-b`

**Dentro de `nodo-a`:** `ping -c 2 10.10.2.3` (debe fallar)

**Maqueta:** `docker network connect anillo_bc nodo-b`, `./montar-rutas.sh`

**Dentro de `nodo-a`:** `ping -c 2 10.10.2.3` (debe volver)

**Maqueta:** `docker compose down`

</details>
