# 🎓 Ejercicios Progresivos de Seguridad WiFi

**Nivel: Básico → Intermedio → Avanzado**

Este documento contiene ejercicios estructurados progresivamente para que los alumnos aprendan a usar las herramientas de análisis WiFi paso a paso, desde conceptos básicos hasta escenarios de ataque realistas.

---

## 📊 Índice de Ejercicios

### Nivel Básico (30 min cada uno)
1. **Explorando PCAPs** - Familiarización con Wireshark y tshark
2. **Frames WiFi Básicos** - Beacon, Probe Request, Association
3. **DHCP y Conexión a Red** - Proceso completo de conexión

### Nivel Intermedio (45 min cada uno)
4. **WPA2 4-Way Handshake** - Análisis profundo del handshake
5. **EAPOL y Nonces** - Extracción de datos crypto
6. **DNS Analysis** - Detección de anomalías en DNS

### Nivel Avanzado (60 min cada uno)
7. **ARP Spoofing Detection** - Detectar ataques MitM
8. **HTTP Traffic Analysis** - Captive portals y session hijacking
9. **PMKID Attack Simulation** - Extracción y cracking

---

# NIVEL BÁSICO

---

## Ejercicio 1: Explorando PCAPs con tshark

**Objetivo:** Familiarizarse con tshark y comandos básicos de análisis de PCAPs

**PCAP:** `wifi_lab/pcaps/wpa2/wpa_induction.pcap` (175KB)

**Duración:** 30 minutos

### Paso 1: Información General del PCAP

```bash
# Ver estadísticas del archivo
tshark -r wifi_lab/pcaps/wpa2/wpa_induction.pcap -q -z io,stat,0
```

**Preguntas guía:**
- ¿Cuántos frames tiene el PCAP?
- ¿Cuál es la duración de la captura?
- ¿Cuántos bytes de datos capturados?

### Paso 2: Listar Primeros 10 Frames

```bash
# Ver primeros 10 frames con información básica
tshark -r wifi_lab/pcaps/wpa2/wpa_induction.pcap -c 10
```

**Preguntas guía:**
- ¿Qué tipos de frames ves?
- ¿Puedes identificar direcciones MAC?
- ¿Qué protocolos aparecen?

### Paso 3: Filtrar por Tipo de Frame

```bash
# Solo ver beacon frames (type/subtype 0x08)
tshark -r wifi_lab/pcaps/wpa2/wpa_induction.pcap -Y "wlan.fc.type_subtype == 0x08" -c 5
```

**Resultado esperado:**
```
1   0.000000 00:0c:41:82:b2:55 → Broadcast    802.11 Beacon frame, SN=2543, FN=0, Flags=........C
3   0.102400 00:0c:41:82:b2:55 → Broadcast    802.11 Beacon frame, SN=2544, FN=0, Flags=........C
...
```

### Paso 4: Extraer SSID del Network

```bash
# Extraer todos los SSID únicos
tshark -r wifi_lab/pcaps/wpa2/wpa_induction.pcap -Y "wlan.ssid" -T fields -e wlan.ssid | sort -u
```

**Resultado esperado:**
```
436f6865726572
```

**Conversión a ASCII:**
```bash
echo "436f6865726572" | xxd -r -p
```

**Resultado:** `Coherer`

### Paso 5: Identificar Dispositivos (MACs)

```bash
# Extraer direcciones MAC únicas (Source Addresses)
tshark -r wifi_lab/pcaps/wpa2/wpa_induction.pcap -T fields -e wlan.sa | sort -u
```

**Resultado esperado:**
```
00:0c:41:82:b2:55  ← Access Point (AP)
00:0d:93:82:36:3a  ← Cliente (STA)
```

### 📝 Ejercicio Práctico:

**Tarea 1:** ¿Cuántos beacon frames existen en total?
```bash
tshark -r wifi_lab/pcaps/wpa2/wpa_induction.pcap -Y "wlan.fc.type_subtype == 0x08" | wc -l
```

**Tarea 2:** ¿Cuántos probe requests hay?
```bash
tshark -r wifi_lab/pcaps/wpa2/wpa_induction.pcap -Y "wlan.fc.type_subtype == 0x04" | wc -l
```

**Tarea 3:** Exportar los resultados a un archivo
```bash
tshark -r wifi_lab/pcaps/wpa2/wpa_induction.pcap -Y "eapol" > wifi_lab/outputs/ejercicio1_eapol.txt
cat wifi_lab/outputs/ejercicio1_eapol.txt
```

---

## Ejercicio 2: Frames WiFi Básicos

**Objetivo:** Entender los diferentes tipos de frames 802.11

**PCAP:** `wifi_lab/pcaps/misc/mobile_network_join.pcap` (161KB)

**Duración:** 30 minutos

### Tipos de Frames 802.11

| Tipo | Subtipo | Hex | Nombre | Función |
|------|---------|-----|--------|---------|
| 0 (Management) | 0 | 0x00 | Association Request | Cliente solicita asociación |
| 0 (Management) | 1 | 0x01 | Association Response | AP acepta/rechaza |
| 0 (Management) | 4 | 0x04 | Probe Request | Cliente busca redes |
| 0 (Management) | 5 | 0x05 | Probe Response | AP responde con info |
| 0 (Management) | 8 | 0x08 | Beacon | AP anuncia su presencia |
| 0 (Management) | 11 | 0x0b | Authentication | Autenticación Open/Shared |
| 0 (Management) | 12 | 0x0c | Deauthentication | Desconexión forzada |
| 2 (Data) | 0 | 0x20 | Data | Tráfico de datos |

### Paso 1: Ver Beacon Frames

```bash
tshark -r wifi_lab/pcaps/misc/mobile_network_join.pcap -Y "wlan.fc.type_subtype == 0x08" -T fields -e frame.number -e wlan.ssid -e wlan.bssid | head -5
```

**Resultado esperado:**
```
1       <SSID_hex>      <BSSID_MAC>
...
```

### Paso 2: Ver Probe Requests

```bash
tshark -r wifi_lab/pcaps/misc/mobile_network_join.pcap -Y "wlan.fc.type_subtype == 0x04"
```

**Preguntas guía:**
- ¿El dispositivo busca una red específica o hace broadcast?
- ¿Qué información revela el dispositivo en los probe requests?

### Paso 3: Proceso de Autenticación

```bash
# Ver frames de autenticación (0x0b)
tshark -r wifi_lab/pcaps/misc/mobile_network_join.pcap -Y "wlan.fc.type_subtype == 0x0b"
```

### Paso 4: Proceso de Asociación

```bash
# Association Request (0x00)
tshark -r wifi_lab/pcaps/misc/mobile_network_join.pcap -Y "wlan.fc.type_subtype == 0x00"

# Association Response (0x01)
tshark -r wifi_lab/pcaps/misc/mobile_network_join.pcap -Y "wlan.fc.type_subtype == 0x01"
```

### 📝 Ejercicio Práctico:

**Reconstruir el proceso completo de conexión:**

1. Probe Request
2. Probe Response
3. Authentication Request
4. Authentication Response
5. Association Request
6. Association Response
7. DHCP (obteniendo IP)

```bash
# Script para ver la secuencia
for TYPE in 0x04 0x05 0x0b 0x00 0x01; do
  echo "=== Type/Subtype: $TYPE ==="
  tshark -r wifi_lab/pcaps/misc/mobile_network_join.pcap -Y "wlan.fc.type_subtype == $TYPE" -c 1
  echo ""
done
```

---

## Ejercicio 3: DHCP y Conexión Completa

**Objetivo:** Analizar el proceso DHCP tras la conexión WiFi

**PCAP:** `wifi_lab/pcaps/misc/dhcp_traffic.pcap` (1.4KB)

**Duración:** 30 minutos

### DHCP Process (DORA)

1. **D**iscover - Cliente busca servidor DHCP
2. **O**ffer - Servidor ofrece una IP
3. **R**equest - Cliente solicita esa IP
4. **A**ck - Servidor confirma

### Paso 1: Ver Todos los Mensajes DHCP

```bash
tshark -r wifi_lab/pcaps/misc/dhcp_traffic.pcap -Y "dhcp"
```

### Paso 2: Extraer Información Detallada

```bash
tshark -r wifi_lab/pcaps/misc/dhcp_traffic.pcap -Y "dhcp" -T fields \
  -e frame.number \
  -e dhcp.option.dhcp \
  -e dhcp.option.requested_ip_address \
  -e dhcp.option.dhcp_server_id
```

**Campos importantes:**
- `dhcp.option.dhcp = 1` → DISCOVER
- `dhcp.option.dhcp = 2` → OFFER
- `dhcp.option.dhcp = 3` → REQUEST
- `dhcp.option.dhcp = 5` → ACK

### Paso 3: Ver IP Asignada

```bash
tshark -r wifi_lab/pcaps/misc/dhcp_traffic.pcap -Y "dhcp.option.dhcp == 5" -T fields -e dhcp.option.requested_ip_address
```

### 📝 Ejercicio Práctico:

**Crear un reporte de la conexión DHCP:**

```bash
cat > wifi_lab/reports/ejercicio3_dhcp.txt << 'EOF'
DHCP Analysis Report
====================

1. DISCOVER:
   - Client MAC: [extraer con tshark]
   - Requested Options: [extraer]

2. OFFER:
   - Offered IP: [extraer]
   - Server IP: [extraer]
   - Lease Time: [extraer]

3. REQUEST:
   - Requested IP: [extraer]

4. ACK:
   - Assigned IP: [extraer]
   - Gateway: [extraer]
   - DNS Servers: [extraer]
EOF
```

---

# NIVEL INTERMEDIO

---

## Ejercicio 4: WPA2 4-Way Handshake Profundo

**Objetivo:** Análisis detallado del proceso de autenticación WPA2-PSK

**PCAP:** `wifi_lab/pcaps/wpa2/wpa_induction.pcap` (175KB)

**Duración:** 45 minutos

### Teoría: 4-Way Handshake

El handshake WPA2-PSK involucra 4 mensajes EAPOL (Extensible Authentication Protocol Over LAN):

```
   AP (00:0c:41:82:b2:55)          STA (00:0d:93:82:36:3a)
          |                                   |
          |  [1] ANonce                       |
          |---------------------------------->|
          |                                   |
          |            [2] SNonce + MIC       |
          |<----------------------------------|
          |                                   |
          |  [3] GTK + MIC                    |
          |---------------------------------->|
          |                                   |
          |            [4] ACK + MIC          |
          |<----------------------------------|
          |                                   |
```

### Paso 1: Identificar los 4 Frames EAPOL

```bash
tshark -r wifi_lab/pcaps/wpa2/wpa_induction.pcap -Y "eapol" -T fields \
  -e frame.number \
  -e wlan.sa \
  -e wlan.da \
  -e eapol.keydes.key_info
```

**Resultado esperado:**
```
87	00:0c:41:82:b2:55	00:0d:93:82:36:3a	0x008a  ← Message 1/4
89	00:0d:93:82:36:3a	00:0c:41:82:b2:55	0x010a  ← Message 2/4
92	00:0c:41:82:b2:55	00:0d:93:82:36:3a	0x13ca  ← Message 3/4
94	00:0d:93:82:36:3a	00:0c:41:82:b2:55	0x030a  ← Message 4/4
```

### Paso 2: Extraer ANonce (Message 1/4)

```bash
tshark -r wifi_lab/pcaps/wpa2/wpa_induction.pcap -Y "eapol && frame.number == 87" -T fields -e eapol.keydes.nonce
```

**El ANonce es un número aleatorio de 256 bits (32 bytes / 64 hex chars)**

### Paso 3: Extraer SNonce (Message 2/4)

```bash
tshark -r wifi_lab/pcaps/wpa2/wpa_induction.pcap -Y "eapol && frame.number == 89" -T fields -e eapol.keydes.nonce
```

### Paso 4: Verificar MIC (Message Integrity Code)

```bash
tshark -r wifi_lab/pcaps/wpa2/wpa_induction.pcap -Y "eapol && frame.number == 89" -T fields -e eapol.keydes.mic
```

**El MIC asegura que el mensaje no fue modificado**

### Paso 5: Verificar Handshake con aircrack-ng

```bash
aircrack-ng wifi_lab/pcaps/wpa2/wpa_induction.pcap
```

**Resultado esperado:**
```
Reading packets, please wait...
Opening wifi_lab/pcaps/wpa2/wpa_induction.pcap

1 potential targets

#  BSSID              ESSID                     Encryption
1  00:0C:41:82:B2:55  Coherer                   WPA (1 handshake)

Choosing first network as target.
```

### 📝 Ejercicio Práctico:

**Crear script de análisis automático:**

```bash
#!/bin/bash
# Script: analizar_handshake.sh

PCAP="wifi_lab/pcaps/wpa2/wpa_induction.pcap"

echo "=== Análisis de WPA2 4-Way Handshake ==="
echo ""

# Contar EAPOL frames
EAPOL_COUNT=$(tshark -r "$PCAP" -Y "eapol" 2>/dev/null | wc -l | tr -d ' ')
echo "[+] EAPOL frames encontrados: $EAPOL_COUNT"

if [ "$EAPOL_COUNT" -eq 4 ]; then
    echo "[✓] Handshake COMPLETO (4 frames)"
elif [ "$EAPOL_COUNT" -eq 2 ]; then
    echo "[!] Handshake PARCIAL (solo 2 frames)"
else
    echo "[✗] Handshake INCOMPLETO"
fi

echo ""
echo "=== Información del Network ==="

# SSID
SSID_HEX=$(tshark -r "$PCAP" -Y "wlan.ssid" -T fields -e wlan.ssid 2>/dev/null | sort -u | head -1)
SSID=$(echo "$SSID_HEX" | xxd -r -p 2>/dev/null)
echo "SSID: $SSID"

# BSSID
BSSID=$(tshark -r "$PCAP" -Y "wlan.fc.type_subtype == 0x08" -T fields -e wlan.bssid 2>/dev/null | head -1)
echo "BSSID (AP): $BSSID"

# Cliente
CLIENT=$(tshark -r "$PCAP" -Y "eapol" -T fields -e wlan.da 2>/dev/null | head -1)
echo "Cliente (STA): $CLIENT"

echo ""
echo "=== Verificación con aircrack-ng ==="
aircrack-ng "$PCAP" 2>/dev/null | grep -A 3 "potential targets"
```

---

## Ejercicio 5: Extracción de Nonces y MIC

**Objetivo:** Extracción manual de nonces para entender el proceso PTK

**PCAP:** `wifi_lab/pcaps/wpa2/wpa_induction.pcap`

**Duración:** 45 minutos

### Teoría: PTK (Pairwise Transient Key)

```
PTK = PRF-512(PMK, "Pairwise key expansion",
              min(AP_MAC, STA_MAC) || max(AP_MAC, STA_MAC) ||
              min(ANonce, SNonce) || max(ANonce, SNonce))
```

Donde:
- **PMK** = PBKDF2(passphrase, SSID, 4096 iterations, 256 bits)
- **ANonce** = Número aleatorio del AP
- **SNonce** = Número aleatorio del STA
- **PRF-512** = Pseudo-Random Function

### Paso 1: Extraer Todos los Componentes

```bash
#!/bin/bash
PCAP="wifi_lab/pcaps/wpa2/wpa_induction.pcap"

# SSID
SSID=$(tshark -r "$PCAP" -Y "wlan.ssid" -T fields -e wlan.ssid 2>/dev/null | sort -u | head -1 | xxd -r -p)

# AP MAC (BSSID)
AP_MAC=$(tshark -r "$PCAP" -Y "eapol" -T fields -e wlan.sa 2>/dev/null | head -1)

# STA MAC
STA_MAC=$(tshark -r "$PCAP" -Y "eapol" -T fields -e wlan.da 2>/dev/null | head -1)

# ANonce (Message 1/4)
ANONCE=$(tshark -r "$PCAP" -Y "eapol" -T fields -e eapol.keydes.nonce 2>/dev/null | head -1)

# SNonce (Message 2/4)
SNONCE=$(tshark -r "$PCAP" -Y "eapol" -T fields -e eapol.keydes.nonce 2>/dev/null | sed -n '2p')

echo "SSID: $SSID"
echo "AP MAC: $AP_MAC"
echo "STA MAC: $STA_MAC"
echo "ANonce: $ANONCE"
echo "SNonce: $SNONCE"
```

### Paso 2: Exportar Handshake para Cracking

```bash
# Crear wordlist de prueba
cat > wifi_lab/outputs/test_wordlist.txt << EOF
password
12345678
password123
Coherer
coherer
Coherer123
EOF

# Intentar crackear (esto fallará probablemente)
aircrack-ng -w wifi_lab/outputs/test_wordlist.txt wifi_lab/pcaps/wpa2/wpa_induction.pcap
```

### 📝 Ejercicio Práctico:

**Tarea:** Exportar el handshake en formato hashcat

```bash
# Instalar hcxtools si está disponible
# brew install hcxtools  (macOS)
# sudo apt install hcxtools  (Linux)

# Convertir PCAP a formato hashcat 22000
hcxpcapngtool -o wifi_lab/outputs/handshake.22000 wifi_lab/pcaps/wpa2/wpa_induction.pcap

# Ver el hash
cat wifi_lab/outputs/handshake.22000
```

---

## Ejercicio 6: DNS Analysis y Detección de Anomalías

**Objetivo:** Analizar tráfico DNS y detectar comportamientos sospechosos

**PCAP:** `wifi_lab/pcaps/misc/dns_tunnel.pcap` (24KB)

**Duración:** 45 minutos

### Paso 1: Ver Queries DNS

```bash
tshark -r wifi_lab/pcaps/misc/dns_tunnel.pcap -Y "dns.flags.response == 0" -T fields -e dns.qry.name | head -10
```

### Paso 2: Detectar Queries Anómalas

```bash
# Queries con subdominios muy largos (posible tunneling)
tshark -r wifi_lab/pcaps/misc/dns_tunnel.pcap -Y "dns" -T fields -e dns.qry.name | awk 'length($0) > 50'
```

### Paso 3: Contar Queries por Dominio

```bash
tshark -r wifi_lab/pcaps/misc/dns_tunnel.pcap -Y "dns.flags.response == 0" -T fields -e dns.qry.name | sort | uniq -c | sort -nr | head -10
```

### 📝 Ejercicio Práctico:

**Crear un detector de DNS tunneling:**

```bash
#!/bin/bash
# Script: detect_dns_tunnel.sh

PCAP="wifi_lab/pcaps/misc/dns_tunnel.pcap"
THRESHOLD=40  # Longitud sospechosa

echo "=== DNS Tunneling Detection ==="
echo ""

tshark -r "$PCAP" -Y "dns.qry.name" -T fields -e frame.number -e dns.qry.name 2>/dev/null | \
while read FRAME QUERY; do
    LENGTH=${#QUERY}
    if [ $LENGTH -gt $THRESHOLD ]; then
        echo "[ALERTA] Frame $FRAME: Query sospechosa (length=$LENGTH)"
        echo "         Domain: $QUERY"
    fi
done
```

---

# NIVEL AVANZADO

---

## Ejercicio 7: ARP Spoofing Detection

**Objetivo:** Detectar ataques de ARP spoofing (Man-in-the-Middle)

**PCAP:** `wifi_lab/pcaps/attacks/arp_spoofing.pcap` (46KB)

**Duración:** 60 minutos

### Teoría: ARP Spoofing

El ataque ARP spoofing permite a un atacante interceptar tráfico entre dos hosts enviando respuestas ARP falsas.

```
Normal:
  Client (192.168.1.10) → Gateway (192.168.1.1)

ARP Spoofing:
  Client (192.168.1.10) → Attacker (192.168.1.100) → Gateway (192.168.1.1)
                          (pretende ser 192.168.1.1)
```

### Paso 1: Ver Todos los Paquetes ARP

```bash
tshark -r wifi_lab/pcaps/attacks/arp_spoofing.pcap -Y "arp"
```

### Paso 2: Detectar Respuestas ARP Duplicadas

```bash
# Ver paquetes ARP reply (opcode 2)
tshark -r wifi_lab/pcaps/attacks/arp_spoofing.pcap -Y "arp.opcode == 2" -T fields \
  -e frame.time \
  -e arp.src.proto_ipv4 \
  -e arp.src.hw_mac
```

**Señal de ARP spoofing:**
- Múltiples MACs reclamando la misma IP
- ARP replies no solicitados (gratuitous ARP)
- Alta frecuencia de ARP replies

### Paso 3: Crear Detector de ARP Spoofing

```bash
#!/bin/bash
# Script: detect_arp_spoofing.sh

PCAP="wifi_lab/pcaps/attacks/arp_spoofing.pcap"

echo "=== ARP Spoofing Detection ==="
echo ""

# Crear tabla temporal de IP → MAC
temp_file=$(mktemp)

tshark -r "$PCAP" -Y "arp.opcode == 2" -T fields \
  -e arp.src.proto_ipv4 -e arp.src.hw_mac 2>/dev/null | \
  sort | uniq > "$temp_file"

# Buscar IPs con múltiples MACs
echo "[+] Buscando IPs con múltiples MACs..."
cat "$temp_file" | awk '{print $1}' | sort | uniq -d | while read IP; do
    echo ""
    echo "[ALERTA] IP $IP tiene múltiples MACs:"
    grep "^$IP" "$temp_file" | awk '{print "         MAC: " $2}'
    echo "         ⚠️ POSIBLE ARP SPOOFING"
done

rm -f "$temp_file"

echo ""
echo "[+] Estadísticas de tráfico ARP:"
echo "    Requests: $(tshark -r "$PCAP" -Y "arp.opcode == 1" 2>/dev/null | wc -l)"
echo "    Replies:  $(tshark -r "$PCAP" -Y "arp.opcode == 2" 2>/dev/null | wc -l)"
```

### Paso 4: Análisis de Timing

```bash
# Ver frecuencia de ARP replies por segundo
tshark -r wifi_lab/pcaps/attacks/arp_spoofing.pcap -Y "arp.opcode == 2" -T fields -e frame.time_relative | \
  awk '{print int($1)}' | sort -n | uniq -c
```

**ARP spoofing activo:** Alta frecuencia de replies (>10/segundo)

### 📝 Ejercicio Práctico:

**Tarea 1:** Identificar el atacante
```bash
# Contar ARP replies por MAC
tshark -r wifi_lab/pcaps/attacks/arp_spoofing.pcap -Y "arp.opcode == 2" -T fields -e arp.src.hw_mac | \
  sort | uniq -c | sort -nr
```

**El MAC con más ARP replies es probablemente el atacante**

**Tarea 2:** Crear regla de Snort/Suricata para detectar ARP spoofing

```
alert arp any any -> any any (msg:"POSIBLE ARP SPOOFING - Multiple MACs for same IP"; \
  detection_filter:track by_dst, count 2, seconds 60; sid:1000001; rev:1;)
```

---

## Ejercicio 8: HTTP Traffic Analysis y Captive Portals

**Objetivo:** Analizar tráfico HTTP no cifrado y detectar captive portals

**PCAP:** `wifi_lab/pcaps/misc/http_captive_portal.cap` (319KB)

**Duración:** 60 minutos

### Paso 1: Ver Todos los HTTP Requests

```bash
tshark -r wifi_lab/pcaps/misc/http_captive_portal.cap -Y "http.request" -T fields \
  -e http.host \
  -e http.request.uri \
  -e http.user_agent
```

### Paso 2: Extraer Credenciales en Texto Claro

```bash
# Buscar POST requests (pueden contener credenciales)
tshark -r wifi_lab/pcaps/misc/http_captive_portal.cap -Y "http.request.method == POST"
```

### Paso 3: Ver Cookies de Sesión

```bash
tshark -r wifi_lab/pcaps/misc/http_captive_portal.cap -Y "http.cookie" -T fields \
  -e ip.src \
  -e http.host \
  -e http.cookie
```

**Session hijacking:** Cookies en texto claro pueden ser robadas

### Paso 4: Detectar Captive Portal

```bash
# Buscar redirects (302, 301)
tshark -r wifi_lab/pcaps/misc/http_captive_portal.cap -Y "http.response.code == 302 || http.response.code == 301" -T fields \
  -e http.response.code \
  -e http.location
```

**Indicadores de captive portal:**
- Redirect a página de login
- HTTP en lugar de HTTPS
- Domain como `login.wifi.com` o similar

### Paso 5: Extraer Imágenes Transmitidas

```bash
# Exportar objetos HTTP (imágenes, etc.)
tshark -r wifi_lab/pcaps/misc/http_captive_portal.cap --export-objects http,wifi_lab/outputs/http_objects 2>/dev/null

# Listar objetos extraídos
ls -lh wifi_lab/outputs/http_objects/
```

### 📝 Ejercicio Práctico:

**Crear un análisis completo de sesión HTTP:**

```bash
#!/bin/bash
# Script: analyze_http_session.sh

PCAP="wifi_lab/pcaps/misc/http_captive_portal.cap"

echo "=== HTTP Traffic Analysis ==="
echo ""

# Hosts contactados
echo "[+] Hosts HTTP contactados:"
tshark -r "$PCAP" -Y "http.request" -T fields -e http.host 2>/dev/null | sort -u

echo ""
echo "[+] User-Agents detectados:"
tshark -r "$PCAP" -Y "http.user_agent" -T fields -e http.user_agent 2>/dev/null | sort -u

echo ""
echo "[+] Métodos HTTP utilizados:"
tshark -r "$PCAP" -Y "http.request.method" -T fields -e http.request.method 2>/dev/null | sort | uniq -c

echo ""
echo "[+] Códigos de respuesta:"
tshark -r "$PCAP" -Y "http.response.code" -T fields -e http.response.code 2>/dev/null | sort | uniq -c

echo ""
echo "[⚠️] ALERTA: Todo el tráfico HTTP es visible en texto claro"
echo "    Recomendación: Usar HTTPS (TLS/SSL) siempre"
```

---

## Ejercicio 9: PMKID Attack Simulation (Avanzado)

**Objetivo:** Extraer PMKID y preparar para cracking (simulación educativa)

**PCAP:** `wifi_lab/pcaps/wpa2/wpa_induction.pcap` o `wpa_eap_tls.pcap`

**Duración:** 60 minutos

### Teoría: PMKID Attack

El PMKID attack (descubierto por Jens Steube, 2018) permite atacar redes WPA2 **sin necesidad de capturar clientes conectados**.

```
PMKID = HMAC-SHA1-128(PMK, "PMK Name" | MAC_AP | MAC_STA)
```

El PMKID se transmite en el primer mensaje del RSN IE (Robust Security Network Information Element) durante la asociación.

**Ventajas del atacante:**
- No necesita esperar a que un cliente se conecte
- No necesita hacer deauthentication
- Solo requiere el primer frame de asociación

### Paso 1: Buscar Frames de Association

```bash
# Ver association requests y responses
tshark -r wifi_lab/pcaps/wpa2/wpa_induction.pcap -Y "wlan.fc.type_subtype == 0x00 || wlan.fc.type_subtype == 0x01"
```

### Paso 2: Buscar RSN Information Element

```bash
# Extraer RSN IE
tshark -r wifi_lab/pcaps/wpa2/wpa_induction.pcap -Y "wlan.rsn.ie" -V | grep -A 20 "RSN Information"
```

### Paso 3: Extraer PMKID (si existe)

```bash
# El PMKID está en el tag 221 (Vendor Specific) del RSN IE
tshark -r wifi_lab/pcaps/wpa2/wpa_induction.pcap -Y "wlan.tag.number == 221" -x
```

### Paso 4: Conversión a Formato Hashcat

```bash
# Usando hcxtools (si está instalado)
hcxpcapngtool -o wifi_lab/outputs/pmkid.22000 wifi_lab/pcaps/wpa2/wpa_induction.pcap 2>/dev/null

# Ver hash generado
if [ -f wifi_lab/outputs/pmkid.22000 ]; then
    echo "[+] PMKID extraído:"
    cat wifi_lab/outputs/pmkid.22000
else
    echo "[!] No se encontró PMKID en este PCAP"
    echo "    Nota: No todos los PCAPs contienen PMKID"
fi
```

### Paso 5: Simulación de Cracking (Educativo)

```bash
# Crear wordlist extendida
cat > wifi_lab/outputs/extended_wordlist.txt << EOF
password
123456
12345678
qwerty
abc123
password123
welcome
admin
letmein
monkey
dragon
Coherer
coherer
COHERER
Coherer123
Coherer2024
WPA2password
MyWiFiPass
SecureNet
NetworkKey
EOF

# Intentar cracking del handshake con aircrack-ng
echo "[+] Intentando cracking con aircrack-ng..."
aircrack-ng -w wifi_lab/outputs/extended_wordlist.txt wifi_lab/pcaps/wpa2/wpa_induction.pcap

echo ""
echo "[!] Nota educativa:"
echo "    Este ejercicio es para demostrar por qué usar contraseñas seguras"
echo "    Contraseñas débiles pueden crackearse en minutos/horas"
echo "    Recomendación: WPA2/WPA3 con contraseñas >12 caracteres aleatorios"
```

### 📝 Ejercicio Práctico Final:

**Crear un informe completo de vulnerabilidades:**

```bash
cat > wifi_lab/reports/ejercicio9_pmkid_analysis.txt << 'EOF'
PMKID Attack Analysis Report
=============================

Objetivo: Analizar la vulnerabilidad PMKID en WPA2-PSK

1. INFORMACIÓN DEL OBJETIVO
   SSID: [extraer con tshark]
   BSSID: [extraer]
   Encryption: WPA2-PSK
   Channel: [extraer si está disponible]

2. PMKID EXTRACTION
   ¿Se encontró PMKID?: [Sí/No]
   Hash extraído: [mostrar hash]
   Formato: hashcat mode 22000 o 16800

3. HANDSHAKE ANALYSIS
   Frames EAPOL: [contar]
   Handshake completo: [Sí/No]
   ANonce: [primeros 16 chars]
   SNonce: [primeros 16 chars]

4. CRACKING ATTEMPT
   Wordlist utilizada: [nombre del archivo]
   Palabras en wordlist: [contar líneas]
   Resultado: [Éxito/Fallo]
   Password encontrado: [si aplicable]
   Tiempo de cracking: [si aplicable]

5. RECOMENDACIONES DE SEGURIDAD
   - Usar WPA3 si está disponible (protege contra PMKID)
   - Contraseñas >12 caracteres aleatorios
   - Evitar palabras del diccionario
   - Cambiar contraseña regularmente
   - Habilitar 802.11w (Management Frame Protection)

6. DETECCIÓN Y MITIGACIÓN
   - Monitorear association frames sospechosos
   - IDS/IPS rules para detectar scan masivo de PMKID
   - Actualizar firmware del AP regularmente
   - Migrar a WPA3 cuando sea posible

CONCLUSIÓN:
El PMKID attack demuestra que WPA2-PSK con contraseñas débiles
es vulnerable incluso sin capturar clientes activos.
EOF

# Llenar el reporte con datos reales
echo ""
echo "[+] Reporte creado en: wifi_lab/reports/ejercicio9_pmkid_analysis.txt"
echo "    Completa los campos [extraer...] con los comandos tshark aprendidos"
```

---

# ESCENARIOS INTEGRADOS

---

## Escenario Final: Auditoría Completa de Red WiFi

**Objetivo:** Aplicar todos los conocimientos en un análisis completo

**PCAPs múltiples:** Todos los disponibles

**Duración:** 90-120 minutos

### Tarea: Análisis Forense de Red WiFi Comprometida

**Contexto:**
Has sido contratado como auditor de seguridad para analizar una red WiFi corporativa que sufrió un incidente de seguridad. Se sospecha que un atacante realizó:
1. Reconnaissance (escaneo de redes)
2. Captura de handshake WPA2
3. ARP spoofing para MitM
4. Interceptación de tráfico HTTP
5. Session hijacking

**Tu tarea:**
Analizar los PCAPs proporcionados y crear un informe forense completo.

### Fase 1: Reconnaissance Analysis

```bash
# Analizar beacons y probe requests
echo "=== FASE 1: RECONNAISSANCE ===" > wifi_lab/reports/auditoria_completa.txt

echo "" >> wifi_lab/reports/auditoria_completa.txt
echo "[+] Redes WiFi detectadas:" >> wifi_lab/reports/auditoria_completa.txt

for PCAP in wifi_lab/pcaps/*/*.{pcap,pcapng,cap}; do
    if [ -f "$PCAP" ]; then
        echo "    Analizando: $(basename $PCAP)" >> wifi_lab/reports/auditoria_completa.txt
        tshark -r "$PCAP" -Y "wlan.fc.type_subtype == 0x08" -T fields -e wlan.ssid 2>/dev/null | \
          sort -u | while read SSID_HEX; do
            if [ -n "$SSID_HEX" ] && [ "$SSID_HEX" != "<MISSING>" ]; then
                SSID_ASCII=$(echo "$SSID_HEX" | xxd -r -p 2>/dev/null || echo "$SSID_HEX")
                echo "        SSID: $SSID_ASCII" >> wifi_lab/reports/auditoria_completa.txt
            fi
        done
    fi
done
```

### Fase 2: Attack Vector Identification

```bash
echo "" >> wifi_lab/reports/auditoria_completa.txt
echo "=== FASE 2: VECTORES DE ATAQUE ===" >> wifi_lab/reports/auditoria_completa.txt

# Buscar deauth attacks
echo "" >> wifi_lab/reports/auditoria_completa.txt
echo "[+] Deauth attacks detectados:" >> wifi_lab/reports/auditoria_completa.txt
for PCAP in wifi_lab/pcaps/*/*.{pcap,pcapng,cap}; do
    if [ -f "$PCAP" ]; then
        DEAUTH_COUNT=$(tshark -r "$PCAP" -Y "wlan.fc.type_subtype == 0x0c" 2>/dev/null | wc -l | tr -d ' ')
        if [ "$DEAUTH_COUNT" -gt 0 ]; then
            echo "    $(basename $PCAP): $DEAUTH_COUNT frames" >> wifi_lab/reports/auditoria_completa.txt
        fi
    fi
done

# Buscar ARP spoofing
echo "" >> wifi_lab/reports/auditoria_completa.txt
echo "[+] Indicadores de ARP spoofing:" >> wifi_lab/reports/auditoria_completa.txt
if [ -f wifi_lab/pcaps/attacks/arp_spoofing.pcap ]; then
    tshark -r wifi_lab/pcaps/attacks/arp_spoofing.pcap -Y "arp.opcode == 2" 2>/dev/null | \
      wc -l >> wifi_lab/reports/auditoria_completa.txt
fi
```

### Fase 3: Data Exfiltration Analysis

```bash
echo "" >> wifi_lab/reports/auditoria_completa.txt
echo "=== FASE 3: EXFILTRACIÓN DE DATOS ===" >> wifi_lab/reports/auditoria_completa.txt

# HTTP traffic analysis
echo "" >> wifi_lab/reports/auditoria_completa.txt
echo "[+] Tráfico HTTP no cifrado:" >> wifi_lab/reports/auditoria_completa.txt
if [ -f wifi_lab/pcaps/misc/http_captive_portal.cap ]; then
    echo "    Hosts contactados:" >> wifi_lab/reports/auditoria_completa.txt
    tshark -r wifi_lab/pcaps/misc/http_captive_portal.cap -Y "http.request" -T fields -e http.host 2>/dev/null | \
      sort -u >> wifi_lab/reports/auditoria_completa.txt
fi
```

### Fase 4: Timeline Reconstruction

```bash
echo "" >> wifi_lab/reports/auditoria_completa.txt
echo "=== FASE 4: LÍNEA DE TIEMPO ===" >> wifi_lab/reports/auditoria_completa.txt

# Crear timeline de eventos
echo "" >> wifi_lab/reports/auditoria_completa.txt
echo "[+] Timeline de eventos sospechosos:" >> wifi_lab/reports/auditoria_completa.txt
echo "    1. [Tiempo] Reconnaissance - Scan de redes" >> wifi_lab/reports/auditoria_completa.txt
echo "    2. [Tiempo] Ataque - Captura de handshake WPA2" >> wifi_lab/reports/auditoria_completa.txt
echo "    3. [Tiempo] Ataque - ARP spoofing iniciado" >> wifi_lab/reports/auditoria_completa.txt
echo "    4. [Tiempo] Exfiltración - Tráfico HTTP interceptado" >> wifi_lab/reports/auditoria_completa.txt
```

### Entrega Final

```bash
echo "" >> wifi_lab/reports/auditoria_completa.txt
echo "=== RECOMENDACIONES ===" >> wifi_lab/reports/auditoria_completa.txt
echo "" >> wifi_lab/reports/auditoria_completa.txt
echo "1. INMEDIATAS:" >> wifi_lab/reports/auditoria_completa.txt
echo "   - Cambiar todas las contraseñas WiFi" >> wifi_lab/reports/auditoria_completa.txt
echo "   - Habilitar 802.11w (MFP)" >> wifi_lab/reports/auditoria_completa.txt
echo "   - Implementar HTTPS everywhere" >> wifi_lab/reports/auditoria_completa.txt
echo "" >> wifi_lab/reports/auditoria_completa.txt
echo "2. CORTO PLAZO:" >> wifi_lab/reports/auditoria_completa.txt
echo "   - Migrar a WPA3" >> wifi_lab/reports/auditoria_completa.txt
echo "   - Implementar 802.1X (WPA2-Enterprise)" >> wifi_lab/reports/auditoria_completa.txt
echo "   - Deploy IDS/IPS wireless" >> wifi_lab/reports/auditoria_completa.txt
echo "" >> wifi_lab/reports/auditoria_completa.txt
echo "3. LARGO PLAZO:" >> wifi_lab/reports/auditoria_completa.txt
echo "   - Segmentación de red (VLANs)" >> wifi_lab/reports/auditoria_completa.txt
echo "   - Monitoreo continuo de seguridad" >> wifi_lab/reports/auditoria_completa.txt
echo "   - Capacitación en seguridad para usuarios" >> wifi_lab/reports/auditoria_completa.txt

echo ""
echo "[✓] Auditoría completa generada en: wifi_lab/reports/auditoria_completa.txt"
```

---

## Rúbrica de Evaluación

### Nivel Básico (30%)
- [x] Uso correcto de tshark
- [x] Filtros de Wireshark básicos
- [x] Identificación de tipos de frames
- [x] Extracción de información básica (SSID, BSSID, MACs)

### Nivel Intermedio (40%)
- [x] Análisis de 4-way handshake
- [x] Extracción de nonces y MIC
- [x] Detección de anomalías en DNS
- [x] Uso de aircrack-ng

### Nivel Avanzado (30%)
- [x] Detección de ARP spoofing
- [x] Análisis forense de tráfico HTTP
- [x] PMKID extraction
- [x] Reporte de auditoría completo

---

## Recursos Adicionales

### Referencias
- IEEE 802.11i-2004 Standard
- Wi-Fi Alliance WPA3 Specification
- NIST SP 800-153 (Guidelines for Securing Wireless Local Area Networks)
- [KRACK Attack](https://www.krackattacks.com/)
- [Dragonblood](https://wpa3.mathyvanhoef.com/)
- [PMKID Attack](https://hashcat.net/forum/thread-7717.html)

### Herramientas
- **Wireshark** - https://www.wireshark.org/
- **tshark** - CLI de Wireshark
- **aircrack-ng** - https://www.aircrack-ng.org/
- **hcxtools** - https://github.com/ZerBea/hcxtools
- **hashcat** - https://hashcat.net/

### Cheat Sheets
- Ver `CHEATSHEET.md` para referencia rápida de comandos
- Ver `INSTRUCTOR_GUIDE.md` para soluciones completas

---

**Universidad Tecnológica Nacional**
**Laboratorio de Blockchain & Ciberseguridad**

*Material educativo para análisis defensivo*
