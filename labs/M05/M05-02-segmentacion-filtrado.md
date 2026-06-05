# Laboratorio M05-02 — Segmentación y filtrado

[← Página anterior](M05-01-dmz.md) · [Siguiente página →](../M06/README.md)

## Objetivo del laboratorio

Al terminar debes poder:

- **Endurecer** reglas `iptables` en el firewall de la maqueta DMZ.
- Separar explícitamente **LAN interna**, **DMZ** e **internet** (denegar por defecto, permitir por excepción).
- Documentar el efecto de cada regla con `ping` y `curl` como en M05-01.

En cada paso: **levantar la maqueta** → **acceder al sistema** (sobre todo `firewall`) → probar desde los clientes.

---

### Paso 1 — Estado actual del firewall

**Aprende:** listar reglas antes de cambiarlas evita “reglas fantasma” y ayuda a explicar el tráfico que sí pasa.

**Levantar la maqueta:**

```bash
cd labs/M05/compose/dmz
docker compose up -d
./montar-dmz.sh
```

**Acceder al sistema `firewall`:**

```bash
docker compose exec -it firewall bash
```

**Dentro del sistema `firewall`:**

```bash
ip -4 addr show
iptables -L FORWARD -n -v --line-numbers
```

**Deberías ver:**

- Tres interfaces con IP en `10.70.1.254`, `10.70.2.254`, `10.70.100.254`.
- En esta maqueta suele ser: **`eth0` = internet** (`10.70.100.254`), **`eth1` = LAN** (`10.70.1.254`), **`eth2` = DMZ** (`10.70.2.254`). Anota tu salida antes de editar reglas.
- Política `FORWARD` en **DROP** y varias reglas `ACCEPT`.

**Por qué:** el orden de las reglas importa: la primera coincidencia gana.

**Dentro del sistema:** deja la sesión abierta o anota interfaces; puedes salir con `exit` y volver a entrar.

---

### Paso 2 — Aislar la LAN interna de la DMZ

**Aprende:** la LAN interna no debería navegar servicios de la DMZ como si fueran intranet; solo el firewall debe autorizar excepciones puntuales (por ejemplo administración por SSH, no HTTP público).

**Acceder al sistema `firewall`:**

```bash
docker compose exec -it firewall bash
```

**Dentro del sistema `firewall`:**

```bash
iptables -D FORWARD -i eth1 -o eth2 -j ACCEPT 2>/dev/null || true
iptables -A FORWARD -i eth1 -o eth2 -p tcp --dport 22 -d 10.70.2.10 -j ACCEPT
iptables -A FORWARD -i eth2 -o eth1 -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -L FORWARD -n -v --line-numbers
exit
```

**Acceder al sistema `pc-interno`:**

```bash
docker compose exec -it pc-interno bash
```

**Dentro del sistema `pc-interno`:**

```bash
ping -c 2 10.70.2.10
curl -sS -m 3 -o /dev/null -w "%{http_code}\n" http://10.70.2.10:8080/ || echo "curl falló"
```

**Deberías ver:**

- `ping` puede seguir respondiendo si no bloqueaste ICMP (si bloqueaste ICMP en un reto, anótalo).
- `curl` al **8080** desde interno debería **fallar** tras quitar la regla amplia `eth1→eth2`.

**Por qué:** segmentar es **restringir** tráfico entre zonas; la DMZ queda para flujos desde internet controlados, no para uso general de usuarios internos.

**Dentro del sistema:** `exit`

---

### Paso 3 — Mantener solo el servicio público desde internet

**Aprende:** la regla del script que abre TCP 8080 desde `eth0` (internet) hacia `10.70.2.10` debe seguir siendo la vía de acceso externo.

**Acceder al sistema `atacante-internet`:**

```bash
docker compose exec -it atacante-internet bash
```

**Dentro del sistema `atacante-internet`:**

```bash
curl -sS -m 3 -o /dev/null -w "%{http_code}\n" http://10.70.2.10:8080/
nc -z -w2 10.70.2.10 22 && echo "22 abierto" || echo "22 cerrado"
```

**Deberías ver:**

- HTTP **8080** con código **200**.
- Puerto **22** hacia la DMZ **cerrado** desde internet (salvo que añadas una regla explícita).

**Por qué:** administración (SSH) y publicación web (8080) son perfiles distintos; mezclarlos sin filtro agranda el riesgo.

**Dentro del sistema:** `exit`

---

### Paso 4 — Registro de intentos denegados (opcional)

**Aprende:** registrar drops ayuda en auditoría; en laboratorio basta una regla de LOG al final.

**Acceder al sistema `firewall`:**

```bash
docker compose exec -it firewall bash
```

**Dentro del sistema `firewall`:**

```bash
iptables -A FORWARD -j LOG --log-prefix "FW-DROP: " --log-level 4
exit
```

**Desde `atacante-internet`**, repite un `curl` a un puerto no permitido (por ejemplo `8081`). **En el firewall**, revisa:

```bash
docker compose exec -it firewall bash
dmesg | tail -5
exit
```

**Deberías ver:** líneas con prefijo `FW-DROP` si el tráfico fue denegado (depende del kernel y permisos del contenedor).

**Por qué:** en producción el log alimenta SIEM/alertas; aquí compruebas que el deny es observable.

**En tu terminal (maqueta):** `docker compose down`

---

## Antes de seguir

### Pon el foco en

- **Segmentación** = menos blast radius: un compromiso en DMZ no implica acceso libre a la LAN.
- **Filtrado stateful:** reglas `ESTABLISHED,RELATED` devuelven respuestas sin abrir todo el rango de puertos entrantes.
- **Documentar política:** tabla origen/destino/puerto/protocolo antes de tocar iptables en producción.

### Reto

**1. Bloquear ICMP entre zonas** — Añade reglas que impidan `ping` desde `pc-interno` hacia `10.70.2.10` y desde `atacante-internet` hacia la DMZ, sin cerrar el HTTP 8080 permitido.

<details>
<summary>Ver solución</summary>

**Dentro de `firewall`:**

```bash
iptables -I FORWARD 1 -i eth1 -o eth2 -p icmp -j DROP
iptables -I FORWARD 1 -i eth0 -o eth2 -p icmp -j DROP
```

Comprueba desde cada cliente; el `curl :8080` desde internet debe seguir en 200.

</details>

**2. Servidor de solo lectura interno** — Permite que `pc-interno` haga `curl` al **8080** solo si el destino es `10.70.2.10` y niega cualquier otro destino en `10.70.2.0/24`.

<details>
<summary>Ver solución</summary>

```bash
iptables -A FORWARD -i eth1 -o eth2 -d 10.70.2.10 -p tcp --dport 8080 -j ACCEPT
iptables -A FORWARD -i eth1 -o eth2 -d 10.70.2.0/24 -j DROP
```

Prueba `curl` al servidor DMZ (OK) y `ping` a otra IP inventada en `.2.0/24` si la añades al compose (DROP).

</details>

**3. Política en una frase** — Escribe la política de tu firewall en una frase estilo: “Desde internet solo TCP 8080 a `10.70.2.10`; desde interno no hay acceso a DMZ salvo …”.

<details>
<summary>Ver solución (ejemplo)</summary>

“Desde internet solo TCP 8080 al servidor DMZ; desde la LAN interna no hay acceso a la DMZ salvo administración SSH al mismo host si se define; todo lo demás FORWARD denegado por defecto.”

</details>
