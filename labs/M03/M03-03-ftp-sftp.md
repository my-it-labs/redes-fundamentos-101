# Laboratorio M03-03 — FTP y SFTP

[← Página anterior](M03-02-dhcp.md) · [Siguiente página →](M03-04-smtp-icmp.md)

## Objetivo del laboratorio

Al terminar debes poder:

- Conectarte por **SFTP** con usuario y contraseña de laboratorio.
- Transferir o listar un fichero en el servidor remoto.
- Explicar la diferencia entre FTP clásico (activo/pasivo) y SFTP (SSH).

En cada paso: **levantar la maqueta** → **acceder al sistema** → comandos **dentro del sistema**.

Conceptos: [Glosario de términos](../../docs/glosario-terminos.md) · Comandos: [Glosario de herramientas](../../docs/glosario-herramientas.md).

---

## Mapa mental (antes de tocar comandos)

```text
cliente-ftp ──SSH/SFTP puerto 22──► servidor-sftp (192.168.54.10)
                                         usuario: alumno / lab101
```

| Modo FTP clásico | Canal de datos | Idea |
|------------------|----------------|------|
| **Activo** | Cliente abre puerto; servidor conecta hacia el cliente | Problemas con NAT/firewall |
| **Pasivo** | Servidor indica IP:puerto; cliente conecta | Más habitual hoy |
| **SFTP** | Mismo túnel **SSH** (cifrado) | No es FTP; es subsistema sobre SSH |

En este lab practicas **SFTP**; FTP activo/pasivo es conceptual (puertos 20/21 y rangos pasivos).

---

### Paso 1 — Levantar y probar SFTP interactivo

**Aprende:** SFTP autentica como SSH y opera sobre el canal seguro (puerto **22** por defecto).

**Levantar la maqueta:**

```bash
cd labs/M03/compose/sftp
docker compose up -d
```

**Acceder al sistema `cliente-ftp`:**

```bash
docker compose exec -it cliente-ftp bash
```

**Dentro del sistema `cliente-ftp`:**

```bash
sftp alumno@192.168.54.10
```

Contraseña de laboratorio: `lab101`

Comandos dentro de `sftp>`:

```text
ls
cd datos
get ejemplo.txt /tmp/ejemplo.txt
bye
```

**Deberías ver:** listado con `ejemplo.txt` y descarga en `/tmp/ejemplo.txt`.

**Dentro del sistema `cliente-ftp`:**

```bash
cat /tmp/ejemplo.txt
```

**Dentro del sistema:** `exit`

---

### Paso 2 — SFTP por una sola línea (batch)

**Aprende:** en scripts se usa `sftp` con batch o `ssh` para automatizar.

**Acceder al sistema `cliente-ftp`:**

```bash
docker compose exec -it cliente-ftp bash
```

**Dentro del sistema `cliente-ftp`:**

```bash
sshpass -p lab101 sftp -o StrictHostKeyChecking=no -b - alumno@192.168.54.10 <<EOF
ls datos
EOF
```

Si `sshpass` no está instalado, repite el paso 1 en modo interactivo.

**Deberías ver:** listado del directorio `datos`.

**Dentro del sistema:** `exit`

---

### Paso 3 — FTP activo vs pasivo (conceptual)

**Aprende:** FTP usa **dos canales**: control (21) y datos (20 en activo, o puertos altos en pasivo).

**Haces:** en papel o tabla, sin levantar FTP en la maqueta:

| | Activo | Pasivo |
|---|--------|--------|
| Quién abre el canal de datos | Servidor → cliente | Cliente → servidor |
| Problema típico con NAT | El servidor no alcanza la IP privada del cliente | Hay que abrir rango de puertos en el servidor |

**Por qué:** en redes modernas se prefiere **SFTP/FTPS** o APIs HTTPS; FTP clásico queda en legado y copias masivas internas.

---

### Paso 4 — Puertos en escucha

**Aprende:** `ss` muestra qué servicios escuchan en el servidor SFTP.

**Acceder al sistema `servidor-sftp`:**

```bash
docker compose exec servidor-sftp sh -c "ss -tlnp 2>/dev/null || netstat -tlnp"
```

**Deberías ver:** puerto **22** en LISTEN.

**En tu terminal (maqueta):** `docker compose down`

---

## Antes de seguir

### Pon el foco en

| Protocolo | Puerto típico | Seguridad |
|-----------|---------------|-----------|
| FTP | 21 control, 20 datos (activo) | Sin cifrado por defecto |
| SFTP | 22 (SSH) | Cifrado + integridad |
| FTPS | 21 + TLS | FTP con capa TLS |

### Reto

**1. Subir un fichero** — Crea `/tmp/mi-nota.txt` en el cliente y súbelo a `datos/` del servidor con `sftp`.

<details>
<summary>Ver solución</summary>

**Dentro de `cliente-ftp`:**

```bash
echo practica > /tmp/mi-nota.txt
sftp alumno@192.168.54.10
```

En `sftp>`: `put /tmp/mi-nota.txt datos/mi-nota.txt`, luego `ls datos`, `bye`.

</details>

**2. Puerto equivocado** — Intenta `sftp alumno@192.168.54.10:2222` (si no hay servicio).

<details>
<summary>Ver solución</summary>

Debe fallar la conexión (connection refused o timeout). El servicio escucha en **22**.

</details>

**3. Dibuja FTP pasivo** — Esquema: cliente, servidor, canal control 21, canal datos en puerto alto indicado por PASV.

<details>
<summary>Ver solución</summary>

```text
Cliente ----(TCP 21 control)----> Servidor
Cliente ----(TCP puerto N)----> Servidor   # datos; N lo anuncia PASV
```

</details>
