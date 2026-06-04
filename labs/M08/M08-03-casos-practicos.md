# Laboratorio M08-03 — Casos prácticos VLAN

[← Página anterior](M08-02-access-trunk.md) · [Siguiente página →](../../README.md)

## Objetivo del laboratorio

Al terminar debes poder:

- Aplicar VLANs a un caso **voz + datos** añadiendo una tercera red en la maqueta.
- Justificar **aislamiento** (voz QoS, menos broadcast) y **routing** selectivo.
- Cerrar el recorrido del curso enlazando con los módulos anteriores (segmentación M05, dispositivos M07).

En cada paso: **levantar la maqueta** → editar compose si toca → **acceder al sistema** → probar.

---

### Paso 1 — Caso: departamento de voz

**Aprende:** la telefonía IP suele ir en VLAN dedicada para QoS y para que un problema en datos no tire las llamadas.

**Haces (diseño):** antes de tocar archivos, define:

- Subred propuesta: `10.80.30.0/24`
- Gateway: `10.80.30.254`
- Host ejemplo: `pc-voz` en `10.80.30.10`

**Por qué:** separar **broadcast** y políticas; el router controla si ventas puede llamar a RRHH por SIP, etc.

---

### Paso 2 — Implementar `pc-voz` en la maqueta

**Aprende:** añadir una red en `docker-compose.yaml` es el equivalente a crear VLAN 30 y cablear el router.

**Haces:** en `labs/M08/compose/departamentos/docker-compose.yaml`, añade red `vlan-voz`, servicio `pc-voz` y tercera interfaz en `router-vlan` (IP `10.80.30.254`). Extiende `montar-rutas.sh` con rutas para `pc-voz` y el router.

**Levantar la maqueta:**

```bash
cd labs/M08/compose/departamentos
docker compose up -d
./montar-rutas.sh
```

**Acceder al sistema `pc-voz`:**

```bash
docker compose exec -it pc-voz bash
```

**Dentro del sistema `pc-voz`:**

```bash
ip -4 addr show
ping -c 2 10.80.10.10
ping -c 2 10.80.20.10
```

**Deberías ver:**

- IP en `10.80.30.0/24`.
- Ping a ventas y RRHH **si** añadiste rutas en el router y en los otros PCs (o solo hacia gateway primero).

**Por qué:** cada VLAN nueva necesita **routing** explícito; no basta crear la red.

**Dentro del sistema:** `exit`

---

### Paso 3 — Política: voz no navega a RRHH

**Aprende:** caso real — permitir señalización SIP al servidor en ventas, bloquear SMB desde voz a RRHH.

**Acceder al sistema `router-vlan`:**

```bash
docker compose exec -it router-vlan bash
```

**Dentro del sistema `router-vlan` (ejemplo didáctico):**

```bash
iptables -A FORWARD -s 10.80.30.0/24 -d 10.80.20.0/24 -j DROP
iptables -L FORWARD -n --line-numbers | tail -5
exit
```

**Desde `pc-voz`**, repite `ping` a `10.80.20.10`.

**Deberías ver:** ping bloqueado tras la regla; ping a ventas puede seguir si no lo bloqueaste.

**Por qué:** combina **VLAN** (aislamiento L2) con **filtrado L3** (M05) en el mismo router.

**En tu terminal (maqueta):** `docker compose down`

---

### Paso 4 — Cierre del curso

**Aprende:** has recorrido desde topologías L2 hasta VLAN, pasando por NAT, servicios, DMZ y modelos de capas.

**Haces:** vuelve al índice del curso y marca qué módulos practicaste con maqueta.

**Siguiente página:** [Formación redes — índice general](../../README.md)

---

## Antes de seguir

### Pon el foco en

- **Voz + datos + invitados** = tres VLAN típicas en campus.
- **Trunk** agrega VLANs sin multiplicar cables; **access** mantiene simple el puesto.
- El curso termina aquí; profundiza en certificaciones o prácticas con hardware real.

### Reto

**1. Solo gateway en voz** — Configura `pc-voz` sin ruta a RRHH (sin ruta host ni red hacia `.20.0/24`) pero con default vía `10.80.30.254`. Comprueba alcance.

<details>
<summary>Ver solución</summary>

```bash
ip route replace default via 10.80.30.254
ping -c 2 10.80.10.10
ping -c 2 10.80.20.10
```

Ventas OK si el router enruta; RRHH depende de rutas/ACL en router.

</details>

**2. Inventario VLAN** — Tabla con columnas: VLAN ID lógico, subred, gateway, quién puede hablar con quién.

<details>
<summary>Ver solución (plantilla)</summary>

| VLAN | Subred | Gateway | Comunicación |
|------|--------|---------|--------------|
| ventas | 10.80.10.0/24 | .10.254 | RRHH vía router; voz según ACL |
| rrhh | 10.80.20.0/24 | .20.254 | ventas vía router |
| voz | 10.80.30.0/24 | .30.254 | bloqueo ejemplo a RRHH |

</details>

**3. Resumen en 5 líneas** — Escribe qué llevas al salir del curso (topología, IP, NAT, servicios, seguridad, capas, switch/router, VLAN).

<details>
<summary>Ver solución (ejemplo)</summary>

Montar LAN/WAN en maqueta; direccionar y enrutar; NAT/PAT; DNS/DHCP/sockets; DMZ y filtrado; diagnosticar por capas OSI/TCP/IP; tablas MAC y roles router/AP; VLAN + trunk conceptual + routing inter-VLAN.

</details>
