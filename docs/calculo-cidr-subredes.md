# Cómo calcular rangos de IP con CIDR

Guía paso a paso para obtener **red**, **máscara**, **primer host**, **último host** y **broadcast** a partir de una notación como `192.168.50.0/26`.

**En el curso:** lo practicas en [M02-01 — CIDR y subredes](../labs/M02/M02-01-cidr-subredes.md). Aquí tienes el método completo antes de entrar al laboratorio.

---

## 1. Qué significa `192.168.50.0/26`

Una dirección IPv4 tiene **32 bits**, agrupados en cuatro números de 0 a 255:

```text
192 . 168 .  50 .   0
│     │      │     └── último octeto (8 bits)
│     │      └──────── tercer octeto
│     └─────────────── segundo octeto
└───────────────────── primer octeto
```

La parte **`/26`** (prefijo CIDR) dice:

- Los **26 primeros bits** identifican la **red** (todos los equipos de ese bloque comparten esos bits).
- Los **6 bits restantes** (32 − 26 = 6) identifican el **host** dentro de esa red.

| Parte | Bits en /26 | Para qué sirve |
|-------|-------------|----------------|
| Red | 26 | «En qué subred estoy» |
| Host | 6 | «Qué equipo soy dentro de la subred» |

**Regla rápida:** a más número después de la barra (`/28` > `/26` > `/24`), la subred es **más pequeña** (menos hosts).

---

## 2. Cuántas direcciones hay

Fórmula:

```text
Total de direcciones = 2^(bits de host)
Hosts asignables     = total − 2   (se reservan red y broadcast)
```

Para `/26`:

```text
Bits de host = 32 − 26 = 6
Total        = 2^6 = 64 direcciones
Asignables   = 64 − 2 = 62 hosts
```

Las dos reservadas:

| Dirección | Uso |
|-----------|-----|
| Primera del bloque (host = 0) | **Dirección de red** — identifica la subred, no se asigna a un PC |
| Última del bloque (host = todos 1) | **Broadcast** — mensaje a todos en la subred, no se asigna a un PC |

---

## 3. Máscara en formato «puntos» (255.255.255.x)

El prefijo `/26` equivale a poner **26 unos** y **6 ceros** en binario:

```text
/26  →  11111111.11111111.11111111.11000000
         255   .  255   .  255   .  192
```

**Truco:** solo cambian los octetos donde «corta» la línea entre red y host:

| Prefijo | Máscara | Bits de host | Total direcciones |
|---------|---------|--------------|-------------------|
| /24 | 255.255.255.0 | 8 | 256 |
| /25 | 255.255.255.128 | 7 | 128 |
| /26 | 255.255.255.192 | 6 | 64 |
| /27 | 255.255.255.224 | 5 | 32 |
| /28 | 255.255.255.240 | 4 | 16 |
| /29 | 255.255.255.248 | 3 | 8 |
| /30 | 255.255.255.252 | 2 | 4 |

En el curso verás mucho `/24` (LANs) y `/29` (enlaces punto a punto del anillo M01: 8 direcciones, 6 hosts útiles).

---

## 4. Método en cuatro pasos (sin calculadora binaria)

Ejemplo: **`192.168.50.0/26`**

### Paso A — Tamaño del bloque en el último octeto «afectado»

En `/26` la frontera cae en el **cuarto octeto** (los 26 bits cubren los tres primeros octetos completos + 2 bits del cuarto).

Bits de host en el cuarto octeto: 6 (todos en el último octeto en este caso).

```text
Tamaño del salto = 256 − máscara_del_octeto = 256 − 192 = 64
```

Los bloques en el cuarto octeto van de **64 en 64**: `.0`, `.64`, `.128`, `.192`.

### Paso B — Dirección de red

La IP dada es `192.168.50.0`. El cuarto octeto es `0`, que coincide con el inicio de un bloque → la red es **`192.168.50.0`**.

Si te dieran `192.168.50.70/26`:

- 70 está entre 64 y 127 → el bloque empieza en **`.64`**
- Red = **`192.168.50.64`** (no es la misma subred que `.0/26`).

### Paso C — Broadcast y última IP usable

```text
Broadcast     = siguiente bloque − 1  →  192.168.50.63
Última usable = broadcast − 1         →  192.168.50.62
Primera usable = red + 1              →  192.168.50.1
```

### Paso D — Tabla resumen

| Campo | Valor |
|-------|-------|
| Red | `192.168.50.0` |
| Máscara | `255.255.255.192` |
| Primera IP usable | `192.168.50.1` |
| Última IP usable | `192.168.50.62` |
| Broadcast | `192.168.50.63` |
| Hosts asignables | 62 |

---

## 5. Más ejemplos del curso

### `172.31.10.0/24` (estrella M01)

| Campo | Valor |
|-------|-------|
| Máscara | `255.255.255.0` |
| Salto en 4.º octeto | 256 |
| Red | `172.31.10.0` |
| Rango usable | `172.31.10.1` – `172.31.10.254` |
| Broadcast | `172.31.10.255` |
| Hosts asignables | 254 |

### `10.10.1.0/29` (anillo M01, enlace `ab`)

| Campo | Valor |
|-------|-------|
| Máscara | `255.255.255.248` |
| Salto en 4.º octeto | 8 |
| Red | `10.10.1.0` |
| Rango usable | `10.10.1.1` – `10.10.1.6` |
| Broadcast | `10.10.1.7` |
| Hosts asignables | 6 |

Por eso en el anillo las IPs van `.2`, `.3`… y el `.1` suele ser el gateway del bridge Docker.

### `192.168.100.0/26` y `192.168.100.64/26` (dos subredes M02-02)

Un `/24` partido en dos `/26`:

| Subred | Red | Rango usable |
|--------|-----|--------------|
| A | `192.168.100.0` | `.1` – `.62` |
| B | `192.168.100.64` | `.65` – `.126` |

`192.168.100.10` está en A; `192.168.100.74` está en B → hace falta **router** para que se hablen.

---

## 6. ¿Dos IPs están en la misma subred?

1. Calcula la **red** de cada IP con el mismo prefijo.
2. Si la red coincide → misma subred (ping directo, sin gateway).
3. Si no → subredes distintas (hace falta router).

Ejemplo: ¿`192.168.50.10/26` y `192.168.50.20/26`?

- Ambas caen en el bloque que empieza en `.0` → **misma subred** ✓

¿`192.168.50.10/26` y `192.168.50.70/26`?

- `.10` → red `192.168.50.0`
- `.70` → red `192.168.50.64` → **subredes distintas** ✗

---

## 7. Elegir el prefijo según cuántos hosts necesitas

Necesitas **al menos H hosts asignables**. Busca el prefijo cuyo `2^(bits host) − 2 ≥ H`.

| Necesitas (hosts) | Prefijo mínimo habitual | Hosts asignables |
|-------------------|-------------------------|------------------|
| 2–4 | /30 | 2 |
| 6 | /29 | 6 |
| 14 | /28 | 14 |
| 30 | /27 | 30 |
| 62 | /26 | 62 |
| 254 | /24 | 254 |

Ejemplo del reto M02-01: «solo 14 hosts» → `/28` (16 direcciones − 2 = **14** asignables).

---

## 8. Errores frecuentes

| Error | Corrección |
|-------|------------|
| Asignar la IP de **red** (`.0` en muchos casos) a un PC | Usar desde `.1` o la primera usable del bloque |
| Asignar el **broadcast** a un PC | Es la última del bloque; no es para hosts |
| Creer que `/26` y `/24` son la misma red | `/26` es un trozo **dentro** de un `/24`, no equivalente |
| Olvidar que el prefijo va **con** la IP | `10.10.1.2/29` y `10.10.1.2/24` son subredes diferentes |

---

## 9. Comprobar en Linux (después del cálculo)

Dentro de un contenedor del laboratorio:

```bash
ip -4 addr show
```

Línea típica:

```text
inet 192.168.50.10/26 brd 192.168.50.63 scope global eth0
```

| Campo en la salida | Qué debes reconocer |
|--------------------|---------------------|
| `192.168.50.10/26` | IP + prefijo que configuraste |
| `brd 192.168.50.63` | Broadcast que calculaste en la tabla |

Si el `brd` no coincide con tu cálculo, revisa el prefijo.

---

## 10. Resumen en una frase

**CIDR:** parte la IP en «red» + «host»; el número después de `/` dice cuántos bits son de red; el resto son hosts; del tamaño del bloque salen red, rango usable y broadcast.

---

## Referencias en este repositorio

- Laboratorio: [M02-01](../labs/M02/M02-01-cidr-subredes.md)
- Concepto breve: [Glosario — máscara y CIDR](glosario-terminos.md#máscara-de-red-y-cidr)
- Rangos privados (RFC 1918): [Glosario de herramientas — RFC1918](glosario-herramientas.md#rangos-rfc1918-referencia-cruzada)
