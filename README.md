# 🔒 Laboratorio de Seguridad WiFi

**Universidad Tecnológica Nacional - Laboratorio Blockchain & Ciberseguridad**

Laboratorio práctico de seguridad WiFi para análisis defensivo utilizando PCAPs de repositorios públicos.

---

## 📋 Descripción

Este repositorio contiene material educativo para la clase práctica de **Seguridad WiFi**, diseñado para complementar la teoría con análisis real de tráfico WiFi. Utilizamos capturas de paquetes (PCAPs) de repositorios públicos para que los estudiantes puedan practicar análisis forense y detección de ataques sin necesidad de realizar capturas en vivo.

## 🎯 Objetivos

- Comprender protocolos de autenticación WiFi (WPA2, WPA3)
- Analizar ataques comunes (deauth, PMKID, handshake capture)
- Desarrollar habilidades de análisis forense de tráfico
- Implementar técnicas de detección y mitigación
- Practicar con herramientas de seguridad WiFi (Wireshark, tshark, aircrack-ng)

## 🚀 Quick Start

### Opción 1: Instalación Automática (Recomendado)

```bash
# 1. Clonar el repositorio
git clone https://github.com/[tu-usuario]/wifisec
cd wifisec

# 2. Instalar herramientas automáticamente
bash install_tools.sh

# 3. Setup del laboratorio (descarga PCAPs principales)
bash setup_wifi_lab.sh

# 4. Descargar PCAPs adicionales (opcional pero recomendado)
bash download_additional_pcaps.sh

# 5. Validar instalación
bash validate_setup.sh

# 6. Comenzar con ejercicios progresivos
# Ver EJERCICIOS_PROGRESIVOS.md - Empezar por Ejercicio 1
```

### Opción 2: Instalación Manual

```bash
# macOS
brew install wireshark aircrack-ng

# Linux (Ubuntu/Debian)
sudo apt install wireshark tshark aircrack-ng

# Luego ejecutar setup
bash setup_wifi_lab.sh
```

**Ver guía completa**: [GUIA_INSTALACION.md](GUIA_INSTALACION.md)

## 📁 Estructura del Proyecto

```
wifisec/
├── README.md                    # Este archivo
├── EJERCICIOS.md               # Guía detallada de ejercicios
├── setup_wifi_lab.sh           # Script principal de setup
├── analysis_scripts/           # Scripts de análisis por ejercicio
│   ├── 01_handshake_analysis.sh
│   ├── 02_pmkid_analysis.sh
│   ├── 03_deauth_detection.sh
│   ├── 04_wpa3_analysis.sh
│   └── 05_traffic_analysis.sh
└── wifi_lab/                   # Creado por setup_wifi_lab.sh
    ├── pcaps/                  # PCAPs descargados
    │   ├── wpa2/
    │   ├── wpa3/
    │   ├── wep/
    │   ├── attacks/
    │   └── misc/
    ├── outputs/                # Resultados de análisis
    ├── reports/                # Reportes generados
    └── manifest.sha256         # Checksums de integridad
```

## 🛠️ Requisitos

### Software

| Herramienta | Instalación (macOS) | Instalación (Linux) |
|-------------|---------------------|---------------------|
| Wireshark/tshark | `brew install wireshark` | `apt install wireshark tshark` |
| aircrack-ng | `brew install aircrack-ng` | `apt install aircrack-ng` |
| hcxtools | `brew install hcxtools` | `apt install hcxtools` |
| wget/curl | (incluido) | (incluido) |

### Verificación

```bash
tshark --version
aircrack-ng --version
hcxpcapngtool --version
```

## 📚 Ejercicios

### 🆕 Ejercicios Progresivos (Recomendado para Principiantes)

Ver **[EJERCICIOS_PROGRESIVOS.md](EJERCICIOS_PROGRESIVOS.md)** - 10 ejercicios estructurados:

**Nivel Básico** (30 min c/u):
1. Explorando PCAPs con tshark
2. Frames WiFi Básicos (Beacon, Probe, Association)
3. DHCP y Conexión a Red

**Nivel Intermedio** (45 min c/u):
4. WPA2 4-Way Handshake Profundo
5. Extracción de Nonces y MIC
6. DNS Analysis y Detección de Anomalías

**Nivel Avanzado** (60 min c/u):
7. ARP Spoofing Detection
8. HTTP Traffic Analysis y Captive Portals
9. PMKID Attack Simulation

**Escenario Integrador** (90-120 min):
10. Auditoría Completa de Red WiFi

### Ejercicios con Scripts Automatizados

### [Ejercicio: WPA2 4-Way Handshake](analysis_scripts/01_handshake_analysis.sh)
Análisis del proceso de autenticación WPA2-PSK mediante frames EAPOL.

**Temas**: EAPOL, PTK, PMK, nonces, MIC

### [Ejercicio: PMKID Attack](analysis_scripts/02_pmkid_analysis.sh)
Estudio del PMKID attack, técnica que no requiere capturar clientes activos.

**Temas**: PMKID, RSN IE, Hashcat mode 16800

### [Ejercicio: Deauthentication Detection](analysis_scripts/03_deauth_detection.sh)
Detección y análisis de ataques de deautenticación.

**Temas**: Management frames, reason codes, 802.11w, IDS rules

### [Ejercicio: WPA3 y SAE](analysis_scripts/04_wpa3_analysis.sh)
Análisis de WPA3 y el protocolo SAE (Dragonfly), incluyendo vulnerabilidades Dragonblood.

**Temas**: SAE, forward secrecy, Dragonblood CVEs, transition mode

### [Ejercicio: Traffic Analysis](analysis_scripts/05_traffic_analysis.sh)
Análisis de tráfico HTTP/DNS sobre WiFi, detección de MitM.

**Temas**: Captive portals, SSL stripping, DNS tunneling, session hijacking

## 🔧 Uso

### Ejecución Individual

```bash
cd analysis_scripts

# Ejecutar ejercicio específico
./01_handshake_analysis.sh

# Ver resultados
ls -l ../wifi_lab/outputs/
```

### Análisis Manual con Wireshark

```bash
# Abrir PCAP en Wireshark
wireshark wifi_lab/pcaps/wpa2/wpa2_handshake_example.pcapng

# Aplicar filtros útiles:
# - eapol                          (4-way handshake)
# - wlan.fc.type_subtype == 0x0c   (deauth frames)
# - http                           (HTTP traffic)
# - dns                            (DNS queries)
```

### Análisis con tshark (CLI)

```bash
# Listar SSIDs
tshark -r wifi_lab/pcaps/wpa2/*.pcap -Y "wlan.ssid" -T fields -e wlan.ssid | sort -u

# Contar frames EAPOL
tshark -r wifi_lab/pcaps/wpa2/*.pcap -Y "eapol" | wc -l

# Exportar HTTP requests
tshark -r wifi_lab/pcaps/misc/http_traffic.cap -Y "http.request" -T fields -e http.host -e http.request.uri
```

## 📊 Fuentes de PCAPs

Los PCAPs se descargan automáticamente de:

- **Mathy Vanhoef's WiFi Examples**: Investigador de KRACK y Dragonblood
  - WPA2 handshakes
  - PMKID attacks
  - WPA3 SAE examples

- **Wireshark Sample Captures**: Proyecto oficial Wireshark
  - WEP traffic
  - Deauth attacks
  - HTTP/DNS traffic
  - EAPOL exchanges

Todos los PCAPs son de dominio público y están disponibles para uso educativo.

## 🛡️ Consideraciones Éticas

**⚠️ IMPORTANTE**: Este material es exclusivamente para **análisis defensivo** y educación.

### Está PERMITIDO:
✓ Analizar PCAPs proporcionados
✓ Practicar detección de ataques
✓ Desarrollar reglas de IDS/IPS
✓ Testear en laboratorios controlados con autorización

### Está PROHIBIDO:
✗ Atacar redes WiFi sin autorización
✗ Capturar tráfico de redes ajenas
✗ Usar técnicas aprendidas de forma maliciosa
✗ Distribuir herramientas sin contexto educativo

**El uso no autorizado puede resultar en consecuencias legales.**

## 🔍 Troubleshooting

### Error: "tshark: command not found"

```bash
# macOS
brew install wireshark

# Linux
sudo apt update && sudo apt install tshark
```

### Error: "Permission denied" en scripts

```bash
chmod +x setup_wifi_lab.sh
chmod +x analysis_scripts/*.sh
```

### PCAPs no se descargan

```bash
# Verificar conectividad
ping gitlab.com
ping raw.githubusercontent.com

# Descargar manualmente
wget https://gitlab.com/wireshark/wireshark/-/raw/master/test/captures/wpa-Induction.pcap
```

### Wireshark no captura interfaces

```bash
# macOS: Instalar ChmodBPF
brew install --cask wireshark

# Linux: Agregar usuario al grupo
sudo usermod -aG wireshark $USER
# Logout y login nuevamente
```

## 📖 Referencias

### Papers y Estándares
- IEEE 802.11i-2004 (WPA2)
- Wi-Fi Alliance WPA3 Specification (2018)
- [KRACK Attack](https://www.krackattacks.com/) - Mathy Vanhoef (2017)
- [Dragonblood](https://wpa3.mathyvanhoef.com/) - Vanhoef & Ronen (2019)

### Herramientas
- [Wireshark](https://www.wireshark.org/) - Network protocol analyzer
- [Aircrack-ng](https://www.aircrack-ng.org/) - WiFi security suite
- [Hashcat](https://hashcat.net/hashcat/) - Password recovery tool
- [hcxtools](https://github.com/ZerBea/hcxtools) - PCAP conversion tools

### Recursos Educativos
- [OWASP Wireless Security](https://owasp.org/www-community/controls/Wireless_Security)
- [NIST SP 800-153](https://csrc.nist.gov/publications/detail/sp/800-153/final) - WiFi Security Guidelines
- [Wireshark Sample Captures](https://gitlab.com/wireshark/wireshark/-/wikis/SampleCaptures)

## 👥 Contribuciones

Este es un proyecto educativo. Si encuentras errores o tienes sugerencias:

1. Fork el repositorio
2. Crea una branch (`git checkout -b feature/mejora`)
3. Commit tus cambios (`git commit -am 'Agrega nueva funcionalidad'`)
4. Push a la branch (`git push origin feature/mejora`)
5. Abre un Pull Request

## 📝 Licencia

Este material educativo está disponible bajo **licencia MIT** para uso académico.

Los PCAPs descargados provienen de repositorios públicos y mantienen sus licencias originales.

## 📧 Contacto

**Profesor**: [Nombre del Profesor]
**Email**: [email@utn.edu.ar]
**Institución**: Universidad Tecnológica Nacional
**Laboratorio**: Blockchain & Ciberseguridad

---

## 🌟 Agradecimientos

- **Mathy Vanhoef** - Por su investigación en seguridad WiFi y PCAPs de ejemplo
- **Wireshark Project** - Por mantener sample captures públicas
- **Jens Steube (Hashcat)** - Por descubrir PMKID attack
- **Comunidad de seguridad WiFi** - Por compartir conocimiento

---

**¡Happy Hacking (Ethical)!** 🔐

*Última actualización: Octubre 2025*
