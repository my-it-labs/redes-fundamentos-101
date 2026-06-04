# Glosario de términos — Formación redes

Definiciones breves de los conceptos que aparecen en los laboratorios. Para **comandos**, usa el [Glosario de herramientas](glosario-herramientas.md).

[← Volver al curso](../README.md)

---

## Índice

| Bloque | Términos |
|--------|----------|
| [Identificación y enlace](#identificación-y-enlace-capas-1–2) | Interfaz, MAC, segmento L2, broadcast |
| [Direccionamiento y rutas](#direccionamiento-y-rutas-capa-3) | IP, privada/pública, máscara/CIDR, gateway, tabla de enrutamiento |
| [Tipos y formas de red](#tipos-y-formas-de-red) | LAN, WAN, topologías |
| [Dispositivos](#dispositivos) | Switch, router |
| [Traducción y filtrado](#traducción-y-filtrado) | NAT, PAT, port forwarding |
| [Servicios y capas superiores](#servicios-y-capas-superiores) | Puerto, DNS, TCP/UDP, VLAN, OSI |
| [Por módulo](#dónde-aparece-cada-módulo) | Tabla resumen |

---

## Identificación y enlace (capas 1–2)

### Interfaz de red

| | |
|--|--|
| **Qué es** | El “puerto” por el que un sistema se conecta a una red: tarjeta física, virtual o de la maqueta (`eth0`, `eth1`…). |
| **Para qué sirve** | Cada interfaz puede tener su propia IP, MAC y estado (activa / caída). Un router suele tener **varias** (una por LAN o enlace). |
| **En el curso** | `ip -4 addr show`, `ip link show` dentro de un sistema. |
| **Comandos** | [Glosario de herramientas → `ip addr` / `ip link`](glosario-herramientas.md#direccionamiento-ip) |

---

### Dirección MAC

| | |
|--|--|
| **Qué es** | Identificador **físico/lógico de enlace** (48 bits, p. ej. `aa:bb:cc:dd:ee:ff`). Va en las tramas de capa 2. |
| **Para qué sirve** | Entregar tráfico **en el mismo segmento** (misma LAN L2). Los switches aprenden qué MAC está en cada puerto. |
| **No confundir con** | Una **IP** (capa 3): la MAC no enruta entre redes distintas sin pasar por un router. |
| **En el curso** | Implícita en LAN de la maqueta; explícita en M07 (tabla MAC del switch). |

---

### Segmento L2 / misma LAN (broadcast)

| | |
|--|--|
| **Qué es** | Conjunto de equipos que comparten un medio tal que un broadcast L2 los alcanza a todos (misma “red local” de enlace). |
| **Para qué sirve** | Si dos sistemas están en el mismo segmento, pueden hacerse `ping` por IP **sin router** entre medias. |
| **En el curso** | Topología estrella y bus de M01-01; una red de la maqueta ≈ un segmento. |

---

## Direccionamiento y rutas (capa 3)

### Dirección IP (IPv4)

| | |
|--|--|
| **Qué es** | Identificador lógico (32 bits en IPv4, p. ej. `192.168.1.50`) para enviar paquetes entre redes. |
| **Para qué sirve** | El enrutamiento y los servicios (web, correo, etc.) usan IP de origen y destino. |
| **En el curso** | Todos los módulos; primera lectura en M01-02. |

---

### IP privada y pública

| | |
|--|--|
| **IP privada** | Rango reservado para uso interno (RFC1918: `10/8`, `172.16/12`, `192.168/16`). No se enruta en internet global. |
| **IP pública** | Dirección única en internet (o en la red externa de un operador). |
| **Para qué sirve** | Millones de equipos usan la misma IP privada en LAN distintas; **NAT** permite salir a internet con pocas IP públicas. |
| **En el curso** | M01-02, M01-03. |

---

### Máscara de red y CIDR

| | |
|--|--|
| **Qué es** | Indica qué parte de la IP es **red** y qué parte es **host**. Se escribe como máscara (`255.255.255.0`) o prefijo CIDR (`/24`). |
| **Para qué sirve** | Saber si dos IP están en la **misma subred** y cuántos hosts caben. |
| **En el curso** | M02 (cálculo de subredes); en M01 verás el prefijo en `ip addr` (p. ej. `172.31.10.2/24`). |

---

### Gateway (puerta de enlace)

| | |
|--|--|
| **Qué es** | Router o equipo al que un host envía el tráfico **cuyo destino no está en su subred local** (ruta por defecto). |
| **Para qué sirve** | Salir de la LAN hacia otras redes o hacia internet. |
| **En el curso** | `gw-oficina`, `gateway-nat`; `ip route show default`. |
| **Comandos** | [Glosario → `ip route`](glosario-herramientas.md#direccionamiento-ip) |

---

### Tabla de enrutamiento

| | |
|--|--|
| **Qué es** | Lista de reglas en un sistema o router: “si el destino coincide con esta red, envía el paquete **por esta interfaz** o **hacia esta IP siguiente**”. |
| **Partes típicas** | Destino (red o `default`), siguiente salto (`via`), interfaz de salida. |
| **Para qué sirve** | Decidir el camino de cada paquete. Sin ruta correcta, verás `Destination Host Unreachable` o timeout. |
| **En el curso** | Anillo, malla y empresa (M01-01); `montar-rutas.sh` instala rutas estáticas; tú las ves con `ip route show` y `ip route get`. |
| **Comandos** | [Glosario → `ip route`](glosario-herramientas.md#direccionamiento-ip) |

---

### Ruta por defecto (`default`)

| | |
|--|--|
| **Qué es** | Entrada de la tabla de enrutamiento para **todo** destino que no encaje en otra ruta más específica. |
| **Para qué sirve** | “Internet o el resto del mundo sale por este gateway” (`0.0.0.0/0` o `default via …`). |
| **En el curso** | Clientes de `nat-pat`, PCs de empresa tras `montar-rutas.sh`. |

---

### ICMP y `ping`

| | |
|--|--|
| **Qué es** | Protocolo de **control y diagnóstico** (capa 3). `ping` usa mensajes Echo Request/Reply. |
| **Para qué sirve** | Comprobar si hay camino hasta un host y latencia aproximada. **No** prueba puertos TCP/UDP de aplicaciones. |
| **En el curso** | Casi todos los laboratorios de conectividad. |
| **Comandos** | [Glosario → `ping`](glosario-herramientas.md#conectividad-icmp) |

---

## Tipos y formas de red

### LAN, WAN, MAN, PAN

| Término | Alcance habitual |
|---------|------------------|
| **LAN** | Red local de un sitio (oficina, casa, laboratorio). |
| **WAN** | Une sitios lejanos (operador, MPLS, internet entre sedes). |
| **MAN** | Ciudad o campus grande. |
| **PAN** | Alrededor de una persona (Bluetooth, USB tethering). |

**En el curso:** clasificación en M01-01 (empresa) y reflexión sobre tu Codespace en M01-02.

---

### Topología (estrella, bus, anillo, malla)

| | |
|--|--|
| **Qué es** | Forma **lógica o física** de cómo se interconectan los nodos, no el protocolo. |
| **Estrella** | Todos cuelgan de un punto central; fallo del centro aísla muchos. |
| **Bus** | Medio compartido; un corte en el troncal puede partir la red. |
| **Anillo** | Cada nodo enlaza con dos vecinos; suele hacer falta **enrutamiento** entre saltos. |
| **Malla** | Varios caminos; más tolerancia a fallos si hay rutas alternativas. |
| **En el curso** | M01-01 (maquetas estrella, bus, anillo, malla). |

---

## Dispositivos

### Switch

| | |
|--|--|
| **Qué es** | Equipo de **capa 2** que reenvía tramas según **MAC** dentro de una LAN. |
| **Para qué sirve** | Conectar muchos hosts en la misma red local sin repetir el dominio de broadcast en cada puerto (dominio de collision en hubs antiguos). |
| **En el curso** | Modelado por el segmento L2 de la maqueta; M07 profundiza en tabla MAC. |

---

### Router

| | |
|--|--|
| **Qué es** | Equipo que **enruta** paquetes entre **redes IP distintas** (decisiones por tabla de rutas). |
| **Para qué sirve** | Unir LANs, conectar a WAN o internet, aplicar NAT y políticas. |
| **En el curso** | `gw-oficina`, `gateway-nat`, nodos del anillo con `ip_forward`. |
| **No confundir con** | Un switch (solo L2) ni con “router WiFi doméstico” que a veces hace también switch y NAT. |

---

## Traducción y filtrado

### NAT (Network Address Translation)

| | |
|--|--|
| **Qué es** | Cambiar direcciones (y a menudo puertos) IP al cruzar un límite, típicamente LAN → internet. |
| **Para qué sirve** | Compartir una o pocas IP públicas entre muchos equipos privados. |
| **En el curso** | M01-03 (`MASQUERADE`, `DNAT`). |

---

### PAT (NAT sobrecarga / NAPT)

| | |
|--|--|
| **Qué es** | Varias IP privadas comparten **una** IP pública; se distinguen por **puerto** traducido. |
| **Para qué sirve** | Patrón habitual en hogar y oficinas para navegación saliente. |
| **En el curso** | Maqueta `nat-pat`; lo comparas con `curl ifconfig.me` en el Codespace. |

---

### Port forwarding (NAT estático de puerto)

| | |
|--|--|
| **Qué es** | Regla fija: tráfico entrante a `IP_pública:puerto` se redirige a un **servicio interno** concreto. |
| **Para qué sirve** | Exponer un servidor, cámara o servicio interno hacia fuera. |
| **Riesgo** | Abre un servicio; no sustituye un firewall que inspeccione aplicaciones. |
| **En el curso** | M01-03 (regla `DNAT` en `gateway-nat`). |

---

## Servicios y capas superiores

### Puerto (TCP / UDP)

| | |
|--|--|
| **Qué es** | Número (0–65535) que identifica **qué aplicación** atiende el tráfico en un host (`:80`, `:443`). |
| **Para qué sirve** | Una misma IP puede ofrecer muchos servicios; el puerto desambigua. |
| **En el curso** | M04; ya lo usas en PAT y `nc` (M01-03). |

---

### DNS

| | |
|--|--|
| **Qué es** | Sistema que traduce **nombres** (`ejemplo.com`) a **IP**. |
| **Para qué sirve** | No memorizar IP; balanceo y cambios de servidor. |
| **En el curso** | M03 (`dig`, `host`). En la maqueta, los nombres `pc-a`, `pc-b` se resuelven dentro del laboratorio. |

---

### TCP y UDP

| | |
|--|--|
| **TCP** | Conexión fiable, ordenada (web, SSH, correo…). |
| **UDP** | Sin conexión, más ligero (DNS, VoIP, algunos juegos). |
| **En el curso** | M04. |

---

### VLAN (802.1Q)

| | |
|--|--|
| **Qué es** | **Segmentación lógica** de una misma infraestructura física: varias “LAN virtuales” con etiqueta en la trama. |
| **Para qué sirve** | Separar departamentos, voz/datos, reducir broadcast sin tirar más cable. |
| **En el curso** | M08 (conceptual en 101; la maqueta usa redes distintas como analogía). |

---

### Modelo OSI / TCP/IP

| | |
|--|--|
| **Qué es** | Marcos de referencia por **capas** (enlace, red, transporte, aplicación…) para ubicar protocolos y fallos. |
| **Para qué sirve** | Responder “¿es un problema de cable/IP/ruta/puerto/aplicación?”. |
| **En el curso** | M06; en M01 ya usas ideas L2 (mismo segmento) vs L3 (router, rutas). |

---

## Dónde aparece cada módulo

| Módulo | Conceptos principales |
|--------|------------------------|
| **M01** | Topologías, LAN/WAN, IP privada/pública, gateway, tabla de rutas, NAT/PAT |
| **M02** | Máscara, CIDR, subredes, IPv6 básico |
| **M03** | DNS, DHCP, FTP/SFTP, SMTP, ICMP |
| **M04** | Puertos, TCP/UDP, sockets |
| **M05** | DMZ, segmentación, filtrado |
| **M06** | OSI, TCP/IP |
| **M07** | Switch, MAC, router, AP, WiFi |
| **M08** | VLAN, trunk 802.1Q |

---

## Referencias cruzadas

- [Glosario de herramientas](glosario-herramientas.md) — `ip`, `ping`, `iptables`, etc.
- [M01 — Introducción](labs/M01/README.md) — primer uso de la mayoría de términos de enlace y rutas.
