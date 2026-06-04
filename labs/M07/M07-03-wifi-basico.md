# Laboratorio M07-03 — WiFi básico (conceptos en el host)

[← Página anterior](M07-02-router-modem-ap.md) · [Siguiente página →](../M08/README.md)

## Objetivo del laboratorio

Al terminar debes poder:

- Relacionar **SSID**, **canal** y **seguridad WPA** con capa 2 inalámbrica.
- Usar `ip link` (y `iw` si existe) en tu **terminal del Codespace o Linux**, no dentro de la maqueta.
- Explicar por qué en muchos entornos de laboratorio **no hay radio WiFi** y qué observarías igualmente.

Este ejercicio es mayormente **conceptual** en el host; la maqueta del curso no simula ondas radio.

Conceptos: [Glosario de términos](../../docs/glosario-terminos.md) · Comandos: [Glosario de herramientas](../../docs/glosario-herramientas.md).

---

### Paso 1 — Interfaces en tu puesto

**Aprende:** WiFi en Linux aparece como interfaz `wlan0` (o similar); Ethernet como `eth0`. El AP une clientes `wlan` al segmento del uplink.

**Haces:** en tu **terminal del Codespace o del host** (fuera de cualquier maqueta):

```bash
ip link show
```

**Deberías ver:**

- Lista de interfaces (`lo`, `eth0`, a veces `docker0`, etc.).
- Puede **no existir** `wlan0` en Codespace/cloud → es normal.

**Por qué:** sin hardware WiFi no practicas asociación real; igual aprendes a leer estado **UP/DOWN** y tipo de interfaz.

---

### Paso 2 — Herramienta `iw` (si está disponible)

**Aprende:** `iw dev` lista radios; `iw dev wlan0 link` muestra SSID y señal cuando estás asociado.

**Haces:**

```bash
command -v iw >/dev/null && iw dev || echo "iw no disponible en este entorno"
```

**Deberías ver:**

- Salida con `Interface` y `ssid`, o el mensaje de que no hay `iw`/radio.

**Por qué:** en portátil con WiFi verías canal y BSSID; en servidor cloud el AP está fuera de tu VM.

---

### Paso 3 — Mapa mental AP + router doméstico

**Aprende:**

```text
Internet ──► [Módem/Router NAT] ──► switch ──► AP ──► clientes WiFi (misma LAN IP)
                      │
                      └── Ethernet cable a AP (modo AP, no router)
```

**Haces:** responde por escrito:

1. ¿El SSID es una capa 3?
2. ¿Por qué conviene separar red de invitados (otro SSID/VLAN)?
3. ¿WPA2/WPA3 protege después de asociarte también el tráfico IP?

**Deberías ver (ideas clave):**

1. No; SSID es identidad L2 del BSS.
2. Aislamiento de invitados (VLAN o subred distinta + firewall).
3. WPA cifra el enlace radio; aun así conviene HTTPS en aplicaciones.

**Por qué:** el curso cierra dispositivos con WiFi porque en soporte mezclan “no hay WiFi” con “no hay internet”.

---

### Paso 4 — Enlace con M07-01 y M07-02

**Aprende:** un portátil en WiFi obtiene IP por DHCP en la LAN del AP; `ip neigh` y `ping` funcionan igual que en `segmento-l2`, solo cambia el medio (802.11 vs cable).

**Haces:** sin maqueta, describe qué comandos usarías en un portátil conectado al SSID de casa para comprobar gateway y DNS.

**Deberías proponer:** `ip -4 addr`, `ip route`, `ping` al gateway, `ping 8.8.8.8`, `dig` o `curl` — mismas capas que en M06.

---

## Antes de seguir

### Pon el foco en

- **AP ≠ router** salvo modo “router travel” que hace NAT aparte.
- **Canal/ancho de banda** afecta colisiones en 2,4 GHz; en 5 GHz hay más canales no solapados.
- En cloud/Codespace, el ejercicio es **leer documentación y comandos**, no ver SSID real.

### Reto

**1. Modo AP vs modo router** — En un “router barato”, ¿qué desactivarías para dejarlo solo como AP detrás de otro router?

<details>
<summary>Ver solución</summary>

Desactivar DHCP/NAT en el segundo equipo (modo AP/bridge); conectar cable LAN-LAN (no puerto WAN). Un solo router hace NAT hacia internet.

</details>

**2. SSID oculto** — ¿Ocultar el SSID mejora la seguridad?

<details>
<summary>Ver solución</summary>

No de forma relevante: el SSID sigue filtrándose en probes; lo importante es WPA2/WPA3 y contraseña fuerte. La segmentación (VLAN/invitados) aporta más.

</details>
