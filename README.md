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
git clone https://github.com/WIFI-SEC/lab01.git
cd lab01

# 2. Instalar herramientas automáticamente
bash scripts/setup/install_tools.sh

# 3. Setup del laboratorio (descarga PCAPs principales)
bash scripts/setup/setup_wifi_lab.sh

# 4. Descargar PCAPs adicionales (opcional pero recomendado)
bash scripts/setup/download_additional_pcaps.sh

# 5. Validar instalación
bash scripts/setup/validate_setup.sh

# 6. Ver demo del laboratorio (recomendado para primera vez)
bash scripts/demo/demo_rapida.sh          # 5 minutos
bash scripts/demo/demo_laboratorio.sh     # 15-20 minutos completo

# 7. Comenzar con ejercicios progresivos
# Ver docs/exercises/EJERCICIOS_PROGRESIVOS.md - Empezar por Ejercicio 1
```

### Opción 2: Instalación Manual

```bash
# macOS
brew install wireshark aircrack-ng

# Linux (Ubuntu/Debian)
sudo apt install wireshark tshark aircrack-ng

# Luego ejecutar setup
bash scripts/setup/setup_wifi_lab.sh
```

**Ver guía completa**: [docs/guides/GUIA_INSTALACION.md](docs/guides/GUIA_INSTALACION.md)

## 📁 Estructura del Proyecto

```
lab01/
├── README.md                           # Este archivo
├── LICENSE                             # Licencia MIT
│
├── docs/                               # 📚 Documentación
│   ├── exercises/                      # Ejercicios y referencias
│   │   ├── EJERCICIOS_PROGRESIVOS.md  # 10 ejercicios estructurados ⭐
│   │   ├── EJERCICIOS.md              # Ejercicios originales
│   │   └── CHEATSHEET.md              # Referencia rápida de comandos
│   │
│   └── guides/                         # Guías para profesores y alumnos
│       ├── GUIA_DEMO.md               # Cómo presentar el laboratorio
│       ├── GUIA_INSTALACION.md        # Instalación detallada
│       ├── INICIO_RAPIDO.md           # Quick start extendido
│       ├── INSTRUCTOR_GUIDE.md        # Soluciones (solo profesores)
│       ├── TUTORIAL_PASO_A_PASO.md    # Tutorial completo
│       └── REFERENCIA_RAPIDA_CLASE.md # Referencia de 1 página
│
├── scripts/                            # 🔧 Scripts del laboratorio
│   ├── setup/                          # Scripts de instalación
│   │   ├── install_tools.sh           # Instalar herramientas
│   │   ├── setup_wifi_lab.sh          # Setup inicial del lab
│   │   ├── download_additional_pcaps.sh # Descargar más PCAPs
│   │   ├── validate_setup.sh          # Validar instalación
│   │   └── create_test_wordlist.sh    # Crear wordlist de prueba
│   │
│   ├── demo/                           # Scripts de demostración
│   │   ├── README.md                  # Guía de demos
│   │   ├── demo_rapida.sh             # Demo 5 min ⚡
│   │   ├── demo_laboratorio.sh        # Demo completa 15-20 min 🎯
│   │   └── demo_simple.sh             # Demo simplificada
│   │
│   └── analysis/                       # Scripts de análisis por tema
│       ├── 01_handshake_analysis.sh   # WPA2 4-way handshake
│       ├── 02_pmkid_analysis.sh       # PMKID attack
│       ├── 03_deauth_detection.sh     # Deauth attacks
│       ├── 04_wpa3_analysis.sh        # WPA3 SAE
│       └── 05_traffic_analysis.sh     # HTTP/DNS traffic
│
└── wifi_lab/                           # 🗂️ Creado por setup
    ├── pcaps/                          # PCAPs descargados (9 archivos)
    │   ├── wpa2/                       # WPA2 handshakes
    │   ├── wpa3/                       # WPA3 SAE
    │   ├── wep/                        # WEP (legacy)
    │   ├── attacks/                    # Ataques (deauth, arp spoofing)
    │   └── misc/                       # HTTP, DNS, DHCP
    ├── outputs/                        # Resultados de análisis
    ├── reports/                        # Reportes generados
    └── manifest.sha256                 # Checksums de integridad
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
```

## 📚 Ejercicios

### 🆕 Ejercicios Progresivos (Recomendado)

Ver **[docs/exercises/EJERCICIOS_PROGRESIVOS.md](docs/exercises/EJERCICIOS_PROGRESIVOS.md)** - 10 ejercicios estructurados:

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

## 🎬 Demos del Laboratorio

Para presentar el laboratorio en clase o ver una demostración completa:

### Demo Rápida (5 minutos)
```bash
bash scripts/demo/demo_rapida.sh
```
Muestra highlights: PCAPs disponibles, WPA2 handshake, detección de ataques.

### Demo Completa (15-20 minutos)
```bash
bash scripts/demo/demo_laboratorio.sh
```
Demo interactiva con 7 secciones detalladas y generación de reporte.

**Ver guía completa**: [scripts/demo/README.md](scripts/demo/README.md)

## 🔧 Uso

### Ejecución de Scripts de Análisis

```bash
# Ejecutar análisis específico
bash scripts/analysis/01_handshake_analysis.sh

# Ver resultados
ls -l wifi_lab/outputs/
cat wifi_lab/reports/latest_report.txt
```

### Análisis Manual con Wireshark

```bash
# Abrir PCAP en Wireshark
wireshark wifi_lab/pcaps/wpa2/wpa_induction.pcap

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
tshark -r wifi_lab/pcaps/misc/http_captive_portal.cap -Y "http.request" -T fields -e http.host -e http.request.uri
```

**Ver más comandos**: [docs/exercises/CHEATSHEET.md](docs/exercises/CHEATSHEET.md)

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

**Total**: 9 PCAPs (840KB) con escenarios realistas de análisis.

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
chmod +x scripts/setup/*.sh
chmod +x scripts/demo/*.sh
chmod +x scripts/analysis/*.sh
```

### PCAPs no se descargan

```bash
# Verificar conectividad
ping gitlab.com
ping raw.githubusercontent.com

# Ejecutar setup nuevamente
bash scripts/setup/setup_wifi_lab.sh
```

**Ver más**: [docs/guides/GUIA_INSTALACION.md](docs/guides/GUIA_INSTALACION.md#troubleshooting)

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

Ver [LICENSE](LICENSE) para más detalles.

## 📧 Contacto

**Autor**: fboiero
**Email**: fboiero@frvm.utn.edu.ar
**Institución**: Universidad Tecnológica Nacional
**Laboratorio**: Blockchain & Ciberseguridad

---

## 🌟 Agradecimientos

- **Mathy Vanhoef** - Por su investigación en seguridad WiFi y PCAPs de ejemplo
- **Wireshark Project** - Por mantener sample captures públicas
- **Jens Steube (Hashcat)** - Por descubrir PMKID attack
- **Comunidad de seguridad WiFi** - Por compartir conocimiento

---

## 📄 Documentación Adicional

- **[INICIO_RAPIDO.md](docs/guides/INICIO_RAPIDO.md)** - Guía de inicio extendida
- **[TUTORIAL_PASO_A_PASO.md](docs/guides/TUTORIAL_PASO_A_PASO.md)** - Tutorial completo
- **[GUIA_DEMO.md](docs/guides/GUIA_DEMO.md)** - Cómo presentar en clase
- **[INSTRUCTOR_GUIDE.md](docs/guides/INSTRUCTOR_GUIDE.md)** - Guía del instructor

---

**¡Happy Hacking (Ethical)!** 🔐

*Última actualización: Octubre 2025*
