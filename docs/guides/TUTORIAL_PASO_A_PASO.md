# 🎓 Tutorial Paso a Paso - Laboratorio WiFi Security

## Guía Completa con Verificación de Cada Paso

**Tiempo estimado**: 30-45 minutos
**Nivel**: Principiante a Intermedio

---

## 📋 Tabla de Contenidos

1. [Detección del Sistema Operativo](#1-detección-del-sistema-operativo)
2. [Instalación de Herramientas](#2-instalación-de-herramientas)
3. [Descarga Manual de PCAPs](#3-descarga-manual-de-pcaps)
4. [Verificación de Archivos](#4-verificación-de-archivos)
5. [Análisis de Cada PCAP](#5-análisis-de-cada-pcap)
6. [Ejercicios Prácticos](#6-ejercicios-prácticos)

---

## 1. Detección del Sistema Operativo

### Paso 1.1: Identificar tu Sistema

Abre una terminal y ejecuta:

```bash
uname -a
```

**Salida esperada (ejemplos):**

**macOS:**
```
Darwin MacBook-Pro.local 23.0.0 Darwin Kernel Version...
```

**Ubuntu/Debian:**
```
Linux hostname 5.15.0-91-generic #101-Ubuntu SMP...
```

**Arch Linux:**
```
Linux hostname 6.6.1-arch1-1 #1 SMP PREEMPT_DYNAMIC...
```

### Paso 1.2: Verificar distribución (Linux)

Si estás en Linux, ejecuta:

```bash
cat /etc/os-release
```

**Salida esperada:**
```
NAME="Ubuntu"
VERSION="22.04.3 LTS (Jammy Jellyfish)"
ID=ubuntu
...
```

✅ **Checkpoint**: Anota tu sistema operativo para los siguientes pasos.

---

## 2. Instalación de Herramientas

### macOS - Paso 2.1

#### 2.1.1: Verificar/Instalar Homebrew

```bash
# Verificar si está instalado
which brew
```

**Si está instalado verás**: `/opt/homebrew/bin/brew` o `/usr/local/bin/brew`

**Si NO está instalado**, ejecutar:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**Verificar instalación:**
```bash
brew --version
```

**Salida esperada:**
```
Homebrew 4.1.20
```

✅ **Checkpoint 1**: Homebrew instalado y funcionando

#### 2.1.2: Instalar Wireshark y tshark

```bash
brew install wireshark
```

**Durante la instalación verás:**
```
==> Downloading https://ghcr.io/v2/homebrew/core/wireshark/...
==> Pouring wireshark--4.0.8.arm64_sonoma.bottle.tar.gz
...
```

**Verificar:**
```bash
tshark --version
```

**Salida esperada:**
```
TShark (Wireshark) 4.0.8 (v4.0.8-0-g81696bb74857)
```

✅ **Checkpoint 2**: Wireshark/tshark instalados

#### 2.1.3: Instalar aircrack-ng

```bash
brew install aircrack-ng
```

**Verificar:**
```bash
aircrack-ng --help | head -5
```

**Salida esperada:**
```
Aircrack-ng 1.7

  usage: aircrack-ng [options] <input file(s)>
```

✅ **Checkpoint 3**: aircrack-ng instalado

#### 2.1.4: Instalar herramientas opcionales

```bash
# hcxtools (para PMKID)
brew install hcxtools

# Verificar
hcxpcapngtool --version
```

**Salida esperada:**
```
hcxpcapngtool 6.3.0
```

```bash
# hashcat (para cracking - OPCIONAL)
brew install hashcat

# Verificar
hashcat --version
```

**Salida esperada:**
```
hashcat (v6.2.6)
```

✅ **Checkpoint 4**: Todas las herramientas instaladas en macOS

---

### Ubuntu/Debian - Paso 2.2

#### 2.2.1: Actualizar repositorios

```bash
sudo apt update
```

**Salida esperada:**
```
Hit:1 http://archive.ubuntu.com/ubuntu jammy InRelease
Get:2 http://security.ubuntu.com/ubuntu jammy-security InRelease
...
Reading package lists... Done
```

✅ **Checkpoint 1**: Repositorios actualizados

#### 2.2.2: Instalar Wireshark y tshark

```bash
sudo apt install -y wireshark tshark
```

**Durante la instalación aparecerá:**
```
Should non-superusers be able to capture packets? [yes/no]
```

**Responder: yes**

**Verificar:**
```bash
tshark --version
```

**Salida esperada:**
```
TShark (Wireshark) 3.6.2
```

✅ **Checkpoint 2**: Wireshark instalado

#### 2.2.3: Instalar aircrack-ng

```bash
sudo apt install -y aircrack-ng
```

**Verificar:**
```bash
aircrack-ng --version
```

**Salida esperada:**
```
Aircrack-ng 1.6
```

✅ **Checkpoint 3**: aircrack-ng instalado

#### 2.2.4: Configurar permisos

```bash
# Agregar usuario al grupo wireshark
sudo usermod -aG wireshark $USER

# Verificar
groups $USER
```

**Salida esperada (debe incluir "wireshark"):**
```
usuario : usuario adm dialout cdrom ... wireshark
```

⚠️ **IMPORTANTE**: Hacer logout y login para que los cambios tomen efecto.

✅ **Checkpoint 4**: Permisos configurados

---

### Windows (WSL2) - Paso 2.3

#### 2.3.1: Verificar WSL2

```powershell
# En PowerShell (como administrador)
wsl --status
```

**Salida esperada:**
```
Default Distribution: Ubuntu
Default Version: 2
```

**Si WSL no está instalado:**
```powershell
wsl --install
```

#### 2.3.2: Dentro de WSL2

Una vez en la terminal de Ubuntu (WSL):

```bash
sudo apt update
sudo apt install -y wireshark tshark aircrack-ng wget curl
```

**Seguir los mismos pasos que Ubuntu/Debian**

✅ **Checkpoint**: Herramientas instaladas en WSL2

---

## 3. Descarga Manual de PCAPs

### Paso 3.1: Crear Estructura de Directorios

```bash
# Crear estructura
mkdir -p wifi_lab/pcaps/{wpa2,wpa3,wep,attacks,misc}
mkdir -p wifi_lab/{outputs,reports,scripts}

# Entrar al directorio
cd wifi_lab

# Verificar estructura
ls -la
```

**Salida esperada:**
```
drwxr-xr-x  outputs
drwxr-xr-x  pcaps
drwxr-xr-x  reports
drwxr-xr-x  scripts
```

✅ **Checkpoint 1**: Estructura creada

### Paso 3.2: Descargar PCAPs Uno por Uno

#### PCAP 1: WPA Handshake (ESENCIAL ⭐)

```bash
# Descargar
curl -L -o pcaps/wpa2/wpa_induction.pcap.gz \
  "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/wpa-Induction.pcap.gz"

# Verificar descarga
ls -lh pcaps/wpa2/wpa_induction.pcap.gz
```

**Salida esperada:**
```
-rw-r--r-- 1 usuario grupo 70K Oct 17 10:30 pcaps/wpa2/wpa_induction.pcap.gz
```

**Descomprimir:**
```bash
gunzip pcaps/wpa2/wpa_induction.pcap.gz

# Verificar
ls -lh pcaps/wpa2/
```

**Salida esperada:**
```
-rw-r--r-- 1 usuario grupo 175K Oct 17 10:30 wpa_induction.pcap
```

**Verificar contenido:**
```bash
tshark -r pcaps/wpa2/wpa_induction.pcap -q -z io,phs | head -10
```

**Salida esperada:**
```
===================================================================
Protocol Hierarchy Statistics
Filter:

radiotap                                 frames:1093 bytes:161786
  wlan_radio                             frames:1093 bytes:161786
    wlan                                 frames:1093 bytes:161786
```

✅ **PCAP 1 Descargado y Verificado**: wpa_induction.pcap (175KB)

---

#### PCAP 2: WPA EAP-TLS

```bash
curl -L -o pcaps/wpa2/wpa_eap_tls.pcap.gz \
  "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/wpa-eap-tls.pcap.gz"

gunzip pcaps/wpa2/wpa_eap_tls.pcap.gz

# Verificar
tshark -r pcaps/wpa2/wpa_eap_tls.pcap -c 5
```

**Salida esperada (primeros 5 paquetes):**
```
    1   0.000000 Cisco-Li_XX:XX:XX → Broadcast    802.11 ...
    2   0.102400 Cisco-Li_XX:XX:XX → Broadcast    802.11 ...
...
```

✅ **PCAP 2 Descargado y Verificado**: wpa_eap_tls.pcap (~32KB)

---

#### PCAP 3: Cisco Wireless

```bash
curl -L -o pcaps/misc/cisco_wireless.pcap.gz \
  "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/ciscowl.pcap.gz"

gunzip pcaps/misc/cisco_wireless.pcap.gz

# Verificar cantidad de paquetes
tshark -r pcaps/misc/cisco_wireless.pcap | wc -l
```

**Salida esperada:**
```
416
```

✅ **PCAP 3 Descargado y Verificado**: cisco_wireless.pcap (416 paquetes)

---

#### PCAP 4: Mobile Network Join

```bash
curl -L -o pcaps/misc/mobile_network_join.pcap \
  "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/Network_Join_Nokia_Mobile.pcap"

# Verificar
tshark -r pcaps/misc/mobile_network_join.pcap -q -z conv,wlan
```

**Salida esperada:**
```
Conversation Statistics > WLAN
...
```

✅ **PCAP 4 Descargado y Verificado**: mobile_network_join.pcap

---

#### PCAP 5: DHCP Traffic

```bash
curl -L -o pcaps/misc/dhcp_traffic.pcap \
  "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/dhcp.pcap"

# Verificar paquetes DHCP
tshark -r pcaps/misc/dhcp_traffic.pcap -Y "dhcp"
```

**Salida esperada:**
```
    1   0.000000 0.0.0.0 → 255.255.255.255 DHCP 314 DHCP Discover - Transaction ID 0x3d1d
...
```

✅ **PCAP 5 Descargado y Verificado**: dhcp_traffic.pcap

---

#### PCAP 6: RADIUS Authentication

```bash
curl -L -o pcaps/misc/radius_auth.pcapng \
  "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/radius_localhost.pcapng"

# Verificar
tshark -r pcaps/misc/radius_auth.pcapng -c 3
```

**Salida esperada:**
```
    1   0.000000 127.0.0.1 → 127.0.0.1    RADIUS ...
```

✅ **PCAP 6 Descargado y Verificado**: radius_auth.pcapng

---

### Paso 3.3: Resumen de Descargas

```bash
# Ver todos los archivos descargados
find pcaps -type f -name "*.pcap*" -exec ls -lh {} \;
```

**Salida esperada:**
```
-rw-r--r-- 1 usuario grupo 175K ... pcaps/wpa2/wpa_induction.pcap
-rw-r--r-- 1 usuario grupo  32K ... pcaps/wpa2/wpa_eap_tls.pcap
-rw-r--r-- 1 usuario grupo  32K ... pcaps/misc/cisco_wireless.pcap
-rw-r--r-- 1 usuario grupo  48K ... pcaps/misc/mobile_network_join.pcap
-rw-r--r-- 1 usuario grupo  14K ... pcaps/misc/dhcp_traffic.pcap
-rw-r--r-- 1 usuario grupo   8K ... pcaps/misc/radius_auth.pcapng
```

**Contar archivos:**
```bash
find pcaps -type f | wc -l
```

**Salida esperada:**
```
6
```

✅ **Checkpoint Final Descarga**: 6 PCAPs descargados correctamente

---

## 4. Verificación de Archivos

### Paso 4.1: Generar Checksums

```bash
# Generar checksums SHA256
find pcaps -type f -name "*.pcap*" -exec shasum -a 256 {} \; > manifest.sha256

# Ver checksums
cat manifest.sha256
```

**Salida esperada:**
```
a1b2c3d4... pcaps/wpa2/wpa_induction.pcap
e5f6g7h8... pcaps/wpa2/wpa_eap_tls.pcap
...
```

### Paso 4.2: Validar Integridad

```bash
# Verificar checksums
shasum -a 256 -c manifest.sha256
```

**Salida esperada:**
```
pcaps/wpa2/wpa_induction.pcap: OK
pcaps/wpa2/wpa_eap_tls.pcap: OK
pcaps/misc/cisco_wireless.pcap: OK
pcaps/misc/mobile_network_join.pcap: OK
pcaps/misc/dhcp_traffic.pcap: OK
pcaps/misc/radius_auth.pcapng: OK
```

✅ **Checkpoint**: Integridad de archivos verificada

---

## 5. Análisis de Cada PCAP

### PCAP 1: WPA Handshake (wpa_induction.pcap) ⭐

Este es el más importante para el laboratorio.

#### 5.1.1: Información General

```bash
capinfos pcaps/wpa2/wpa_induction.pcap
```

**Salida esperada:**
```
File name:           pcaps/wpa2/wpa_induction.pcap
File type:           Wireshark/tcpdump/... - pcap
File encapsulation:  IEEE 802.11 Radiotap
Number of packets:   1093
File size:           175 kB
Data size:           161 kB
Capture duration:    16.094726 seconds
...
```

#### 5.1.2: Buscar EAPOL Frames (4-Way Handshake)

```bash
tshark -r pcaps/wpa2/wpa_induction.pcap -Y "eapol"
```

**Salida esperada:**
```
   87   5.649953 Cisco-Li_82:b2:55 → Apple_82:36:3a EAPOL 181 Key (Message 1 of 4)
   89   5.650959 Apple_82:36:3a → Cisco-Li_82:b2:55 EAPOL 181 Key (Message 2 of 4)
   92   5.655957 Cisco-Li_82:b2:55 → Apple_82:36:3a EAPOL 239 Key (Message 3 of 4)
   94   5.655973 Apple_82:36:3a → Cisco-Li_82:b2:55 EAPOL 159 Key (Message 4 of 4)
```

✅ **PERFECTO**: Handshake completo de 4 mensajes!

#### 5.1.3: Contar Frames EAPOL

```bash
tshark -r pcaps/wpa2/wpa_induction.pcap -Y "eapol" | wc -l
```

**Salida esperada:**
```
4
```

#### 5.1.4: Extraer SSID

```bash
tshark -r pcaps/wpa2/wpa_induction.pcap -Y "wlan.ssid" -T fields -e wlan.ssid | grep -v "^$" | sort -u
```

**Salida esperada (en hexadecimal):**
```
436f6865726572
6c696e6b737973
```

**Convertir a texto:**
```bash
echo "436f6865726572" | xxd -r -p
```

**Salida:**
```
Coherer
```

#### 5.1.5: Extraer BSSID (MAC del AP)

```bash
tshark -r pcaps/wpa2/wpa_induction.pcap -Y "wlan.fc.type_subtype == 0x08" -T fields -e wlan.bssid | head -1
```

**Salida esperada:**
```
00:0c:41:82:b2:55
```

#### 5.1.6: Analizar Nonces (para detectar KRACK)

```bash
tshark -r pcaps/wpa2/wpa_induction.pcap -Y "eapol" -T fields -e eapol.keydes.nonce
```

**Salida esperada (nonces diferentes = OK):**
```
a1b2c3d4e5f6...
b2c3d4e5f6g7...
c3d4e5f6g7h8...
d4e5f6g7h8i9...
```

✅ **Análisis PCAP 1 Completo**

---

### PCAP 2: WPA EAP-TLS (wpa_eap_tls.pcap)

#### 5.2.1: Buscar paquetes EAP

```bash
tshark -r pcaps/wpa2/wpa_eap_tls.pcap -Y "eap"
```

**Salida esperada:**
```
   XX   X.XXXXXX ... EAP Request, Identity
   XX   X.XXXXXX ... EAP Response, Identity
   XX   X.XXXXXX ... EAP Request, TLS (TLS)
...
```

#### 5.2.2: Contar paquetes EAP

```bash
tshark -r pcaps/wpa2/wpa_eap_tls.pcap -Y "eap" | wc -l
```

**Salida esperada:**
```
30+ paquetes
```

✅ **Análisis PCAP 2 Completo**

---

### PCAP 3: Cisco Wireless (cisco_wireless.pcap)

#### 5.3.1: Ver tipos de frames

```bash
tshark -r pcaps/misc/cisco_wireless.pcap -Y "wlan" -T fields -e wlan.fc.type_subtype | sort | uniq -c
```

**Salida esperada:**
```
  150 0x08  (Beacon)
   80 0x04  (Probe Request)
   50 0x05  (Probe Response)
  ...
```

#### 5.3.2: Ver SSIDs

```bash
tshark -r pcaps/misc/cisco_wireless.pcap -Y "wlan.ssid" -T fields -e wlan.ssid | grep -v "^$" | sort -u
```

**Salida esperada:**
```
(Lista de SSIDs en hex)
```

✅ **Análisis PCAP 3 Completo**

---

### PCAP 4: Mobile Network Join

#### 5.4.1: Ver proceso de asociación

```bash
tshark -r pcaps/misc/mobile_network_join.pcap -Y "wlan.fc.type_subtype == 0x00 || wlan.fc.type_subtype == 0x01"
```

**Salida esperada:**
```
   XX Association Request
   XX Association Response
```

✅ **Análisis PCAP 4 Completo**

---

### PCAP 5: DHCP Traffic

#### 5.5.1: Ver secuencia DHCP

```bash
tshark -r pcaps/misc/dhcp_traffic.pcap -Y "dhcp"
```

**Salida esperada (DORA sequence):**
```
   1 DHCP Discover
   2 DHCP Offer
   3 DHCP Request
   4 DHCP ACK
```

✅ **Análisis PCAP 5 Completo**

---

### PCAP 6: RADIUS Authentication

#### 5.6.1: Ver paquetes RADIUS

```bash
tshark -r pcaps/misc/radius_auth.pcapng -Y "radius"
```

**Salida esperada:**
```
   1 RADIUS Access-Request
   2 RADIUS Access-Challenge
   3 RADIUS Access-Request
   4 RADIUS Access-Accept
```

✅ **Análisis PCAP 6 Completo**

---

## 6. Ejercicios Prácticos

### Ejercicio 1: Análisis del 4-Way Handshake

#### 6.1: Preparar script

```bash
cd ..  # Volver al directorio principal
bash analysis_scripts/01_handshake_analysis.sh
```

**Salida esperada:**
```
==========================================
  Ejercicio 1: WPA2 4-Way Handshake
==========================================

[+] Analizando handshake WPA2...

Archivo: ./wifi_lab/pcaps/wpa2/wpa_induction.pcap

--- TAREA 1: Contar EAPOL frames ---

Total de frames EAPOL encontrados: 4

Desglose de EAPOL messages:
Frame 87: 00:0c:41:82:b2:55 -> 00:0d:93:82:36:3a (Key Info: 0x008a)
Frame 89: 00:0d:93:82:36:3a -> 00:0c:41:82:b2:55 (Key Info: 0x010a)
Frame 92: 00:0c:41:82:b2:55 -> 00:0d:93:82:36:3a (Key Info: 0x13ca)
Frame 94: 00:0d:93:82:36:3a -> 00:0c:41:82:b2:55 (Key Info: 0x030a)

--- TAREA 2: Información del Handshake ---

SSID de la red:
436f6865726572

BSSID (MAC del AP):
00:0c:41:82:b2:55

Estaciones (clientes) conectadas:
00:0c:41:82:b2:53
00:0c:41:82:b2:55
00:0d:1d:06:e0:f2
00:0d:93:82:36:3a

--- TAREA 3: Exportar handshake para cracking ---

[!] hcxpcapngtool no instalado (opcional)
[✓] PCAP copiado para aircrack-ng: ./wifi_lab/outputs/handshake_aircrack.cap

--- Comandos para practicar (DEFENSIVO) ---

1. Ver handshake completo en Wireshark:
   wireshark ./wifi_lab/pcaps/wpa2/wpa_induction.pcap -Y 'eapol'

2. Verificar integridad del handshake:
   aircrack-ng ./wifi_lab/outputs/handshake_aircrack.cap

3. Analizar nonces y detectar ataques de reutilización:
   tshark -r ./wifi_lab/pcaps/wpa2/wpa_induction.pcap -Y 'eapol' -T fields -e eapol.keydes.nonce

========================================
PREGUNTAS PARA RESPONDER:
========================================

1. ¿Cuántos mensajes EAPOL componen un 4-way handshake completo?
   Respuesta esperada: 4

2. ¿Qué información se intercambia en cada mensaje?
   - Mensaje 1: ANonce (del AP al cliente)
   - Mensaje 2: SNonce + MIC (del cliente al AP)
   - Mensaje 3: GTK + MIC (del AP al cliente)
   - Mensaje 4: ACK (del cliente al AP)

3. ¿Qué campo permite identificar ataques KRACK (reutilización de nonces)?
   Respuesta: El campo eapol.keydes.nonce

4. ¿Cómo se puede detectar un ataque de deautenticación previo al handshake?
   Comando: tshark -r [PCAP] -Y "wlan.fc.type_subtype == 0x0c"

5. ¿Qué ventajas tiene PMKID attack sobre capturar el handshake completo?
   Respuesta: No requiere esperar a que un cliente se conecte

[✓] Ejercicio 1 completado. Revisar outputs en: ./wifi_lab/outputs
```

✅ **Ejercicio 1 Completado**

---

### Ejercicio 2: Verificar Handshake con aircrack-ng

```bash
aircrack-ng wifi_lab/outputs/handshake_aircrack.cap
```

**Salida esperada:**
```
Opening wifi_lab/outputs/handshake_aircrack.cap
Read 1093 packets.

   #  BSSID              ESSID                     Encryption

   1  00:0C:41:82:B2:55  Coherer                   WPA (1 handshake)

Choosing first network as target.
```

**Interpretación:**
- ✅ 1 handshake detectado
- ✅ BSSID identificado correctamente
- ✅ ESSID (SSID) identificado: "Coherer"
- ✅ Tipo de cifrado: WPA

✅ **Handshake válido confirmado por aircrack-ng**

---

### Ejercicio 3: Análisis Visual con Wireshark

```bash
wireshark wifi_lab/pcaps/wpa2/wpa_induction.pcap -Y 'eapol' &
```

**Qué buscar en Wireshark:**

1. **Frame 87 (Message 1 of 4)**:
   - Source: AP (00:0c:41:82:b2:55)
   - Destination: Client (00:0d:93:82:36:3a)
   - Contiene: ANonce
   - Key Information: 0x008a

2. **Frame 89 (Message 2 of 4)**:
   - Source: Client
   - Destination: AP
   - Contiene: SNonce + MIC
   - Key Information: 0x010a

3. **Frame 92 (Message 3 of 4)**:
   - Source: AP
   - Destination: Client
   - Contiene: GTK + MIC
   - Key Information: 0x13ca

4. **Frame 94 (Message 4 of 4)**:
   - Source: Client
   - Destination: AP
   - Contiene: ACK
   - Key Information: 0x030a

**Screenshot esperado en Wireshark:**
```
[Frame 87] EAPOL Key (Message 1 of 4)
  ├─ Version: 802.1X-2001
  ├─ Type: Key (3)
  ├─ Key Information: 0x008a
  ├─ Key Nonce: a1b2c3d4e5f6... (ANonce)
  └─ ...

[Frame 89] EAPOL Key (Message 2 of 4)
  ├─ Key Information: 0x010a
  ├─ Key Nonce: b2c3d4e5f6g7... (SNonce)
  ├─ Key MIC: present
  └─ ...
```

✅ **Análisis visual completo**

---

### Ejercicio 4: Análisis de DHCP

```bash
tshark -r wifi_lab/pcaps/misc/dhcp_traffic.pcap -Y "dhcp" -T fields \
  -e frame.number \
  -e dhcp.option.dhcp \
  -e dhcp.option.requested_ip_address \
  -e dhcp.option.dhcp_server_id
```

**Salida esperada:**
```
1  1  (Discover)  -              -
2  2  (Offer)     192.168.1.100  192.168.1.1
3  3  (Request)   192.168.1.100  192.168.1.1
4  5  (ACK)       192.168.1.100  192.168.1.1
```

**Interpretación:**
- ✅ Secuencia DORA completa
- ✅ Cliente recibe IP: 192.168.1.100
- ✅ Servidor DHCP: 192.168.1.1

✅ **Análisis DHCP completo**

---

## 7. Validación Final

### Paso 7.1: Ejecutar script de validación

```bash
bash validate_setup.sh
```

**Salida esperada:**
```
╔══════════════════════════════════════════════════════════╗
║     Validación de Laboratorio WiFi                      ║
╚══════════════════════════════════════════════════════════╝

Verificando herramientas requeridas...

[✓] Tshark (Wireshark CLI): instalado
    Versión: TShark (Wireshark) 4.0.8
[✓] Aircrack-ng: instalado
    Versión: Aircrack-ng 1.7
[✓] wget: instalado
    Versión: GNU Wget 1.21.3
[✓] sha256sum: instalado
    Versión: sha256sum (Darwin) 1.0

Verificando herramientas opcionales...

[✓] Wireshark (GUI): instalado
[✓] hcxtools (PMKID extraction): instalado
[!] Hashcat (password recovery): NO INSTALADO (opcional)
[!] tree (visualización de directorios): NO INSTALADO (opcional)
[✓] capinfos (PCAP info): instalado

Verificando estructura de directorios...

[✓] Directorio WPA2 PCAPs: OK (2 archivos)
[✓] Directorio WPA3 PCAPs: OK (0 archivos)
[✓] Directorio WEP PCAPs: OK (0 archivos)
[✓] Directorio Attack PCAPs: OK (0 archivos)
[✓] Directorio Misc PCAPs: OK (4 archivos)
[✓] Directorio Outputs: OK (1 archivos)
[✓] Directorio Reports: OK (0 archivos)

[✓] Manifest de integridad: OK

Verificando scripts de análisis...

[✓] Ejercicio 1: Handshake Analysis: OK (ejecutable)
[✓] Ejercicio 2: PMKID Analysis: OK (ejecutable)
[✓] Ejercicio 3: Deauth Detection: OK (ejecutable)
[✓] Ejercicio 4: WPA3 Analysis: OK (ejecutable)
[✓] Ejercicio 5: Traffic Analysis: OK (ejecutable)

Verificando PCAPs descargados...

[✓] Total de PCAPs encontrados: 6

Desglose por categoría:
  • wpa2: 2 archivos
  • misc: 4 archivos

Verificando integridad (checksums)...
[✓] Integridad de PCAPs: VERIFICADA

Ejecutando test básico de tshark...

Analizando: wifi_lab/pcaps/misc/cisco_wireless.pcap
[✓] tshark funciona correctamente: 416 paquetes leídos

╔══════════════════════════════════════════════════════════╗
║                    RESUMEN DE VALIDACIÓN                 ║
╚══════════════════════════════════════════════════════════╝

  ✓ Verificaciones exitosas: 25
  ! Advertencias:             2
  ✗ Errores:                  0

[✓] Instalación completada exitosamente

Próximos pasos:
  1. Ejecutar: bash setup_wifi_lab.sh
  2. Validar: bash validate_setup.sh
```

✅ **VALIDACIÓN COMPLETA EXITOSA**

---

## 8. Resumen de Evidencias

### 8.1: Tabla de Verificación

| Item | Verificación | Evidencia | Estado |
|------|--------------|-----------|--------|
| **SO Detectado** | `uname -a` | macOS/Linux/Windows | ✅ |
| **Homebrew** (macOS) | `brew --version` | v4.1.20 | ✅ |
| **tshark** | `tshark --version` | v4.0.8 | ✅ |
| **aircrack-ng** | `aircrack-ng --version` | v1.7 | ✅ |
| **hcxtools** | `hcxpcapngtool --version` | v6.3.0 | ✅ |
| **PCAP 1** | `ls -lh wpa_induction.pcap` | 175KB | ✅ |
| **PCAP 2** | `ls -lh wpa_eap_tls.pcap` | 32KB | ✅ |
| **PCAP 3** | `ls -lh cisco_wireless.pcap` | 32KB | ✅ |
| **PCAP 4** | `ls -lh mobile_network_join.pcap` | 48KB | ✅ |
| **PCAP 5** | `ls -lh dhcp_traffic.pcap` | 14KB | ✅ |
| **PCAP 6** | `ls -lh radius_auth.pcapng` | 8KB | ✅ |
| **Handshake** | `tshark -Y "eapol"` | 4 frames | ✅ |
| **SSID** | `tshark -Y "wlan.ssid"` | "Coherer" | ✅ |
| **BSSID** | Frame analysis | 00:0c:41:82:b2:55 | ✅ |
| **Aircrack-ng** | `aircrack-ng handshake` | 1 handshake válido | ✅ |
| **Checksums** | `shasum -c manifest` | All OK | ✅ |
| **Scripts** | `ls analysis_scripts/` | 5 scripts | ✅ |
| **Validación** | `validate_setup.sh` | 25/25 OK | ✅ |

### 8.2: Capturas de Pantalla Sugeridas

Para documentar completamente el laboratorio, tomar capturas de:

1. **Terminal mostrando tshark --version**
2. **Terminal mostrando aircrack-ng --version**
3. **Listado de PCAPs descargados (ls -lh)**
4. **Salida de 4-way handshake (tshark -Y "eapol")**
5. **Wireshark mostrando el handshake visualmente**
6. **Salida de aircrack-ng validando el handshake**
7. **Script de análisis ejecutándose**
8. **Salida de validate_setup.sh (éxito)**

---

## 9. Troubleshooting

### Problema: PCAP no descarga

**Solución:**
```bash
# Verificar conectividad
ping -c 3 wiki.wireshark.org

# Intentar con wget si curl falla
wget -O archivo.pcap.gz "URL"

# Verificar proxy si estás en red corporativa
echo $http_proxy
```

### Problema: "Permission denied" en tshark

**macOS:**
```bash
brew install --cask wireshark
# Esto instala ChmodBPF automáticamente
```

**Linux:**
```bash
sudo usermod -aG wireshark $USER
# Logout y login
```

### Problema: Handshake no válido

**Verificar:**
```bash
# ¿El PCAP tiene EAPOL frames?
tshark -r pcap -Y "eapol" | wc -l
# Debe ser 4 (o múltiplo de 4)

# ¿Los frames están completos?
tshark -r pcap -Y "eapol" -V | grep "Key Information"
```

---

## 10. Conclusión

Si completaste todos los pasos y todos los checkpoints están en ✅, entonces:

🎉 **¡LABORATORIO COMPLETAMENTE CONFIGURADO Y FUNCIONAL!**

**Tienes:**
- ✅ 6 PCAPs verificados y listos
- ✅ Handshake WPA2 completo y válido
- ✅ Todas las herramientas instaladas
- ✅ Scripts de análisis funcionales
- ✅ Ejercicios listos para ejecutar

**Próximos pasos:**
1. Revisar `EJERCICIOS.md` para guías detalladas
2. Ejecutar los 5 ejercicios secuencialmente
3. Consultar `CHEATSHEET.md` para comandos rápidos
4. Usar `INSTRUCTOR_GUIDE.md` si eres el profesor

---

**Tiempo total invertido**: ~30-45 minutos
**Resultado**: Laboratorio WiFi Security completamente funcional ✅

**¡Éxito con tus prácticas!** 🎓🔐
