# Laboratorio de Seguridad WiFi - Ejercicios Prácticos

**Universidad Tecnológica Nacional - Laboratorio de Blockchain & Ciberseguridad**

---

## Índice

1. [Introducción](#introducción)
2. [Requisitos](#requisitos)
3. [Setup del Laboratorio](#setup-del-laboratorio)
4. [Ejercicios](#ejercicios)
   - [Ejercicio 1: Análisis de 4-Way Handshake WPA2](#ejercicio-1-análisis-de-4-way-handshake-wpa2)
   - [Ejercicio 2: PMKID Attack Analysis](#ejercicio-2-pmkid-attack-analysis)
   - [Ejercicio 3: Detección de Deauthentication Attacks](#ejercicio-3-detección-de-deauthentication-attacks)
   - [Ejercicio 4: WPA3 y SAE (Dragonfly)](#ejercicio-4-wpa3-y-sae-dragonfly)
   - [Ejercicio 5: Análisis de Tráfico sobre WiFi](#ejercicio-5-análisis-de-tráfico-sobre-wifi)
5. [Herramientas](#herramientas)
6. [Referencias](#referencias)

---

## Introducción

Este laboratorio está diseñado para **análisis defensivo** de seguridad WiFi. Utilizaremos capturas de tráfico (PCAPs) de repositorios públicos para analizar:

- Protocolos de autenticación WiFi (WPA2, WPA3)
- Ataques comunes y su detección
- Análisis forense de tráfico
- Técnicas de hardening y mitigación

**⚠️ IMPORTANTE**: Este material es para fines educativos y defensivos únicamente. El uso ofensivo de estas técnicas sin autorización es ilegal.

---

## Requisitos

### Software Necesario

```bash
# macOS
brew install wireshark tshark hcxtools aircrack-ng

# Linux (Debian/Ubuntu)
sudo apt update
sudo apt install wireshark tshark hcxtools aircrack-ng

# Verificar instalación
tshark --version
aircrack-ng --version
```

### Conocimientos Previos

- Fundamentos de redes (TCP/IP, OSI)
- Conceptos básicos de WiFi (802.11, SSID, BSSID)
- Criptografía básica (hashing, cifrado simétrico)
- Uso de terminal/línea de comandos

---

## Setup del Laboratorio

### Paso 1: Clonar/Descargar el Repositorio

```bash
cd ~/Documents
git clone [REPOSITORY_URL] wifisec
cd wifisec
```

### Paso 2: Ejecutar el Script de Setup

```bash
chmod +x setup_wifi_lab.sh
./setup_wifi_lab.sh
```

Este script:
- Descarga PCAPs de repositorios públicos (Wireshark, Mathy Vanhoef's examples)
- Crea estructura de directorios
- Genera checksums para verificar integridad
- Organiza archivos por tipo de ataque/protocolo

### Paso 3: Verificar Integridad

```bash
cd wifi_lab
sha256sum -c manifest.sha256
```

### Paso 4: Preparar Scripts de Análisis

```bash
cd ../analysis_scripts
chmod +x *.sh
```

---

## Ejercicios

### Ejercicio 1: Análisis de 4-Way Handshake WPA2

**Objetivo**: Comprender el proceso de autenticación WPA2-PSK mediante análisis de handshake.

**Duración**: 45 minutos

#### Teoría Rápida

El 4-way handshake establece claves de sesión entre cliente y AP:
1. **Message 1**: AP → Client (ANonce)
2. **Message 2**: Client → AP (SNonce + MIC)
3. **Message 3**: AP → Client (GTK + MIC)
4. **Message 4**: Client → AP (Acknowledgment)

#### Tareas

```bash
cd analysis_scripts
./01_handshake_analysis.sh
```

**Preguntas de Investigación**:

1. ¿Cuántos frames EAPOL componen el handshake completo?
2. ¿Qué información se intercambia en cada mensaje?
3. ¿Cómo detectarías un ataque KRACK (reutilización de nonces)?
4. ¿Qué herramientas se pueden usar para crackear el handshake capturado?

#### Entregables

- Reporte identificando todos los frames EAPOL
- Lista de SSID, BSSID, y MACs de clientes
- Exportación del handshake en formato hashcat
- Análisis de la fortaleza de la contraseña (si es conocida)

---

### Ejercicio 2: PMKID Attack Analysis

**Objetivo**: Analizar el PMKID attack, una técnica moderna que no requiere capturar clientes.

**Duración**: 40 minutos

#### Teoría Rápida

PMKID = `HMAC-SHA1-128(PMK, "PMK Name" || MAC_AP || MAC_STA)`

**Ventajas**:
- No requiere esperar a cliente conectándose
- No necesita deauth attack
- Menos detectable

**Limitaciones**:
- No todos los APs son vulnerables
- Depende de implementación del vendor

#### Tareas

```bash
./02_pmkid_analysis.sh
```

**Preguntas de Investigación**:

1. ¿Qué información necesitas para crackear un PMKID?
2. ¿Por qué PMKID es menos detectable que capturar handshakes?
3. ¿Qué diferencias hay entre PMK, PMKID y PTK?
4. ¿Cómo mitigarías este ataque en tu red?

#### Entregables

- Extracción de PMKIDs del PCAP
- Comparación con 4-way handshake (ventajas/desventajas)
- Plan de mitigación para red corporativa

---

### Ejercicio 3: Detección de Deauthentication Attacks

**Objetivo**: Identificar y analizar ataques de deautenticación, comunes en pentest WiFi.

**Duración**: 50 minutos

#### Teoría Rápida

**Deauth frames legítimos**:
- Cliente desconectándose
- Timeout de inactividad
- Cambios de configuración

**Deauth maliciosos**:
- Forzar reconexión para capturar handshake
- DoS contra WiFi
- Preparación para Evil Twin

#### Tareas

```bash
./03_deauth_detection.sh
```

**Preguntas de Investigación**:

1. ¿Cómo distingues un deauth legítimo de uno malicioso?
2. ¿Qué es 802.11w y cómo previene estos ataques?
3. ¿Qué reason codes son más sospechosos?
4. ¿Cómo implementarías detección automatizada en un IDS?

#### Entregables

- Análisis de reason codes en el PCAP
- Detección de patrones de ataque (broadcast deauth, flooding)
- Reglas de detección para Suricata/Snort
- Propuesta de mitigación con 802.11w

---

### Ejercicio 4: WPA3 y SAE (Dragonfly)

**Objetivo**: Comprender WPA3 y sus mejoras sobre WPA2, incluyendo vulnerabilidades Dragonblood.

**Duración**: 60 minutos

#### Teoría Rápida

**WPA3 Mejoras**:
- SAE (Simultaneous Authentication of Equals) en lugar de PSK
- Forward secrecy
- Resistente a ataques de diccionario offline
- 802.11w obligatorio

**Vulnerabilidades Conocidas** (Dragonblood):
- Timing attacks (CVE-2019-9494)
- Side-channel attacks
- Downgrade attacks en transition mode

#### Tareas

```bash
./04_wpa3_analysis.sh
```

**Preguntas de Investigación**:

1. ¿Qué problema de WPA2 resuelve SAE?
2. ¿Por qué WPA3 requiere 802.11w obligatoriamente?
3. Explica qué es "forward secrecy"
4. ¿Cuáles son las vulnerabilidades Dragonblood?
5. ¿Cuándo usar WPA3-Transition mode vs WPA3-only?

#### Entregables

- Identificación de frames SAE en PCAP
- Comparación detallada WPA2 vs WPA3
- Plan de migración WPA2 → WPA3 para empresa mediana
- Análisis de riesgos de Dragonblood

---

### Ejercicio 5: Análisis de Tráfico sobre WiFi

**Objetivo**: Analizar tráfico HTTP/DNS sobre WiFi para identificar riesgos de seguridad.

**Duración**: 55 minutos

#### Teoría Rápida

**Riesgos en WiFi Público**:
- HTTP sin cifrar (credenciales en plaintext)
- Man-in-the-Middle (MitM)
- SSL Stripping
- DNS spoofing
- Session hijacking (cookies)

#### Tareas

```bash
./05_traffic_analysis.sh
```

**Preguntas de Investigación**:

1. ¿Qué riesgos tiene usar HTTP en WiFi público?
2. ¿Cómo funciona SSL Stripping?
3. ¿Qué es DNS tunneling?
4. ¿Qué headers HTTP ayudan a prevenir ataques?
5. ¿Cómo detectar MitM en un PCAP?

#### Entregables

- Lista de sitios visitados (HTTP hosts)
- Identificación de datos sensibles (POST data, cookies)
- Detección de indicadores MitM (ARP spoofing, DNS anomalías)
- Reporte de seguridad con recomendaciones

---

## Herramientas

### Análisis de PCAPs

| Herramienta | Descripción | Uso |
|-------------|-------------|-----|
| **Wireshark** | GUI para análisis de paquetes | Inspección visual, filtros avanzados |
| **tshark** | CLI de Wireshark | Scripts automatizados, análisis batch |
| **tcpdump** | Captura y análisis básico | Capturas ligeras, filtros BPF |
| **capinfos** | Información de PCAP | Estadísticas rápidas |

### WiFi Security Tools

| Herramienta | Descripción | Uso Defensivo |
|-------------|-------------|---------------|
| **aircrack-ng** | Suite WiFi security | Validar handshakes, testing |
| **hcxtools** | Conversión de PCAPs | Extraer PMKIDs/hashes |
| **hashcat** | Password recovery | Testing de contraseñas débiles |
| **Kismet** | WIDS | Detección de intrusos |
| **wpa_supplicant** | Cliente WiFi | Testing de configuraciones |

### Comandos Útiles

```bash
# Ver frames EAPOL
tshark -r captura.pcap -Y "eapol"

# Extraer SSIDs
tshark -r captura.pcap -Y "wlan.ssid" -T fields -e wlan.ssid | sort -u

# Detectar deauth
tshark -r captura.pcap -Y "wlan.fc.type_subtype == 0x0c"

# Analizar HTTP requests
tshark -r captura.pcap -Y "http.request" -T fields -e http.host -e http.request.uri

# Exportar objetos HTTP
wireshark captura.pcap # File → Export Objects → HTTP

# Buscar PMKIDs
hcxpcapngtool -o output.txt captura.pcap

# Validar handshake
aircrack-ng captura.pcap
```

---

## Evaluación

### Criterios de Evaluación

1. **Completitud** (30%): Todas las tareas completadas
2. **Precisión Técnica** (30%): Respuestas correctas y detalladas
3. **Análisis Crítico** (20%): Interpretación de resultados
4. **Recomendaciones** (20%): Propuestas de mitigación realistas

### Formato de Entrega

```
nombre_apellido_wifi_lab/
├── reportes/
│   ├── ejercicio1_handshake.pdf
│   ├── ejercicio2_pmkid.pdf
│   ├── ejercicio3_deauth.pdf
│   ├── ejercicio4_wpa3.pdf
│   └── ejercicio5_traffic.pdf
├── capturas_pantalla/
│   └── (screenshots de Wireshark)
└── scripts/
    └── (scripts propios si desarrollaron)
```

---

## Referencias

### Papers y Whitepapers

- **WPA2 Specification**: IEEE 802.11i-2004
- **WPA3 Specification**: Wi-Fi Alliance (2018)
- **KRACK Attack**: Mathy Vanhoef (2017) - https://www.krackattacks.com/
- **Dragonblood**: Vanhoef & Ronen (2019) - https://wpa3.mathyvanhoef.com/
- **PMKID Attack**: Jens Steube (2018) - Hashcat Forum

### Recursos Online

- **Wireshark Documentation**: https://www.wireshark.org/docs/
- **Aircrack-ng Wiki**: https://www.aircrack-ng.org/
- **OWASP WiFi Security**: https://owasp.org/www-community/controls/Wireless_Security
- **NIST Wireless Guidelines**: SP 800-153

### Libros Recomendados

- "Hacking Exposed Wireless" - Johnny Cache & Joshua Wright
- "802.11 Wireless Networks: The Definitive Guide" - Matthew Gast
- "Practical Packet Analysis" - Chris Sanders

### Repositorios de PCAPs

- Wireshark Sample Captures: https://gitlab.com/wireshark/wireshark/-/wikis/SampleCaptures
- Mathy Vanhoef WiFi Examples: https://github.com/vanhoefm/wifi-example-captures
- Malware Traffic Analysis: https://malware-traffic-analysis.net/

---

## Soporte

Para preguntas o problemas:

- **Profesor**: [Nombre del Profesor]
- **Email**: [email@utn.edu.ar]
- **Horario de consulta**: [Horario]
- **Issues**: [GitHub Issues URL]

---

## Licencia y Ética

Este material es proporcionado bajo licencia educativa. Los estudiantes se comprometen a:

✓ Usar el conocimiento solo con fines defensivos y educativos
✓ No realizar ataques reales contra redes sin autorización
✓ Respetar la privacidad y seguridad de otros
✓ Reportar vulnerabilidades de forma responsable

**El uso no autorizado de estas técnicas puede resultar en acciones legales y/o sanciones académicas.**

---

**¡Bienvenidos al laboratorio de Seguridad WiFi!**

*Última actualización: Octubre 2025*
