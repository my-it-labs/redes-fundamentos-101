# Laboratorio M06-02 — TCP/IP frente a OSI

[← Página anterior](M06-01-modelo-osi.md) · [Siguiente página →](../M07/README.md)

## Objetivo del laboratorio

Al terminar debes poder:

- Comparar el **modelo OSI de 7 capas** con el **modelo TCP/IP de 4 capas**.
- Ubicar en ambos modelos los protocolos que ya usaste (`Ethernet`, IP, TCP, HTTP).
- Completar una tabla de equivalencias para explicar un incidente a un compañero.

No hace falta levantar maqueta en todos los pasos; el paso 2 usa la maqueta `capas` solo para anclar ejemplos reales.

---

### Paso 1 — Tabla comparativa (ejercicio en papel o editor)

**Aprende:** TCP/IP es el modelo **operativo** de internet; OSI es una referencia **pedagógica** muy usada en soporte y certificaciones.

**Haces:** copia la tabla y complétala con protocolos y herramientas del curso.

| OSI (7) | TCP/IP (4) | Protocolos / ejemplos del curso | Herramientas que “tocan” esa capa |
|---------|------------|----------------------------------|-----------------------------------|
| 7 Aplicación | 4 Aplicación | HTTP (`curl`), DNS (`dig` en M03) | `curl`, `dig` |
| 6 Presentación | — (dentro de aplicación) | TLS (concepto) | `curl -v` (negociación) |
| 5 Sesión | — (dentro de aplicación) | — | — |
| 4 Transporte | 3 Transporte | TCP, UDP (`socat` M04) | `ss`, `nc` |
| 3 Red | 2 Internet | IPv4, ICMP (`ping`) | `ip`, `ping` |
| 2 Enlace | 1 Acceso a red | Ethernet, ARP | `ip neigh`, `ip link` |
| 1 Física | 1 Acceso a red | Medio (cable, WiFi) | `ip link` (estado interfaz) |

**Deberías ver:** varias capas OSI colapsan en una sola capa TCP/IP (5–6–7 → Aplicación).

**Por qué:** en troubleshooting sueles pensar en **cuatro bloques**: enlace, internet, transporte, aplicación.

---

### Paso 2 — Mapear un flujo HTTP en la maqueta `capas`

**Aprende:** un mismo `curl` atraviesa las cuatro capas TCP/IP aunque solo veas la URL.

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
getent hosts servidor-web || ping -c 1 servidor-web
curl -sS -m 3 -o /dev/null -w "%{http_code}\n" http://servidor-web/
ip neigh show dev eth0
ss -tn state established | grep 80 || true
```

**Deberías ver:**

- Resolución de nombre (si el hostname responde en la maqueta) o alcance por IP.
- HTTP 200.
- Entrada ARP/MAC hacia el servidor.
- Socket TCP establecido hacia puerto 80 tras el `curl`.

**Por qué:** anota en la tabla del paso 1 **qué línea** corresponde a cada salida (ARP = acceso a red, IP = internet, TCP = transporte, HTTP = aplicación).

**Dentro del sistema:** `exit`

**En tu terminal (maqueta):** `docker compose down`

---

### Paso 3 — Preguntas de entrevista rápida

**Aprende:** preguntas típicas mezclan modelos; la respuesta corta usa TCP/IP, la larga puede citar OSI.

**Haces:** responde por escrito (sin maqueta):

1. ¿En qué capa vive una dirección IP?
2. ¿Y un puerto TCP?
3. ¿`ping` prueba HTTP?
4. ¿Un firewall que filtra por `--dport 8080` actúa como OSI capa 4 o 7?

**Deberías ver (solución conceptual):**

1. Capa 3 OSI / Internet TCP/IP.
2. Capa 4 OSI / Transporte TCP/IP.
3. No; ICMP es capa 3 (mensaje de control), no aplicación.
4. Capa 4 (transporte); filtrar por URL sería capa 7 (proxy/WAF).

**Por qué:** alinear vocabulario evita discusiones vacías (“capa 3” = IP, no “navegador”).

---

## Antes de seguir

### Pon el foco en

- OSI **no es un protocolo**; TCP/IP **sí** es la pila que implementas.
- En la práctica: “¿es routing, puerto o app?” mapea bien a TCP/IP.
- Certificaciones y documentación de fabricantes aún usan OSI; conviene traducir entre ambos.

### Reto

**1. Dibujo dual** — Dibuja una columna OSI y otra TCP/IP con flechas de alineación (1↔1, 2↔1, 3↔2, 4↔3, 5–7↔4).

<details>
<summary>Ver solución</summary>

Acceso a red (1–2 OSI) = enlace físico+lógico. Internet (3 OSI) = capa internet. Transporte (4) = transporte. Aplicación (5–7) = aplicación TCP/IP.

</details>

**2. Caso DMZ (M05)** — Clasifica “iptables FORWARD tcp dport 8080” y “curl desde atacante” en capas OSI y TCP/IP.

<details>
<summary>Ver solución</summary>

`iptables` filtro por puerto → OSI 4 / TCP/IP transporte (stateful también usa seguimiento de flujo). `curl` → OSI 7 / aplicación. La IP de destino en la regla → OSI 3.

</details>

**3. VLAN (adelanto M08)** — ¿En qué capa OSI está una VLAN 802.1Q? ¿Y en TCP/IP?

<details>
<summary>Ver solución</summary>

OSI capa 2 (enlace), etiqueta en tramas Ethernet. TCP/IP capa de acceso a red. No es capa 3 aunque afecte dominios de broadcast.

</details>
