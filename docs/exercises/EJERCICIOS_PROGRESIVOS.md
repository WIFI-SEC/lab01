# 🎓 Ejercicios Progresivos de Seguridad WiFi

**Nivel: Básico → Intermedio → Avanzado**

Este documento contiene ejercicios estructurados progresivamente para que los alumnos aprendan análisis forense de redes WiFi, desde conceptos fundamentales hasta escenarios de ataque avanzados. Cada ejercicio incluye teoría detallada, explicaciones paso a paso y ejercicios prácticos.

---

## 📊 Índice de Ejercicios

### Nivel Básico
1. **Explorando PCAPs** - Familiarización con Wireshark y tshark
2. **Frames WiFi Básicos** - Beacon, Probe Request, Association
3. **DHCP y Conexión a Red** - Proceso completo de conexión

### Nivel Intermedio
4. **WPA2 4-Way Handshake** - Análisis profundo del handshake
5. **EAPOL y Nonces** - Extracción de datos criptográficos
6. **DNS Analysis** - Detección de anomalías en DNS

### Nivel Avanzado
7. **ARP Spoofing Detection** - Detectar ataques Man-in-the-Middle
8. **HTTP Traffic Analysis** - Captive portals y session hijacking
9. **PMKID Attack Simulation** - Extracción y cracking offline

### Escenario Integrador
10. **Auditoría Completa de Red WiFi** - Aplicación de todos los conocimientos

---

# NIVEL BÁSICO

---

## Ejercicio 1: Explorando PCAPs con tshark

### 🎯 Objetivo

Familiarizarse con las herramientas de análisis de paquetes (tshark/Wireshark) y comprender la estructura básica de archivos PCAP conteniendo tráfico WiFi 802.11.

### 📚 Fundamentos Teóricos

#### ¿Qué es un PCAP?

PCAP (Packet Capture) es un formato de archivo estándar para almacenar capturas de tráfico de red. Fue desarrollado por tcpdump/libpcap y es el formato más utilizado en análisis forense de redes.

**Estructura de un archivo PCAP:**
```
┌─────────────────────────────┐
│  Global Header              │  ← Metadatos del archivo
│  - Magic Number (a1b2c3d4)  │
│  - Version (2.4)            │
│  - Timezone                 │
│  - Snaplen (max bytes)      │
│  - Network Type (802.11)    │
├─────────────────────────────┤
│  Packet 1 Header            │  ← Frame #1
│  - Timestamp                │
│  - Captured Length          │
│  - Original Length          │
├─────────────────────────────┤
│  Packet 1 Data              │
│  (Raw bytes del frame)      │
├─────────────────────────────┤
│  Packet 2 Header            │  ← Frame #2
│  ...                        │
└─────────────────────────────┘
```

#### ¿Qué es tshark?

**tshark** es la versión CLI (Command Line Interface) de Wireshark. Permite:
- Analizar PCAPs sin interfaz gráfica
- Automatizar análisis mediante scripts
- Filtrar y extraer información específica
- Generar estadísticas y reportes

**Ventajas de tshark vs Wireshark GUI:**
- ✅ Automatizable (scripts bash, python)
- ✅ Uso remoto via SSH
- ✅ Menor consumo de recursos
- ✅ Ideal para análisis de grandes volúmenes
- ✅ Output procesable (grep, awk, sed)

**PCAP utilizado:** `wifi_lab/pcaps/wpa2/wpa_induction.pcap` (175KB)

Este PCAP contiene una captura real de un proceso de autenticación WPA2-PSK, incluyendo:
- Beacon frames del Access Point
- Proceso de asociación cliente-AP
- 4-way handshake completo (4 frames EAPOL)
- Tráfico de datos encriptado

---

### Paso 1: Información General del PCAP

**Objetivo:** Obtener estadísticas generales del archivo de captura.

```bash
# Ver estadísticas globales del PCAP
tshark -r wifi_lab/pcaps/wpa2/wpa_induction.pcap -q -z io,stat,0
```

**Explicación del comando:**
- `-r <archivo>` → **Read**: Lee el archivo PCAP especificado
- `-q` → **Quiet**: Modo silencioso, solo muestra el resultado de -z
- `-z io,stat,0` → **Statistics**: Calcula estadísticas de I/O
  - `io,stat` → Tipo de estadística (Input/Output)
  - `0` → Intervalo en segundos (0 = toda la captura en un solo intervalo)

**Output esperado:**
```
===================================================================
| IO Statistics                                                   |
|                                                                 |
| Duration: 3.5 seconds                                           |
| Interval: 0 secs                                                |
|                                                                 |
| Col 1: Frames and bytes                                        |
|-----------------------------------------------------------------|
|              |1               |                                 |
| Interval     | Frames | Bytes |                                 |
|-----------------------------------------------------------------|
|  0 <>  3.5   |    102 | 34567 |                                 |
===================================================================
```

**Análisis del resultado:**
- **Duration**: Tiempo total de la captura (3.5 segundos)
- **Frames**: Número total de frames capturados (102)
- **Bytes**: Bytes totales capturados (~34KB)

**Preguntas de comprensión:**
1. ¿Por qué una captura de 3.5 segundos puede contener 102 frames?
   - *Respuesta*: En WiFi, hay alta frecuencia de frames de management (beacons cada ~100ms) y control.

2. ¿Cuál es el tamaño promedio de frame en esta captura?
   - *Cálculo*: 34567 bytes / 102 frames ≈ 339 bytes por frame

---

### Paso 2: Listar Primeros Frames

**Objetivo:** Visualizar los primeros frames para entender el contenido del PCAP.

```bash
# Ver los primeros 10 frames con información básica
tshark -r wifi_lab/pcaps/wpa2/wpa_induction.pcap -c 10
```

**Explicación del comando:**
- `-c 10` → **Count**: Limita la salida a los primeros 10 frames

**Output esperado:**
```
    1   0.000000 00:0c:41:82:b2:55 → Broadcast    802.11 Beacon frame, SN=2543
    2   0.001234 00:0d:93:82:36:3a → 00:0c:41:82:b2:55 802.11 Probe Req, SN=0
    3   0.102400 00:0c:41:82:b2:55 → Broadcast    802.11 Beacon frame, SN=2544
    4   0.150000 00:0c:41:82:b2:55 → 00:0d:93:82:36:3a 802.11 Probe Resp, SN=2545
    ...
```

**Estructura de cada línea:**
```
[Frame#] [Timestamp] [Source MAC] → [Dest MAC] [Protocol] [Info]
```

- **Frame #**: Número secuencial del frame en el PCAP
- **Timestamp**: Tiempo relativo desde el inicio de la captura
- **Source MAC**: Dirección MAC origen (quien envía)
- **Dest MAC**: Dirección MAC destino (quien recibe)
- **Protocol**: Tipo de protocolo (802.11, EAPOL, etc.)
- **Info**: Descripción del frame

**Tipos de frames visibles:**
1. **Beacon frame** → AP anuncia su presencia (broadcast cada ~100ms)
2. **Probe Request** → Cliente busca redes disponibles
3. **Probe Response** → AP responde a la búsqueda

---

### Paso 3: Filtrar por Tipo de Frame

**Objetivo:** Aplicar filtros de Wireshark para aislar tipos específicos de frames.

#### Teoría: Frame Control Field (802.11)

Cada frame WiFi 802.11 tiene un campo **Frame Control** de 2 bytes que especifica:

```
Frame Control (16 bits)
├─ Type (2 bits)       ← Management (00), Control (01), Data (10)
├─ Subtype (4 bits)    ← Beacon (1000), Probe Req (0100), etc.
└─ Flags (10 bits)     ← ToDS, FromDS, Retry, etc.
```

**Type/Subtype combinados (hex):**

| Type | Subtype | Hex | Nombre |
|------|---------|-----|--------|
| 00 (Management) | 0000 | 0x00 | Association Request |
| 00 (Management) | 0001 | 0x01 | Association Response |
| 00 (Management) | 0100 | 0x04 | Probe Request |
| 00 (Management) | 0101 | 0x05 | Probe Response |
| 00 (Management) | 1000 | 0x08 | Beacon |
| 00 (Management) | 1011 | 0x0b | Authentication |
| 00 (Management) | 1100 | 0x0c | Deauthentication |
| 10 (Data) | 0000 | 0x20 | Data |

#### Filtrar Beacon Frames

```bash
# Filtrar solo beacon frames (type/subtype = 0x08)
tshark -r wifi_lab/pcaps/wpa2/wpa_induction.pcap -Y "wlan.fc.type_subtype == 0x08" -c 5
```

**Explicación del comando:**
- `-Y "filter"` → **Display filter**: Aplica filtro de visualización
- `wlan.fc.type_subtype == 0x08` → Filtra frames con Type/Subtype = Beacon
  - `wlan.fc` → Frame Control field
  - `type_subtype` → Valor combinado Type+Subtype
  - `== 0x08` → Hexadecimal 0x08 = Beacon

**Output esperado:**
```
    1   0.000000 00:0c:41:82:b2:55 → Broadcast    802.11 Beacon frame, SN=2543, FN=0, Flags=........C
    3   0.102400 00:0c:41:82:b2:55 → Broadcast    802.11 Beacon frame, SN=2544, FN=0, Flags=........C
    5   0.204800 00:0c:41:82:b2:55 → Broadcast    802.11 Beacon frame, SN=2545, FN=0, Flags=........C
```

**Análisis:**
- Todos los beacons provienen de la misma MAC: `00:0c:41:82:b2:55` (el AP)
- Destino: **Broadcast** (FF:FF:FF:FF:FF:FF) → Todos los dispositivos
- Intervalo: ~102ms entre beacons (estándar 802.11: 100ms TU - Time Units)
- **SN** (Sequence Number) incrementa: 2543, 2544, 2545...

**¿Por qué los beacons son importantes?**
- Anuncian la presencia del AP
- Contienen el SSID (nombre de la red)
- Incluyen capacidades del AP (tasas soportadas, cifrado, canal)
- Permiten sincronización de tiempo entre AP y clientes

---

### Paso 4: Extraer el SSID de la Red

**Objetivo:** Identificar el nombre de la red WiFi capturada.

#### Teoría: SSID (Service Set Identifier)

El **SSID** es el nombre de la red WiFi (máximo 32 bytes). Se transmite:
- En **Beacon frames** (anuncio periódico del AP)
- En **Probe Response** (respuesta a búsquedas de clientes)
- En **Association Request** (solicitud de conexión)

En el PCAP, el SSID se almacena en **formato hexadecimal**.

```bash
# Extraer todos los SSID únicos (en hexadecimal)
tshark -r wifi_lab/pcaps/wpa2/wpa_induction.pcap -Y "wlan.ssid" -T fields -e wlan.ssid | sort -u
```

**Explicación del comando:**
- `-T fields` → **Output format**: Formato de campos (no líneas completas)
- `-e wlan.ssid` → **Extract field**: Extraer solo el campo SSID
- `sort -u` → Ordenar y eliminar duplicados (unique)

**Output esperado:**
```
436f6865726572
```

Este es el SSID en **hexadecimal**. Para convertirlo a ASCII:

```bash
# Convertir hex → ASCII usando xxd
echo "436f6865726572" | xxd -r -p
```

**Explicación del comando:**
- `echo "..."` → Imprime el string hexadecimal
- `xxd -r -p` → **Reverse hex dump**
  - `-r` → Reverse (hex → binario)
  - `-p` → Plain (sin formato, solo datos)

**Resultado:**
```
Coherer
```

**Dato histórico:** "Coherer" fue un detector de ondas de radio primitivo usado en telegrafía inalámbrica (~1890s). Nombre apropiado para una red WiFi educativa.

---

### Paso 5: Identificar Dispositivos (Direcciones MAC)

**Objetivo:** Identificar todos los dispositivos participantes en la comunicación.

#### Teoría: Direcciones MAC en WiFi

En WiFi 802.11, hay **4 campos de dirección** posibles (no todos se usan siempre):

```
802.11 Frame
├─ Address 1 (Destination Address - DA)  ← A quién va dirigido
├─ Address 2 (Source Address - SA)       ← Quién lo envía
├─ Address 3 (BSSID)                     ← MAC del AP
└─ Address 4 (usado solo en WDS)         ← Opcional
```

**BSSID (Basic Service Set Identifier):**
- Es la dirección MAC del Access Point
- Identifica únicamente al AP
- Diferente del SSID (que es el nombre de texto)

```bash
# Extraer todas las direcciones MAC origen (Source Address)
tshark -r wifi_lab/pcaps/wpa2/wpa_induction.pcap -T fields -e wlan.sa | sort -u
```

**Explicación:**
- `wlan.sa` → **Source Address** (dirección MAC origen)

**Output esperado:**
```
00:0c:41:82:b2:55
00:0d:93:82:36:3a
```

**Identificación:**
- `00:0c:41:82:b2:55` → **Access Point (AP)**
  - Prefijo OUI `00:0c:41` → Cisco Systems
  - Envía beacons, probe responses, EAPOL messages

- `00:0d:93:82:36:3a` → **Cliente (STA - Station)**
  - Prefijo OUI `00:0d:93` → Apple Inc.
  - Envía probe requests, association, EAPOL responses

#### Verificar el BSSID del AP

```bash
# Extraer BSSID de los beacon frames
tshark -r wifi_lab/pcaps/wpa2/wpa_induction.pcap -Y "wlan.fc.type_subtype == 0x08" -T fields -e wlan.bssid | head -1
```

**Output:**
```
00:0c:41:82:b2:55
```

Confirmado: `00:0c:41:82:b2:55` es el BSSID del Access Point.

---

### 📝 Ejercicios Prácticos

#### Tarea 1: Contar Beacon Frames

**Pregunta:** ¿Cuántos beacon frames existen en total en esta captura?

```bash
tshark -r wifi_lab/pcaps/wpa2/wpa_induction.pcap -Y "wlan.fc.type_subtype == 0x08" | wc -l
```

**Explicación:**
- El filtro `wlan.fc.type_subtype == 0x08` selecciona solo beacons
- `wc -l` (word count lines) cuenta las líneas = número de beacons

**Resultado esperado:** ~35 beacons (en 3.5 segundos, uno cada ~100ms)

**Análisis:** Si la captura dura 3.5s y hay beacons cada 100ms:
```
Beacons esperados = 3.5 segundos / 0.1 segundos = 35 beacons
```

---

#### Tarea 2: Contar Probe Requests

**Pregunta:** ¿Cuántos probe requests envió el cliente?

```bash
tshark -r wifi_lab/pcaps/wpa2/wpa_induction.pcap -Y "wlan.fc.type_subtype == 0x04" | wc -l
```

**Explicación:**
- `0x04` → Probe Request (cliente busca redes)

**Resultado esperado:** 1-3 probe requests

**Análisis:** El cliente envía probe requests cuando:
1. Busca una red específica (directed probe)
2. Busca cualquier red disponible (broadcast probe)
3. Antes de asociarse con el AP

---

#### Tarea 3: Exportar Frames EAPOL

**Objetivo:** Extraer y guardar los frames EAPOL (parte del 4-way handshake).

```bash
# Exportar frames EAPOL a un archivo de texto
tshark -r wifi_lab/pcaps/wpa2/wpa_induction.pcap -Y "eapol" > wifi_lab/outputs/ejercicio1_eapol.txt

# Visualizar el archivo creado
cat wifi_lab/outputs/ejercicio1_eapol.txt
```

**Explicación:**
- `"eapol"` → Filtro para frames **EAP over LAN** (autenticación WPA2)
- `>` → Redirección de output a archivo
- `cat` → Muestra el contenido del archivo

**Output esperado:**
```
   87   2.123456 00:0c:41:82:b2:55 → 00:0d:93:82:36:3a EAPOL Key (Message 1/4)
   89   2.125678 00:0d:93:82:36:3a → 00:0c:41:82:b2:55 EAPOL Key (Message 2/4)
   92   2.127890 00:0c:41:82:b2:55 → 00:0d:93:82:36:3a EAPOL Key (Message 3/4)
   94   2.130000 00:0d:93:82:36:3a → 00:0c:41:82:b2:55 EAPOL Key (Message 4/4)
```

**Análisis:**
- **4 frames EAPOL** → Handshake WPA2 **completo** ✓
- **Dirección alterna** → AP ↔ Cliente (intercambio bidireccional)
- **Timing:** Los 4 mensajes ocurren en ~6ms (2.123 → 2.130)

**¿Por qué es importante?**
- Solo con los 4 frames del handshake se puede **intentar crackear** la contraseña WPA2
- Esto es lo que buscan los atacantes en ataques de captura de handshake

---

### 🎓 Resumen del Ejercicio 1

**Has aprendido:**

✅ **Conceptos:**
- Estructura de archivos PCAP
- Diferencia entre tshark (CLI) y Wireshark (GUI)
- Frame Control field en 802.11
- Tipos de frames: Management, Control, Data
- SSID vs BSSID
- Direcciones MAC en WiFi

✅ **Comandos tshark:**
- `-r <file>` → Leer PCAP
- `-q -z io,stat,0` → Estadísticas
- `-c N` → Limitar a N frames
- `-Y "filter"` → Display filter
- `-T fields -e <field>` → Extraer campos específicos
- `wc -l` → Contar líneas

✅ **Filtros de Wireshark:**
- `wlan.fc.type_subtype == 0x08` → Beacons
- `wlan.fc.type_subtype == 0x04` → Probe Requests
- `eapol` → Frames de autenticación WPA2
- `wlan.ssid` → SSID de la red
- `wlan.sa` → Source Address (MAC origen)

**Próximo paso:** Ejercicio 2 - Frames WiFi Básicos (tipos de management frames)

---

## Ejercicio 2: Frames WiFi Básicos

### 🎯 Objetivo

Comprender en profundidad los diferentes tipos de frames 802.11 y el proceso completo de asociación de un cliente a un Access Point.

### 📚 Fundamentos Teóricos

#### Arquitectura 802.11

El estándar IEEE 802.11 define tres tipos principales de frames:

```
802.11 Frames
│
├── Management Frames (Type = 00)  ← Gestión de la red
│   ├── Beacon (0x08)              ← AP anuncia su presencia
│   ├── Probe Request (0x04)       ← Cliente busca redes
│   ├── Probe Response (0x05)      ← AP responde
│   ├── Authentication (0x0b)      ← Autenticación Open/Shared
│   ├── Deauthentication (0x0c)    ← Desconexión
│   ├── Association Req (0x00)     ← Cliente pide asociarse
│   ├── Association Resp (0x01)    ← AP acepta/rechaza
│   ├── Reassociation Req (0x02)   ← Cambio de AP
│   └── Disassociation (0x0a)      ← Terminar asociación
│
├── Control Frames (Type = 01)     ← Control de acceso al medio
│   ├── RTS (Request To Send)      ← Reserva de canal
│   ├── CTS (Clear To Send)        ← Confirmación de reserva
│   ├── ACK (Acknowledgment)       ← Confirmación de recepción
│   └── Block ACK                  ← ACK múltiple
│
└── Data Frames (Type = 10)        ← Datos de usuario
    ├── Data (0x20)                ← Datos normales
    ├── QoS Data (0x28)            ← Datos con calidad de servicio
    └── Null Data (0x24)           ← Sin datos (keep-alive)
```

#### Proceso de Conexión WiFi (Paso a Paso)

Cuando un cliente se conecta a un AP, sigue este proceso:

```
Cliente (STA)                    Access Point (AP)
     |                                  |
     |  1. ESCUCHA BEACONS              |
     |<----------(Beacon)---------------|  Broadcast cada ~100ms
     |         "Red disponible"         |
     |                                  |
     |  2. PROBE (Búsqueda activa)      |
     |--------(Probe Request)---------->|  "¿Hay redes disponibles?"
     |<-------(Probe Response)----------|  "Sí, aquí estoy"
     |                                  |
     |  3. AUTHENTICATION (Open System) |
     |------(Auth Request)------------->|  "Quiero autenticarme"
     |<-----(Auth Response)-------------|  "OK, autenticado"
     |          Status: Success         |
     |                                  |
     |  4. ASSOCIATION                  |
     |-----(Association Request)------->|  "Quiero asociarme"
     |    Capabilities, Rates, SSID     |
     |<---(Association Response)--------|  "Asociado (AID=1)"
     |      Status: Success, AID        |
     |                                  |
     |  5. DHCP (Obtención de IP)       |
     |--------(DHCP Discover)---------->|
     |<-------(DHCP Offer)--------------|
     |--------(DHCP Request)----------->|
     |<-------(DHCP ACK)----------------|  IP asignada
     |                                  |
     |  6. 4-WAY HANDSHAKE (WPA2)       |
     |<-------(EAPOL 1/4)---------------|  ANonce del AP
     |--------(EAPOL 2/4)-------------->|  SNonce + MIC
     |<-------(EAPOL 3/4)---------------|  GTK + MIC
     |--------(EAPOL 4/4)-------------->|  Confirmación
     |                                  |
     |  7. DATOS CIFRADOS               |
     |<========DATA ENCRYPTED==========>|
     |                                  |
```

**PCAP utilizado:** `wifi_lab/pcaps/misc/mobile_network_join.pcap` (161KB)

Este PCAP captura un dispositivo móvil uniéndose a una red WiFi, mostrando todo el proceso de conexión.

---

### Paso 1: Analizar Beacon Frames en Detalle

**Objetivo:** Examinar la información que un AP anuncia en sus beacons.

```bash
# Ver beacons con SSID y BSSID
tshark -r wifi_lab/pcaps/misc/mobile_network_join.pcap \
  -Y "wlan.fc.type_subtype == 0x08" \
  -T fields \
  -e frame.number \
  -e wlan.ssid \
  -e wlan.bssid \
  -e wlan.channel \
  | head -5
```

**Explicación del comando multi-línea:**
- `\` → Continuación de línea (permite comandos largos en múltiples líneas)
- `-e frame.number` → Número del frame
- `-e wlan.ssid` → SSID (en hex)
- `-e wlan.bssid` → BSSID del AP
- `-e wlan.channel` → Canal WiFi (1-14 en 2.4GHz, 36-165 en 5GHz)

**Output esperado:**
```
1    <SSID_hex>    aa:bb:cc:dd:ee:ff    6
5    <SSID_hex>    aa:bb:cc:dd:ee:ff    6
9    <SSID_hex>    aa:bb:cc:dd:ee:ff    6
```

#### Analizar Capacidades del AP

```bash
# Ver información extendida del primer beacon
tshark -r wifi_lab/pcaps/misc/mobile_network_join.pcap \
  -Y "wlan.fc.type_subtype == 0x08" \
  -V | head -100
```

**Explicación:**
- `-V` → **Verbose**: Muestra decodificación detallada de cada frame
- `head -100` → Primeras 100 líneas (un beacon típico tiene 50-80 líneas)

**Información visible en un beacon:**

```
IEEE 802.11 Beacon frame
    Fixed parameters (12 bytes)
        Timestamp: 123456789            ← Tiempo del AP (sincronización)
        Beacon Interval: 0.102400       ← Intervalo entre beacons (100ms)
        Capabilities: 0x0431            ← Capacidades del AP
            .... .... .... ...1 = ESS   ← Es un AP (no Ad-hoc)
            .... .... .... ..1. = Privacy ← Cifrado habilitado (WEP/WPA/WPA2)

    Tagged parameters
        Tag: SSID                       ← Nombre de la red
        Tag: Supported Rates            ← Velocidades: 1, 2, 5.5, 11 Mbps...
        Tag: DS Parameter set: Channel 6 ← Canal WiFi
        Tag: RSN Information            ← WPA2/WPA3 info
            Version: 1
            Group Cipher Suite: AES (CCM)
            Pairwise Cipher Suite: AES (CCM)
            Auth Key Management: PSK    ← WPA2-Personal
```

**¿Por qué es importante analizar beacons?**
- Revelan **configuración del AP** (canal, cifrado, velocidades)
- Permiten **fingerprinting** del fabricante
- Detectar **rogue APs** (APs falsos con mismo SSID)
- Identificar **WPS enabled** (vulnerable a ataques Pixie Dust/PIN brute force)

---

### Paso 2: Probe Request/Response (Descubrimiento Activo)

**Objetivo:** Analizar cómo los clientes buscan redes disponibles.

#### Teoría: Tipos de Probe Requests

Existen dos tipos:

1. **Broadcast Probe Request** → Busca **cualquier** red
   ```
   Cliente: "¿Hay alguna red WiFi disponible?"
   Todos los APs: "Sí, yo estoy aquí (mi SSID es X)"
   ```

2. **Directed Probe Request** → Busca una red **específica**
   ```
   Cliente: "¿Está disponible la red 'MiCasa'?"
   AP 'MiCasa': "Sí, aquí estoy"
   Otros APs: (no responden)
   ```

```bash
# Ver probe requests del cliente
tshark -r wifi_lab/pcaps/misc/mobile_network_join.pcap \
  -Y "wlan.fc.type_subtype == 0x04" \
  -T fields \
  -e frame.number \
  -e wlan.sa \
  -e wlan.ssid
```

**Análisis del output:**
```
12    11:22:33:44:55:66    <vacío>        ← Broadcast probe (SSID vacío)
15    11:22:33:44:55:66    4d69436173    ← Directed probe (SSID="MiCasa")
```

**Privacidad:**
- Los **directed probe requests** revelan las redes que el dispositivo conoce
- Un atacante puede saber: "Este dispositivo suele conectarse a 'Trabajo', 'Casa', 'CafeX'"
- **Solución:** Randomización de MAC y probe request privacy (802.11u)

```bash
# Ver probe responses del AP
tshark -r wifi_lab/pcaps/misc/mobile_network_join.pcap \
  -Y "wlan.fc.type_subtype == 0x05" \
  -T fields \
  -e frame.number \
  -e wlan.da \
  -e wlan.ssid
```

---

### Paso 3: Proceso de Autenticación (Authentication)

**Objetivo:** Analizar el intercambio de authentication frames.

#### Teoría: Open System Authentication

En redes modernas (WPA2/WPA3), la autenticación 802.11 es **Open System**:

```
Frame 1: Client → AP
    Authentication Algorithm: Open System (0)
    Transaction Sequence: 1
    Status: <ninguno>

Frame 2: AP → Client
    Authentication Algorithm: Open System (0)
    Transaction Sequence: 2
    Status Code: Successful (0x0000)
```

**Importante:** Esta "autenticación" **NO verifica la contraseña WiFi**.
- Es solo un paso administrativo del protocolo 802.11
- La verdadera autenticación WPA2 ocurre en el **4-way handshake** (EAPOL)

```bash
# Ver frames de authentication
tshark -r wifi_lab/pcaps/misc/mobile_network_join.pcap \
  -Y "wlan.fc.type_subtype == 0x0b" \
  -V | grep -A 20 "Authentication"
```

**Campos importantes:**
- **Algorithm**: 0 = Open System, 1 = Shared Key (obsoleto, WEP)
- **Transaction Sequence**: 1 = Request, 2 = Response
- **Status Code**:
  - `0x0000` = Successful
  - `0x0001` = Unspecified failure
  - `0x000d` = Invalid authentication algorithm

---

### Paso 4: Proceso de Asociación (Association)

**Objetivo:** Analizar cómo el cliente se asocia formalmente con el AP.

#### Teoría: Association Request

El cliente envía un **Association Request** con:

```
Association Request Frame
├─ Capabilities Information
│  ├─ ESS: 1 (modo infraestructura)
│  ├─ Privacy: 1 (cifrado requerido)
│  ├─ Short Preamble: 1
│  └─ Channel Agility: 0
│
├─ Listen Interval: 10 ← Cada cuántos beacons el cliente escucha
│
├─ Tagged Parameters
│  ├─ SSID: "MiRed"
│  ├─ Supported Rates: 1, 2, 5.5, 11, 6, 9, 12, 18 Mbps
│  ├─ Extended Supported Rates: 24, 36, 48, 54 Mbps
│  ├─ RSN (WPA2 info)
│  └─ HT Capabilities (802.11n)
```

```bash
# Ver association request
tshark -r wifi_lab/pcaps/misc/mobile_network_join.pcap \
  -Y "wlan.fc.type_subtype == 0x00" \
  -V | grep -A 30 "Association Request"
```

#### Association Response

El AP responde con:

```
Association Response Frame
├─ Capabilities Information (igual que el request)
├─ Status Code: 0x0000 (Successful)
├─ Association ID (AID): 1 ← ID único del cliente en este AP
└─ Supported Rates
```

**AID (Association ID):**
- Número único (1-2007) asignado al cliente
- Usado en power saving (AP buffers traffic for sleeping STAs)
- Usado en group addressing

```bash
# Ver association response con AID
tshark -r wifi_lab/pcaps/misc/mobile_network_join.pcap \
  -Y "wlan.fc.type_subtype == 0x01" \
  -T fields \
  -e frame.number \
  -e wlan.fixed.aid \
  -e wlan.fixed.status_code
```

**Output esperado:**
```
45    0x0001    0x0000
```

- `AID = 0x0001` → Primer cliente asociado
- `Status = 0x0000` → Successful

---

### 📝 Ejercicio Práctico: Reconstruir Secuencia Completa

**Objetivo:** Identificar y ordenar todos los pasos de la conexión WiFi.

```bash
#!/bin/bash
# Script: reconstruir_conexion.sh

PCAP="wifi_lab/pcaps/misc/mobile_network_join.pcap"

echo "======================================"
echo " SECUENCIA COMPLETA DE CONEXIÓN WiFi"
echo "======================================"
echo ""

echo "[1] BEACONS (AP anuncia su presencia)"
echo "────────────────────────────────────"
tshark -r "$PCAP" -Y "wlan.fc.type_subtype == 0x08" -T fields \
  -e frame.number -e frame.time_relative -e wlan.ssid | head -3
echo ""

echo "[2] PROBE REQUEST (Cliente busca redes)"
echo "────────────────────────────────────"
tshark -r "$PCAP" -Y "wlan.fc.type_subtype == 0x04" -T fields \
  -e frame.number -e frame.time_relative -e wlan.sa | head -1
echo ""

echo "[3] PROBE RESPONSE (AP responde)"
echo "────────────────────────────────────"
tshark -r "$PCAP" -Y "wlan.fc.type_subtype == 0x05" -T fields \
  -e frame.number -e frame.time_relative -e wlan.da | head -1
echo ""

echo "[4] AUTHENTICATION REQUEST"
echo "────────────────────────────────────"
tshark -r "$PCAP" -Y "wlan.fc.type_subtype == 0x0b && wlan.fixed.auth.seq == 1" \
  -T fields -e frame.number -e frame.time_relative | head -1
echo ""

echo "[5] AUTHENTICATION RESPONSE"
echo "────────────────────────────────────"
tshark -r "$PCAP" -Y "wlan.fc.type_subtype == 0x0b && wlan.fixed.auth.seq == 2" \
  -T fields -e frame.number -e frame.time_relative | head -1
echo ""

echo "[6] ASSOCIATION REQUEST"
echo "────────────────────────────────────"
tshark -r "$PCAP" -Y "wlan.fc.type_subtype == 0x00" \
  -T fields -e frame.number -e frame.time_relative | head -1
echo ""

echo "[7] ASSOCIATION RESPONSE"
echo "────────────────────────────────────"
tshark -r "$PCAP" -Y "wlan.fc.type_subtype == 0x01" \
  -T fields -e frame.number -e frame.time_relative -e wlan.fixed.aid | head -1
echo ""

echo "✓ Cliente ahora asociado al AP con AID"
echo "  Siguiente paso: DHCP para obtener IP"
echo "  Luego: 4-Way Handshake WPA2 (EAPOL)"
```

**Guardar y ejecutar:**
```bash
chmod +x reconstruir_conexion.sh
./reconstruir_conexion.sh
```

---

### 🎓 Resumen del Ejercicio 2

**Has aprendido:**

✅ **Conceptos:**
- Tres tipos de frames: Management, Control, Data
- Proceso completo de asociación WiFi (7 pasos)
- Diferencia entre Authentication 802.11 (open) y WPA2 (EAPOL)
- AID (Association ID) y su propósito
- Probe requests revelan privacidad del usuario
- RSN IE contiene información de cifrado WPA2/WPA3

✅ **Frame types:**
- `0x08` → Beacon (anuncio del AP)
- `0x04` → Probe Request (búsqueda activa)
- `0x05` → Probe Response (respuesta del AP)
- `0x0b` → Authentication (open system)
- `0x00` → Association Request (cliente pide asociarse)
- `0x01` → Association Response (AP asigna AID)

✅ **Campos importantes:**
- `wlan.ssid` → Nombre de la red
- `wlan.bssid` → MAC del AP
- `wlan.sa/da` → Source/Destination Address
- `wlan.channel` → Canal WiFi
- `wlan.fixed.aid` → Association ID
- `wlan.fixed.status_code` → Código de éxito/error

**Próximo paso:** Ejercicio 3 - DHCP y obtención de dirección IP

---

## Ejercicio 3: DHCP y Conexión Completa a la Red

### 🎯 Objetivo

Comprender el protocolo DHCP (Dynamic Host Configuration Protocol) y cómo un cliente obtiene configuración de red (IP, gateway, DNS) después de asociarse a un Access Point WiFi.

### 📚 Fundamentos Teóricos

#### ¿Qué es DHCP?

**DHCP** es un protocolo de capa de aplicación (capa 7 OSI) que permite la configuración automática de parámetros de red TCP/IP.

**Sin DHCP (configuración manual):**
```
Usuario debe configurar:
├─ Dirección IP: 192.168.1.100
├─ Máscara de subred: 255.255.255.0
├─ Gateway: 192.168.1.1
├─ DNS primario: 8.8.8.8
└─ DNS secundario: 8.8.4.4

Problemas:
❌ Tedioso para usuarios no técnicos
❌ Conflictos de IP (dos dispositivos con misma IP)
❌ Difícil de escalar (1000+ dispositivos)
```

**Con DHCP (configuración automática):**
```
Cliente conecta → Servidor DHCP asigna todo automáticamente → Listo
✅ Configuración automática
✅ Sin conflictos de IP (servidor gestiona pool)
✅ Fácil de escalar
```

#### Proceso DORA (DHCP)

DHCP usa un intercambio de 4 mensajes llamado **DORA**:

```
Cliente                          Servidor DHCP (a menudo el AP)
   |                                     |
   | [D]ISCOVER (broadcast)              |
   |------------------------------------>|  "¿Hay algún servidor DHCP?"
   |     UDP 68 → 67                     |   Source: 0.0.0.0
   |     Dest: 255.255.255.255           |   Dest: 255.255.255.255
   |                                     |
   |            [O]FFER (unicast)        |
   |<------------------------------------|  "Sí, te ofrezco 192.168.1.50"
   |     UDP 67 → 68                     |   + Gateway, DNS, Lease Time
   |     Dest: Cliente MAC o broadcast   |
   |                                     |
   | [R]EQUEST (broadcast)               |
   |------------------------------------>|  "Acepto 192.168.1.50"
   |     UDP 68 → 67                     |   (broadcast por si hay múltiples
   |     Dest: 255.255.255.255           |    servidores DHCP, rechaza otros)
   |                                     |
   |            [A]CK (unicast)          |
   |<------------------------------------|  "Confirmado, IP asignada"
   |     UDP 67 → 68                     |   Lease start time, duración
   |                                     |
   ✓ Cliente configura interfaz          |
     con IP recibida                     |
```

#### Detalles de cada mensaje

##### 1. DHCP DISCOVER

```
DHCP Discover
├─ Opcode: 1 (Boot Request)
├─ Hardware Type: Ethernet (1)
├─ Hardware Address Length: 6 bytes
├─ Transaction ID: 0x12345678 (random, identifica la transacción)
├─ Client IP: 0.0.0.0 (aún no tiene IP)
├─ Your IP: 0.0.0.0
├─ Server IP: 0.0.0.0
├─ Gateway IP: 0.0.0.0
├─ Client MAC: aa:bb:cc:dd:ee:ff
└─ Options:
   ├─ Option 53: DHCP Message Type = DISCOVER (1)
   ├─ Option 50: Requested IP Address (opcional, si renovando)
   ├─ Option 55: Parameter Request List
   │             (qué parámetros quiere: subnet, router, DNS, etc.)
   └─ Option 61: Client Identifier (MAC del cliente)
```

##### 2. DHCP OFFER

```
DHCP Offer
├─ Opcode: 2 (Boot Reply)
├─ Transaction ID: 0x12345678 (mismo que el DISCOVER)
├─ Client IP: 0.0.0.0
├─ Your IP: 192.168.1.50 ← IP propuesta
├─ Server IP: 192.168.1.1 (IP del servidor DHCP)
├─ Gateway IP: 192.168.1.1
├─ Client MAC: aa:bb:cc:dd:ee:ff
└─ Options:
   ├─ Option 53: DHCP Message Type = OFFER (2)
   ├─ Option 54: Server Identifier = 192.168.1.1
   ├─ Option 51: IP Address Lease Time = 86400 (24 horas)
   ├─ Option 1: Subnet Mask = 255.255.255.0
   ├─ Option 3: Router (Gateway) = 192.168.1.1
   └─ Option 6: DNS Servers = 8.8.8.8, 8.8.4.4
```

##### 3. DHCP REQUEST

```
DHCP Request
├─ Transaction ID: 0x12345678 (mismo)
├─ Client IP: 0.0.0.0
├─ Your IP: 0.0.0.0
├─ Server IP: 0.0.0.0
├─ Client MAC: aa:bb:cc:dd:ee:ff
└─ Options:
   ├─ Option 53: DHCP Message Type = REQUEST (3)
   ├─ Option 50: Requested IP = 192.168.1.50 ← IP que acepta
   ├─ Option 54: Server Identifier = 192.168.1.1 ← Servidor elegido
   └─ (si había múltiples OFFERs, esto rechaza los demás)
```

##### 4. DHCP ACK

```
DHCP ACK
├─ Opcode: 2 (Boot Reply)
├─ Transaction ID: 0x12345678
├─ Client IP: 0.0.0.0
├─ Your IP: 192.168.1.50 ← IP confirmada
├─ Server IP: 192.168.1.1
├─ Client MAC: aa:bb:cc:dd:ee:ff
└─ Options:
   ├─ Option 53: DHCP Message Type = ACK (5)
   ├─ Option 51: Lease Time = 86400 seconds
   ├─ Option 58: Renewal Time (T1) = 43200 (12h, 50% del lease)
   ├─ Option 59: Rebinding Time (T2) = 75600 (21h, 87.5% del lease)
   └─ (todos los parámetros de configuración repetidos)
```

**PCAP utilizado:** `wifi_lab/pcaps/misc/dhcp_traffic.pcap` (1.4KB)

Este PCAP contiene únicamente el intercambio DHCP DORA, sin el tráfico WiFi 802.11 (fue capturado a nivel Ethernet).

---

### Paso 1: Visualizar Todos los Mensajes DHCP

**Objetivo:** Identificar los 4 mensajes del proceso DORA.

```bash
# Ver todos los paquetes DHCP
tshark -r wifi_lab/pcaps/misc/dhcp_traffic.pcap -Y "dhcp"
```

**Explicación:**
- Filtro `dhcp` → Selecciona paquetes DHCP (puerto UDP 67/68)

**Output esperado:**
```
    1   0.000000 0.0.0.0 → 255.255.255.255 DHCP DHCP Discover - Transaction ID 0xabcd1234
    2   0.001523 192.168.1.1 → 192.168.1.50 DHCP DHCP Offer    - Transaction ID 0xabcd1234
    3   0.003045 0.0.0.0 → 255.255.255.255 DHCP DHCP Request  - Transaction ID 0xabcd1234
    4   0.004567 192.168.1.1 → 192.168.1.50 DHCP DHCP ACK     - Transaction ID 0xabcd1234
```

**Análisis de IPs:**
- Frame 1 (DISCOVER): `0.0.0.0` → `255.255.255.255` (broadcast, cliente sin IP)
- Frame 2 (OFFER): `192.168.1.1` → `192.168.1.50` (servidor ofrece IP)
- Frame 3 (REQUEST): `0.0.0.0` → `255.255.255.255` (broadcast, acepta IP)
- Frame 4 (ACK): `192.168.1.1` → `192.168.1.50` (servidor confirma)

**Timing:**
- Todo el proceso DORA ocurre en ~4.5 milisegundos
- En redes lentas o congestión puede tardar 1-2 segundos

---

### Paso 2: Extraer Información Detallada

**Objetivo:** Ver los campos importantes de cada mensaje DHCP.

```bash
# Extraer tipo de mensaje, IP solicitada/ofrecida, servidor
tshark -r wifi_lab/pcaps/misc/dhcp_traffic.pcap -Y "dhcp" -T fields \
  -e frame.number \
  -e dhcp.option.dhcp \
  -e dhcp.option.requested_ip_address \
  -e dhcp.option.dhcp_server_id \
  -e dhcp.option.subnet_mask \
  -e dhcp.option.router \
  -e dhcp.option.domain_name_server
```

**Explicación de los campos:**
- `dhcp.option.dhcp` → **Message Type**:
  - `1` = DISCOVER
  - `2` = OFFER
  - `3` = REQUEST
  - `4` = DECLINE (cliente rechaza IP, conflicto detectado)
  - `5` = ACK
  - `6` = NAK (servidor rechaza REQUEST)
  - `7` = RELEASE (cliente libera IP al desconectarse)
  - `8` = INFORM (cliente pide parámetros, ya tiene IP estática)

- `dhcp.option.requested_ip_address` → IP que el cliente pide (en REQUEST)
- `dhcp.option.dhcp_server_id` → IP del servidor DHCP
- `dhcp.option.subnet_mask` → Máscara de subred (ej: 255.255.255.0)
- `dhcp.option.router` → Gateway (puerta de enlace)
- `dhcp.option.domain_name_server` → Servidores DNS (pueden ser múltiples)

**Output esperado:**
```
1    1    <vacío>         <vacío>         <vacío>          <vacío>      <vacío>
2    2    192.168.1.50    192.168.1.1     255.255.255.0    192.168.1.1  8.8.8.8,8.8.4.4
3    3    192.168.1.50    192.168.1.1     <vacío>          <vacío>      <vacío>
4    5    <vacío>         192.168.1.1     255.255.255.0    192.168.1.1  8.8.8.8,8.8.4.4
```

**Interpretación:**
- Frame 1 (DISCOVER): Solo tipo=1, no tiene info de IP aún
- Frame 2 (OFFER): Tipo=2, ofrece 192.168.1.50, servidor es 192.168.1.1, DNS=Google
- Frame 3 (REQUEST): Tipo=3, pide 192.168.1.50 al servidor 192.168.1.1
- Frame 4 (ACK): Tipo=5, confirma con todos los parámetros

---

### Paso 3: Analizar Transaction ID

**Objetivo:** Verificar que los 4 mensajes pertenecen a la misma transacción.

```bash
# Extraer Transaction ID de cada mensaje
tshark -r wifi_lab/pcaps/misc/dhcp_traffic.pcap -Y "dhcp" -T fields \
  -e frame.number \
  -e dhcp.id \
  -e dhcp.option.dhcp
```

**Explicación:**
- `dhcp.id` → **Transaction ID**: Número random de 32 bits que identifica la transacción
  - Permite emparejar DISCOVER con su OFFER/REQUEST/ACK
  - Evita confusión si hay múltiples clientes haciendo DHCP simultáneamente

**Output esperado:**
```
1    0xabcd1234    1
2    0xabcd1234    2
3    0xabcd1234    3
4    0xabcd1234    4
```

Todos tienen el mismo Transaction ID (`0xabcd1234`) → Pertenecen a la misma sesión DHCP.

---

### Paso 4: Ver Lease Time (Tiempo de Concesión)

**Objetivo:** Entender por cuánto tiempo el cliente puede usar la IP asignada.

```bash
# Extraer lease time del OFFER y ACK
tshark -r wifi_lab/pcaps/misc/dhcp_traffic.pcap \
  -Y "dhcp.option.dhcp == 2 || dhcp.option.dhcp == 5" \
  -T fields \
  -e dhcp.option.dhcp \
  -e dhcp.option.ip_address_lease_time \
  -e dhcp.option.renewal_time_value \
  -e dhcp.option.rebinding_time_value
```

**Explicación:**
- `dhcp.option.ip_address_lease_time` → Duración total del lease (en segundos)
- `dhcp.option.renewal_time_value` → **T1**: Tiempo para intentar renovar (50% del lease)
- `dhcp.option.rebinding_time_value` → **T2**: Tiempo para rebinding (87.5% del lease)

**Output esperado:**
```
2    86400    43200    75600
5    86400    43200    75600
```

**Conversión a unidades comprensibles:**
- Lease Time: `86400` segundos = 24 horas
- Renewal (T1): `43200` segundos = 12 horas (50% de 24h)
- Rebinding (T2): `75600` segundos = 21 horas (87.5% de 24h)

**Timeline del Lease:**
```
0h                    12h                    21h                    24h
├──────────────────────┼──────────────────────┼──────────────────────┤
│    Usando la IP      │ T1: Intentar renovar │   T2: Rebinding      │ Lease expira
│                      │ (mismo servidor)     │ (broadcast, cualquier│ (debe hacer
│                      │                      │  servidor)           │  DISCOVER nuevo)
```

---

### Paso 5: Identificar Opciones DHCP Adicionales

**Objetivo:** Ver qué otros parámetros puede proporcionar DHCP.

```bash
# Ver OFFER completo con todas las opciones
tshark -r wifi_lab/pcaps/misc/dhcp_traffic.pcap -Y "dhcp.option.dhcp == 2" -V | grep "Option:"
```

**Opciones comunes de DHCP:**

| Option | Nombre | Descripción |
|--------|--------|-------------|
| 1 | Subnet Mask | Máscara de subred (255.255.255.0) |
| 3 | Router | Gateway / Puerta de enlace |
| 6 | DNS Server | Servidores DNS |
| 12 | Host Name | Nombre del host del cliente |
| 15 | Domain Name | Dominio DNS (ej: empresa.local) |
| 28 | Broadcast Address | Dirección de broadcast |
| 42 | NTP Server | Servidor de tiempo (Network Time Protocol) |
| 44 | WINS Server | Servidor WINS (Windows) |
| 51 | Lease Time | Tiempo de concesión |
| 54 | Server Identifier | IP del servidor DHCP |
| 58 | Renewal Time (T1) | Cuándo renovar |
| 59 | Rebinding Time (T2) | Cuándo hacer rebinding |
| 66 | TFTP Server | Para boot remoto (PXE) |
| 67 | Bootfile Name | Archivo de boot |
| 121 | Classless Static Route | Rutas estáticas adicionales |

**Ejemplo de configuración completa recibida:**
```
IP Address: 192.168.1.50
Subnet Mask: 255.255.255.0       → Red: 192.168.1.0/24
Gateway: 192.168.1.1             → Puerta de salida a Internet
DNS: 8.8.8.8, 8.8.4.4           → Resolución de nombres
Domain: home.local               → Sufijo DNS
Broadcast: 192.168.1.255         → Dirección de broadcast
Lease: 86400 segundos (24h)      → Válido por 1 día
```

---

###📝 Ejercicio Práctico: Crear Reporte de Análisis DHCP

**Objetivo:** Generar un reporte detallado del proceso DHCP.

```bash
#!/bin/bash
# Script: analizar_dhcp.sh

PCAP="wifi_lab/pcaps/misc/dhcp_traffic.pcap"
OUTPUT="wifi_lab/reports/ejercicio3_dhcp_analisis.txt"

echo "═══════════════════════════════════════════" > "$OUTPUT"
echo "      REPORTE DE ANÁLISIS DHCP" >> "$OUTPUT"
echo "═══════════════════════════════════════════" >> "$OUTPUT"
echo "" >> "$OUTPUT"
echo "PCAP Analizado: $PCAP" >> "$OUTPUT"
echo "Fecha: $(date '+%Y-%m-%d %H:%M:%S')" >> "$OUTPUT"
echo "" >> "$OUTPUT"

# Extraer información de cada mensaje
echo "───────────────────────────────────────────" >> "$OUTPUT"
echo "MENSAJE 1: DHCP DISCOVER" >> "$OUTPUT"
echo "───────────────────────────────────────────" >> "$OUTPUT"

DISCOVER=$(tshark -r "$PCAP" -Y "dhcp.option.dhcp == 1" -T fields \
  -e bootp.hw.mac_addr \
  -e dhcp.id \
  2>/dev/null | head -1)

CLIENT_MAC=$(echo "$DISCOVER" | awk '{print $1}')
TRANS_ID=$(echo "$DISCOVER" | awk '{print $2}')

echo "Cliente MAC: $CLIENT_MAC" >> "$OUTPUT"
echo "Transaction ID: $TRANS_ID" >> "$OUTPUT"
echo "Tipo: DISCOVER (búsqueda de servidor DHCP)" >> "$OUTPUT"
echo "IP Origen: 0.0.0.0 (cliente sin IP)" >> "$OUTPUT"
echo "IP Destino: 255.255.255.255 (broadcast)" >> "$OUTPUT"
echo "" >> "$OUTPUT"

echo "───────────────────────────────────────────" >> "$OUTPUT"
echo "MENSAJE 2: DHCP OFFER" >> "$OUTPUT"
echo "───────────────────────────────────────────" >> "$OUTPUT"

OFFER=$(tshark -r "$PCAP" -Y "dhcp.option.dhcp == 2" -T fields \
  -e bootp.ip.your \
  -e dhcp.option.dhcp_server_id \
  -e dhcp.option.subnet_mask \
  -e dhcp.option.router \
  -e dhcp.option.domain_name_server \
  -e dhcp.option.ip_address_lease_time \
  2>/dev/null | head -1)

OFFERED_IP=$(echo "$OFFER" | awk '{print $1}')
SERVER_IP=$(echo "$OFFER" | awk '{print $2}')
SUBNET=$(echo "$OFFER" | awk '{print $3}')
GATEWAY=$(echo "$OFFER" | awk '{print $4}')
DNS=$(echo "$OFFER" | awk '{print $5}')
LEASE=$(echo "$OFFER" | awk '{print $6}')

echo "Tipo: OFFER (servidor ofrece configuración)" >> "$OUTPUT"
echo "IP Ofrecida: $OFFERED_IP" >> "$OUTPUT"
echo "Servidor DHCP: $SERVER_IP" >> "$OUTPUT"
echo "Subnet Mask: $SUBNET" >> "$OUTPUT"
echo "Gateway: $GATEWAY" >> "$OUTPUT"
echo "DNS Servers: $DNS" >> "$OUTPUT"
echo "Lease Time: $LEASE segundos ($(($LEASE / 3600)) horas)" >> "$OUTPUT"
echo "" >> "$OUTPUT"

echo "───────────────────────────────────────────" >> "$OUTPUT"
echo "MENSAJE 3: DHCP REQUEST" >> "$OUTPUT"
echo "───────────────────────────────────────────" >> "$OUTPUT"

REQUEST=$(tshark -r "$PCAP" -Y "dhcp.option.dhcp == 3" -T fields \
  -e dhcp.option.requested_ip_address \
  -e dhcp.option.dhcp_server_id \
  2>/dev/null | head -1)

REQUESTED_IP=$(echo "$REQUEST" | awk '{print $1}')
SELECTED_SERVER=$(echo "$REQUEST" | awk '{print $2}')

echo "Tipo: REQUEST (cliente acepta oferta)" >> "$OUTPUT"
echo "IP Solicitada: $REQUESTED_IP" >> "$OUTPUT"
echo "Servidor Elegido: $SELECTED_SERVER" >> "$OUTPUT"
echo "IP Destino: 255.255.255.255 (broadcast)" >> "$OUTPUT"
echo "  → Broadcast para rechazar otros servidores si hubo múltiples OFFERs" >> "$OUTPUT"
echo "" >> "$OUTPUT"

echo "───────────────────────────────────────────" >> "$OUTPUT"
echo "MENSAJE 4: DHCP ACK" >> "$OUTPUT"
echo "───────────────────────────────────────────" >> "$OUTPUT"

ACK=$(tshark -r "$PCAP" -Y "dhcp.option.dhcp == 5" -T fields \
  -e bootp.ip.your \
  -e dhcp.option.renewal_time_value \
  -e dhcp.option.rebinding_time_value \
  2>/dev/null | head -1)

ASSIGNED_IP=$(echo "$ACK" | awk '{print $1}')
T1=$(echo "$ACK" | awk '{print $2}')
T2=$(echo "$ACK" | awk '{print $3}')

echo "Tipo: ACK (servidor confirma asignación)" >> "$OUTPUT"
echo "IP Asignada: $ASSIGNED_IP ✓" >> "$OUTPUT"
echo "Renewal Time (T1): $T1 segundos ($(($T1 / 3600)) horas)" >> "$OUTPUT"
echo "Rebinding Time (T2): $T2 segundos ($(($T2 / 3600)) horas)" >> "$OUTPUT"
echo "" >> "$OUTPUT"

echo "═══════════════════════════════════════════" >> "$OUTPUT"
echo "RESUMEN DE LA TRANSACCIÓN" >> "$OUTPUT"
echo "═══════════════════════════════════════════" >> "$OUTPUT"
echo "" >> "$OUTPUT"
echo "Cliente: $CLIENT_MAC" >> "$OUTPUT"
echo "Servidor DHCP: $SERVER_IP" >> "$OUTPUT"
echo "IP Asignada: $ASSIGNED_IP" >> "$OUTPUT"
echo "Gateway: $GATEWAY" >> "$OUTPUT"
echo "DNS: $DNS" >> "$OUTPUT"
echo "Subnet: $SUBNET" >> "$OUTPUT"
echo "Lease: $(($LEASE / 3600)) horas" >> "$OUTPUT"
echo "" >> "$OUTPUT"

echo "TIMELINE DEL LEASE:" >> "$OUTPUT"
echo "" >> "$OUTPUT"
echo "0h ────────────────> $(($T1 / 3600))h ────────────────> $(($T2 / 3600))h ────────────> $(($LEASE / 3600))h" >> "$OUTPUT"
echo "│                    │                    │                      │" >> "$OUTPUT"
echo "IP asignada          T1: Renovar          T2: Rebinding          Lease expira" >> "$OUTPUT"
echo "                     (mismo servidor)     (broadcast)            (hacer DISCOVER)" >> "$OUTPUT"
echo "" >> "$OUTPUT"

echo "═══════════════════════════════════════════" >> "$OUTPUT"
echo "ANÁLISIS DE SEGURIDAD" >> "$OUTPUT"
echo "═══════════════════════════════════════════" >> "$OUTPUT"
echo "" >> "$OUTPUT"
echo "VULNERABILIDADES DHCP:" >> "$OUTPUT"
echo "" >> "$OUTPUT"
echo "1. DHCP SPOOFING (Rogue DHCP Server)" >> "$OUTPUT"
echo "   → Atacante configura servidor DHCP falso" >> "$OUTPUT"
echo "   → Asigna gateway malicioso (Man-in-the-Middle)" >> "$OUTPUT"
echo "   → Asigna DNS malicioso (phishing, redirects)" >> "$OUTPUT"
echo "   Mitigación: DHCP Snooping (switches managed)" >> "$OUTPUT"
echo "" >> "$OUTPUT"
echo "2. DHCP STARVATION (Agotamiento de IPs)" >> "$OUTPUT"
echo "   → Atacante envía miles de DISCOVER con MACs falsas" >> "$OUTPUT"
echo "   → Agota el pool de IPs del servidor legítimo" >> "$OUTPUT"
echo "   → Nuevos clientes no pueden obtener IP" >> "$OUTPUT"
echo "   Mitigación: Rate limiting, port security" >> "$OUTPUT"
echo "" >> "$OUTPUT"
echo "3. DHCP SNOOPING BYPASS" >> "$OUTPUT"
echo "   → Atacante envía DHCP Release para desconectar víctimas" >> "$OUTPUT"
echo "   → Envenamiento de tabla DHCP snooping" >> "$OUTPUT"
echo "   Mitigación: DAI (Dynamic ARP Inspection)" >> "$OUTPUT"
echo "" >> "$OUTPUT"

echo "═══════════════════════════════════════════" >> "$OUTPUT"
echo "RECOMENDACIONES" >> "$OUTPUT"
echo "═══════════════════════════════════════════" >> "$OUTPUT"
echo "" >> "$OUTPUT"
echo "✓ Habilitar DHCP Snooping en switches" >> "$OUTPUT"
echo "✓ Configurar trusted ports solo en uplinks" >> "$OUTPUT"
echo "✓ Limitar rate de DHCP messages por puerto" >> "$OUTPUT"
echo "✓ Usar DAI para prevenir ARP spoofing" >> "$OUTPUT"
echo "✓ Monitorear logs de servidor DHCP" >> "$OUTPUT"
echo "✓ Implementar 802.1X para autenticación de puerto" >> "$OUTPUT"
echo "" >> "$OUTPUT"

echo "[✓] Reporte generado en: $OUTPUT"
cat "$OUTPUT"
```

**Guardar y ejecutar:**
```bash
chmod +x analizar_dhcp.sh
./analizar_dhcp.sh
```

---

### 🎓 Resumen del Ejercicio 3

**Has aprendido:**

✅ **Conceptos:**
- Protocolo DHCP y su importancia en redes modernas
- Proceso DORA (Discover, Offer, Request, Ack)
- Transaction ID para emparejar mensajes
- Lease time, renewal (T1), rebinding (T2)
- Opciones DHCP (subnet, gateway, DNS, domain, NTP, etc.)
- Direccionamiento IP: 0.0.0.0 (sin IP), 255.255.255.255 (broadcast)

✅ **Campos DHCP:**
- `dhcp.option.dhcp` → Tipo de mensaje (1-8)
- `dhcp.id` → Transaction ID
- `bootp.ip.your` → IP asignada/ofrecida
- `dhcp.option.dhcp_server_id` → IP del servidor
- `dhcp.option.subnet_mask` → Máscara de subred
- `dhcp.option.router` → Gateway
- `dhcp.option.domain_name_server` → DNS
- `dhcp.option.ip_address_lease_time` → Duración del lease
- `dhcp.option.renewal_time_value` → T1 (50% del lease)
- `dhcp.option.rebinding_time_value` → T2 (87.5% del lease)

✅ **Seguridad DHCP:**
- DHCP Spoofing (rogue server attack)
- DHCP Starvation (pool exhaustion)
- DHCP Snooping (mitigación en switches)
- Dynamic ARP Inspection (DAI)

**Conexión con WiFi:**
- DHCP ocurre **después** de:
  1. Asociación 802.11 (Authentication + Association)
  2. 4-way handshake WPA2 (EAPOL)
  3. **Entonces** → DHCP para obtener IP

**Próximo paso:** Ejercicio 4 - WPA2 4-Way Handshake (análisis profundo de EAPOL)

---

**FIN DEL NIVEL BÁSICO**

Has completado los fundamentos:
- ✅ Uso de tshark y filtros
- ✅ Tipos de frames 802.11
- ✅ Proceso de asociación WiFi
- ✅ Protocolo DHCP

**Siguiente nivel: INTERMEDIO**
- Criptografía WiFi
- WPA2 4-way handshake
- Extracción de nonces
- Ataques y defensas

---

