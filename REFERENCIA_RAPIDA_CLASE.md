# 🔐 WiFi Security Lab - Referencia Rápida para Clase

**Universidad Tecnológica Nacional - Lab Blockchain & Ciberseguridad**

---

## 📋 Instalación Pre-Clase (Alumnos)

```bash
# 1. Clonar
git clone [URL] wifisec && cd wifisec

# 2. Instalar herramientas (automático multi-OS)
bash install_tools.sh

# 3. Descargar PCAPs
bash setup_wifi_lab.sh

# 4. Validar
bash validate_setup.sh
```

**Resultado esperado:** ✅ 6 PCAPs descargados, herramientas instaladas

---

## 🎓 Ejercicios de Clase

### Ejercicio 1: WPA2 4-Way Handshake (30 min)
```bash
bash analysis_scripts/01_handshake_analysis.sh
```
**PCAP:** `wpa_induction.pcap` (175KB)
**Objetivo:** Identificar los 4 frames EAPOL del handshake
**Conceptos:** ANonce, SNonce, PTK, GTK, MIC

### Ejercicio 2: PMKID Attack (20 min)
```bash
bash analysis_scripts/02_pmkid_analysis.sh
```
**Objetivo:** Extraer PMKID sin necesidad de cliente conectado
**Conceptos:** PMKID = HMAC-SHA1-128(PMK, "PMK Name" | MAC_AP | MAC_STA)

### Ejercicio 3: Deauth Detection (20 min)
```bash
bash analysis_scripts/03_deauth_detection.sh
```
**Objetivo:** Detectar ataques de deautenticación
**Conceptos:** Management frames, reason codes, 802.11w

### Ejercicio 4: WPA3/SAE (20 min)
```bash
bash analysis_scripts/04_wpa3_analysis.sh
```
**Objetivo:** Analizar WPA3 y Dragonfly
**Conceptos:** SAE, forward secrecy, Dragonblood

### Ejercicio 5: Traffic Analysis (30 min)
```bash
bash analysis_scripts/05_traffic_analysis.sh
```
**Objetivo:** Análisis de tráfico HTTP/DNS sobre WiFi
**Conceptos:** Captive portals, DNS leaks, MitM

---

## 🔍 Comandos Útiles Durante Clase

### Análisis con tshark (CLI)
```bash
# Ver SSIDs
tshark -r archivo.pcap -Y "wlan.ssid" -T fields -e wlan.ssid | sort -u

# Contar frames EAPOL (handshake)
tshark -r archivo.pcap -Y "eapol" | wc -l

# Ver deauth frames
tshark -r archivo.pcap -Y "wlan.fc.type_subtype == 0x0c"

# HTTP requests
tshark -r archivo.pcap -Y "http.request" -T fields -e http.host -e http.request.uri
```

### Análisis con Wireshark (GUI)
```bash
# Abrir PCAP
wireshark wifi_lab/pcaps/wpa2/wpa_induction.pcap
```

**Filtros útiles:**
- `eapol` - 4-way handshake
- `wlan.fc.type_subtype == 0x0c` - Deauth frames
- `http` - HTTP traffic
- `dns` - DNS queries
- `wlan.ssid == "NetworkName"` - Filtrar por SSID

### Validación con aircrack-ng
```bash
# Verificar handshake válido
aircrack-ng -w wordlist.txt wifi_lab/pcaps/wpa2/wpa_induction.pcap
```

---

## 📁 Estructura de Archivos

```
wifisec/
├── analysis_scripts/          # Scripts de ejercicios (5)
├── wifi_lab/                  # Laboratorio
│   ├── pcaps/                 # 6 PCAPs descargados
│   │   ├── wpa2/             # 2 archivos (handshake ⭐)
│   │   └── misc/             # 4 archivos
│   ├── outputs/               # Resultados de análisis
│   └── reports/               # Reportes generados
└── EJERCICIOS.md              # Guía detallada
```

---

## 🆘 Troubleshooting Rápido

### "tshark: command not found"
```bash
# macOS
brew install wireshark

# Linux
sudo apt install tshark
```

### "Permission denied"
```bash
chmod +x *.sh
chmod +x analysis_scripts/*.sh
```

### Wireshark no captura interfaces
```bash
# Linux
sudo usermod -aG wireshark $USER
# Logout y login
```

### PCAPs no descargados
```bash
# Reintentar
rm -rf wifi_lab
bash setup_wifi_lab.sh
```

---

## 📊 PCAPs Disponibles

| Archivo | Tamaño | Descripción |
|---------|--------|-------------|
| `wpa_induction.pcap` | 175KB | **4-way handshake completo** ⭐ |
| `wpa_eap_tls.pcap` | 32KB | EAP-TLS authentication |
| `cisco_wireless.pcap` | 32KB | Cisco wireless traffic |
| `mobile_network_join.pcap` | 161KB | Mobile device joining |
| `dhcp_traffic.pcap` | 1.4KB | DHCP traffic |
| `radius_auth.pcapng` | 2.9KB | RADIUS auth |

**Total:** 6 archivos, 420KB

---

## ⏱️ Plan de Clase (2 horas)

| Tiempo | Actividad |
|--------|-----------|
| 0:00 - 0:15 | Verificación de instalación (validate_setup.sh) |
| 0:15 - 0:45 | **Ejercicio 1:** WPA2 4-way handshake |
| 0:45 - 1:05 | **Ejercicio 2:** PMKID attack |
| 1:05 - 1:25 | **Ejercicio 3:** Deauth detection |
| 1:25 - 1:45 | **Ejercicio 5:** Traffic analysis |
| 1:45 - 2:00 | Discusión y preguntas |

---

## 🔑 Conceptos Clave

### WPA2-PSK (Pre-Shared Key)
- **PMK** = PBKDF2(passphrase, SSID, 4096 iterations)
- **PTK** = PRF(PMK, ANonce, SNonce, AP_MAC, STA_MAC)
- **GTK** = Group Temporal Key (para multicast/broadcast)

### 4-Way Handshake
1. **Message 1/4:** AP → STA (ANonce)
2. **Message 2/4:** STA → AP (SNonce, MIC)
3. **Message 3/4:** AP → STA (GTK, MIC)
4. **Message 4/4:** STA → AP (Confirmación, MIC)

### PMKID Attack
- **Ventaja:** No necesita clientes conectados
- **Extracción:** Desde Robust Security Network IE (RSNE)
- **Formato:** `hcxpcapngtool -o hash.22000 capture.pcap`

---

## 📚 Documentación Completa

- **README.md** - Overview del proyecto
- **TUTORIAL_PASO_A_PASO.md** - Tutorial detallado con verificaciones
- **GUIA_INSTALACION.md** - Instalación por OS
- **EJERCICIOS.md** - Guía de ejercicios para estudiantes
- **INSTRUCTOR_GUIDE.md** - Guía del profesor con soluciones
- **CHEATSHEET.md** - Referencia de comandos

---

## ⚠️ Consideraciones Éticas

**PERMITIDO:**
✓ Analizar PCAPs proporcionados
✓ Practicar detección de ataques
✓ Desarrollar reglas de IDS/IPS
✓ Testear en laboratorios controlados

**PROHIBIDO:**
✗ Atacar redes WiFi sin autorización
✗ Capturar tráfico de redes ajenas
✗ Uso malicioso de técnicas aprendidas

---

## 📞 Soporte Durante Clase

1. **validate_setup.sh** - Diagnóstico automático
2. **GUIA_INSTALACION.md** - Troubleshooting detallado
3. **INSTRUCTOR_GUIDE.md** - Soluciones de ejercicios

---

**¡Éxito con la clase!** 🎓🔐

*Universidad Tecnológica Nacional - Octubre 2025*
