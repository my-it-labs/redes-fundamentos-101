# Glosario de herramientas — Formación redes

Referencia rápida (cheat sheet) de las utilidades que usarás en los laboratorios. Enfocado en **qué hace**, **cuándo usarla** y **comandos habituales**.

Definiciones de conceptos (IP, MAC, tabla de rutas…): [Glosario de términos](glosario-terminos.md).

[← Volver al curso](../README.md)

---

## Índice

| Sección | Herramientas |
|---------|----------------|
| [Maqueta del laboratorio](#maqueta-del-laboratorio) | `docker`, `docker compose` |
| [Direccionamiento (`ip`)](#direccionamiento-ip) | `ip addr`, `ip route`, `ip link` |
| [Conectividad ICMP](#conectividad-icmp) | `ping`, `traceroute`, `tracepath` |
| [DNS](#dns) | `dig`, `host` |
| [Puertos y conexiones](#puertos-y-conexiones) | `ss`, `nc` |
| [HTTP y APIs](#http-y-apis) | `curl` |
| [NAT y filtrado](#nat-y-filtrado) | `iptables`, `conntrack` |
| [Por módulo](#uso-previsto-por-módulo) | Tabla resumen |

---

## Maqueta del laboratorio

### `docker` / `docker compose`

| | |
|--|--|
| **Qué es** | Comandos para **levantar** la maqueta del curso y **entrar** en cada sistema (PC, router). |
| **En el curso** | Levantar/parar la maqueta, abrir sesión en un sistema, desconectar un enlace (anillo). |

```bash
# Levantar la maqueta
cd labs/M01/compose/estrella
docker compose up -d

# Acceder al sistema pc-a
docker compose exec -it pc-a bash

# Dentro del sistema pc-a
ping -c 2 pc-b
ip -4 addr show
exit

# Parar la maqueta
docker compose down
```

**Importante:** `docker compose` solo en la **terminal del Codespace**. Dentro de `pc-a` (`root@pc-a:/#`) no existe `docker` — ahí van `ping`, `ip`, etc.

---

## Direccionamiento (`ip`)

Sustituye a `ifconfig` y `route` (obsoletos). Paquete: **iproute2**.

### `ip addr` — direcciones en interfaces

| | |
|--|--|
| **Qué hace** | Muestra o configura IPv4/IPv6 en interfaces. |
| **En el curso** | Ver IP privada del sistema, prefijo CIDR, varias NICs en routers. |

```bash
ip -4 addr show              # solo IPv4, todas las interfaces
ip -4 addr show eth0         # una interfaz
ip addr add 192.168.1.10/24 dev eth0   # añadir IP (labs, routers)
```

**Leer salida (resumen):**

| En la salida | Significado |
|--------------|-------------|
| `lo` + `127.0.0.1` | Loopback (solo el propio sistema). |
| `eth0` + `UP` | Interfaz de red activa. |
| `inet 172.31.10.3/24` | IPv4 + prefijo CIDR (máscara). |
| `brd 172.31.10.255` | Broadcast de la subred. |

Guía detallada la primera vez: [M01-01 — interpretar `ip -4 addr show`](../labs/M01/M01-01-tipos-redes-topologias.md).

---

### `ip route` — tabla de enrutamiento

| | |
|--|--|
| **Qué hace** | Define por dónde salen los paquetes según destino. |
| **En el curso** | Default gateway, rutas estáticas en anillo/malla/empresa (`montar-rutas.sh`). |

```bash
ip route show                    # tabla completa
ip route show default            # solo ruta por defecto
ip route get 192.168.30.10       # qué ruta usaría para ese destino
ip route add 192.168.20.0/24 via 10.255.0.12    # red específica vía gateway
ip route replace default via 192.168.10.254     # cambiar default (PC cliente)
ip route del 192.168.20.0/24                   # borrar ruta
```

**Conceptos:**

- `via <IP>` = siguiente salto (gateway).
- `default` = destino no coincide con ninguna red conectada → se envía al gateway.

---

### `ip link` — interfaces (enlace)

| | |
|--|--|
| **Qué hace** | Estado de interfaces (UP/DOWN), MAC. |
| **En el curso** | Comprobar que una interfaz existe antes de asignar IP. |

```bash
ip link show
ip link set eth0 up
```

---

## Conectividad ICMP

### `ping`

| | |
|--|--|
| **Qué hace** | Envía ICMP Echo (capa 3); prueba si hay respuesta hasta un host/IP. |
| **En el curso** | Casi todos los labs: estrella, empresa, NAT. |
| **No demuestra** | Que un puerto TCP/UDP funcione (solo llega el host). |

```bash
ping -c 4 pc-b              # 4 paquetes; nombre resuelto en la maqueta
ping -c 2 192.168.30.10     # por IP
ping -c 2 -W 3 10.10.2.3    # espera máx. 3 s por respuesta
```

**Leer salida (resumen):**

| En la salida | Significado |
|--------------|-------------|
| `0% packet loss` | Hay respuesta del destino. |
| `ttl=64` en misma LAN | Sin routers en medio. |
| `ttl=63` o menos | Al menos un salto L3 (router). |
| `100% packet loss` | Host caído, filtro ICMP o sin ruta. |
| `Destination Host Unreachable` | Sin ruta o gateway incorrecto. |

Guía detallada: [M01-01](../labs/M01/M01-01-tipos-redes-topologias.md) (pasos 1, 3 y 5).

---

### `traceroute` / `tracepath`

| | |
|--|--|
| **Qué hace** | Muestra los **saltos** (routers) hasta el destino. |
| **En el curso** | M03 (diagnóstico), comparar ruta LAN vs internet. |
| **Diferencia** | `tracepath` suele venir sin instalar extra; no requiere root en muchos casos. |

```bash
traceroute 8.8.8.8
traceroute -n 192.168.30.10    # -n = no resolver nombres (más rápido)
tracepath ejemplo.com
```

**Leer salida:** cada línea ≈ un router; `* * *` = ese salto no respondió (común con firewalls).

---

## DNS

### `dig`

| | |
|--|--|
| **Qué hace** | Consulta DNS con detalle (tipo de registro, servidor usado). |
| **En el curso** | M03 — registros A, AAAA, MX, CNAME. |

```bash
dig ejemplo.com                    # A por defecto
dig ejemplo.com AAAA
dig ejemplo.com MX
dig @8.8.8.8 ejemplo.com           # preguntar a un resolver concreto
dig +short ejemplo.com             # solo la respuesta
```

---

### `host`

| | |
|--|--|
| **Qué hace** | Consulta DNS simple (legible). |
| **En el curso** | Resolución rápida en M03. |

```bash
host ejemplo.com
host -t MX ejemplo.com
```

---

## Puertos y conexiones

### `ss`

| | |
|--|--|
| **Qué hace** | Sockets y puertos en escucha/conexión (reemplazo de `netstat`). |
| **En el curso** | M04 — qué servicio escucha en qué puerto. |

```bash
ss -tuln          # TCP/UDP, listening, numérico (sin resolver nombres)
ss -tunap         # + proceso (requiere root)
ss -tn state established   # conexiones TCP establecidas
```

**Columnas útiles:** `Local Address:Port` → `0.0.0.0:80` escucha en todas las interfaces; `127.0.0.1:8080` solo local.

---

### `nc` (netcat)

| | |
|--|--|
| **Qué hace** | Prueba TCP/UDP: escuchar o conectar a un puerto. |
| **En el curso** | M01-03 (port forwarding), M04 (cliente/servidor mínimo). |

```bash
# Servidor (escuchar)
nc -l -p 8080

# Cliente (enviar una línea)
echo hola | nc -w 2 10.200.100.254 8080
```

---

## HTTP y APIs

### `curl`

| | |
|--|--|
| **Qué hace** | Cliente HTTP/HTTPS; también descarga URLs simples. |
| **En el curso** | IP pública de salida (`ifconfig.me`), APIs, comprobar servicios web (M03+). |

```bash
curl -s ifconfig.me              # IP pública (sale por el host/NAT del entorno)
curl -s https://api.ipify.org
curl -I https://ejemplo.com      # solo cabeceras
curl -v http://192.168.1.10:80/  # verbose (útil para depurar)
```

**En labs:** el `curl` desde tu **terminal Codespace** ≠ IP del sistema dentro de la maqueta.

---

## NAT y filtrado

### `iptables`

| | |
|--|--|
| **Qué hace** | Reglas de filtrado y NAT en Linux (firewall + traducción). |
| **En el curso** | M01-03 — PAT (`MASQUERADE`) y port forwarding (`DNAT`). |

```bash
# Ver reglas NAT
iptables -t nat -L -n -v

# PAT: ocultar IPs internas al salir (típico en gateway)
iptables -t nat -A POSTROUTING -s 10.200.1.0/24 -j MASQUERADE

# Port forwarding: tráfico entrante al gateway → host interno
iptables -t nat -A PREROUTING -d 10.200.100.254 -p tcp --dport 8080 \
  -j DNAT --to-destination 10.200.1.50:8080
```

| Tabla | Cadena | Uso en el curso |
|-------|--------|-----------------|
| `nat` | `POSTROUTING` | PAT al salir (origen traducido) |
| `nat` | `PREROUTING` | DNAT al entrar (destino traducido) |

**Requisito:** en routers de la maqueta, permisos de administración de red y `ip_forward` activo (ya viene en el compose).

---

### `conntrack`

| | |
|--|--|
| **Qué hace** | Lista conexiones rastreadas (estado NAT). |
| **En el curso** | M01-03 — ver traducciones PAT (si el paquete está instalado). |

```bash
conntrack -L
conntrack -L | grep 10.200.100.10
```

Si no existe el comando, `iptables -t nat -L -n -v` (contadores) basta para el 101.

---

## Uso previsto por módulo

| Módulo | Herramientas principales |
|--------|---------------------------|
| **M01** | `docker compose`, `ip`, `ping`, `ip route`, `iptables`, `nc`, `curl` |
| **M02** | `ip addr`, `ip route`, CIDR (cálculo manual + `ip`), IPv6 (`ip -6 addr`) |
| **M03** | `dig`, `host`, `ping`, `traceroute`, `curl`, DHCP (cliente/daemon en compose) |
| **M04** | `ss`, `nc`, `curl` |
| **M05** | `iptables` (filtrado), `ss`, segmentación con Compose |
| **M06** | `ping`, `traceroute`, `ss` (mapear problema → capa) |
| **M07** | `ip`, `ping`, `iw` / `nmcli` (solo en host, si aplica) |
| **M08** | `ip`, `docker network`, varias redes = segmentos lógicos |

---

## Rangos RFC1918 (referencia cruzada)

No es una herramienta, pero lo usarás con `ip` y `ping` todo el curso:

| Rango | CIDR |
|-------|------|
| Clase A privada | `10.0.0.0/8` |
| Clase B privada | `172.16.0.0/12` |
| Clase C privada | `192.168.0.0/16` |

---

## Ayuda rápida en terminal

```bash
man ip
man ping
man iptables
ip help
ss -h
```

En cada sistema de la maqueta (`lab-host`): `iproute2`, `ping`, `curl`, `dig`, `iptables`, `nc` ya instalados.
