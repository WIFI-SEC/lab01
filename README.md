# 🔒 Laboratorio de Seguridad WiFi

**Universidad Tecnológica Nacional - Laboratorio Blockchain & Ciberseguridad**

Laboratorio práctico de seguridad WiFi para análisis defensivo utilizando PCAPs de repositorios públicos.

**Compatible con**: Windows 10/11, macOS, Linux

---

## 📋 Descripción

Este repositorio contiene material educativo para la clase práctica de **Seguridad WiFi**, diseñado para complementar la teoría con análisis real de tráfico WiFi. Utilizamos capturas de paquetes (PCAPs) de repositorios públicos para que los estudiantes puedan practicar análisis forense y detección de ataques sin necesidad de realizar capturas en vivo.

**Características:**
- ✅ 9 PCAPs reales de escenarios WiFi
- ✅ 10 ejercicios progresivos con teoría detallada
- ✅ Scripts automatizados para análisis
- ✅ Compatible con Windows, macOS y Linux
- ✅ Documentación completa paso a paso

## 🎯 Objetivos

- Comprender protocolos de autenticación WiFi (WPA2, WPA3)
- Analizar ataques comunes (deauth, PMKID, handshake capture)
- Desarrollar habilidades de análisis forense de tráfico
- Implementar técnicas de detección y mitigación
- Practicar con herramientas de seguridad WiFi (Wireshark, tshark, aircrack-ng)

---

## 🚀 Quick Start

### 🪟 Para Usuarios de Windows

**¿Por qué necesito instalar algo adicional en Windows?**

Este laboratorio utiliza herramientas de seguridad WiFi (tshark, aircrack-ng) que fueron desarrolladas originalmente para Linux/Unix. En Windows, tienes dos opciones:

1. **WSL2 (Recomendado)**: Instalar un entorno Linux completo dentro de Windows
2. **Git Bash**: Usar versiones Windows nativas de las herramientas (menos compatible)

**Te recomendamos la Opción 1 (WSL2)** porque:
- ✅ Todos los scripts funcionan sin problemas
- ✅ Instalación automática de herramientas
- ✅ Misma experiencia que Linux/macOS
- ✅ Mejor compatibilidad con comandos bash

---

#### Opción 1: WSL2 (Windows Subsystem for Linux) - RECOMENDADO

**¿Qué es WSL2?**

WSL2 (Windows Subsystem for Linux 2) es una característica de Windows 10/11 que te permite ejecutar un entorno Linux real dentro de Windows, sin necesidad de máquina virtual ni dual boot. Es como tener Linux y Windows al mismo tiempo.

**Paso 1: Instalar WSL2**

1. Abrir **PowerShell como Administrador** (clic derecho → "Ejecutar como administrador")

2. Ejecutar:
   ```powershell
   wsl --install -d Ubuntu
   ```

3. Reiniciar el computador cuando se solicite

4. Después del reinicio, se abrirá Ubuntu automáticamente
   - Crear usuario y contraseña cuando se solicite
   - Ejemplo: usuario `estudiante`, contraseña que recuerdes

**Paso 2: Actualizar Ubuntu en WSL2**

```bash
# Actualizar lista de paquetes
sudo apt update

# Actualizar paquetes instalados
sudo apt upgrade -y
```

**Paso 3: Instalar Git**

```bash
sudo apt install git -y
```

**Paso 4: Clonar el Repositorio**

```bash
# Ir al directorio home
cd ~

# Clonar el repositorio
git clone https://github.com/WIFI-SEC/lab01.git

# Entrar al directorio
cd lab01
```

**Paso 5: Instalar Herramientas**

```bash
# Dar permisos de ejecución a los scripts
chmod +x scripts/setup/*.sh

# Ejecutar script de instalación automática
bash scripts/setup/install_tools.sh
```

**Paso 6: Descargar PCAPs**

```bash
# Descargar PCAPs principales
bash scripts/setup/setup_wifi_lab.sh

# Descargar PCAPs adicionales (opcional pero recomendado)
bash scripts/setup/download_additional_pcaps.sh
```

**Paso 7: Validar Instalación**

```bash
# Verificar que todo esté instalado correctamente
bash scripts/setup/validate_setup.sh
```

✅ **Si ves todos los checks en verde, estás listo para empezar!**

**Paso 8: Ver Demo (Opcional)**

```bash
# Demo rápida (5 minutos)
bash scripts/demo/demo_rapida.sh
```

**Paso 9: Comenzar con los Ejercicios**

```bash
# Abrir la guía de ejercicios
cat docs/exercises/EJERCICIOS_PROGRESIVOS.md | less
# (Presiona 'q' para salir)

# O ver en un editor de texto
nano docs/exercises/EJERCICIOS_PROGRESIVOS.md
```

---

#### Opción 2: Wireshark Nativo en Windows + Git Bash

**Paso 1: Instalar Git for Windows**

1. Descargar desde: https://git-scm.com/download/win
2. Ejecutar el instalador
3. Durante la instalación:
   - Seleccionar "Use Git from Git Bash only"
   - Seleccionar "Checkout Windows-style, commit Unix-style line endings"
   - Dejar las demás opciones por defecto

**Paso 2: Instalar Wireshark**

1. Descargar desde: https://www.wireshark.org/download.html
2. Ejecutar el instalador
3. **IMPORTANTE**: Durante la instalación, marcar:
   - ☑️ Wireshark
   - ☑️ TShark (Command Line)
   - ☑️ Plugins / Extensions
4. Agregar al PATH:
   - Abrir **Panel de Control** → **Sistema** → **Configuración avanzada del sistema**
   - Click en **Variables de entorno**
   - En "Variables del sistema", buscar `Path` → Click en **Editar**
   - Click en **Nuevo** → Agregar: `C:\Program Files\Wireshark`
   - Click en **Aceptar** en todas las ventanas

**Paso 3: Instalar Aircrack-ng**

1. Descargar desde: https://www.aircrack-ng.org/downloads.html
2. Descargar la versión para Windows (archivo .zip)
3. Extraer en: `C:\Program Files\Aircrack-ng`
4. Agregar al PATH:
   - Igual que en el Paso 2, agregar: `C:\Program Files\Aircrack-ng\bin`

**Paso 4: Verificar Instalación**

Abrir **Git Bash** (buscar en el menú inicio):

```bash
# Verificar Git
git --version

# Verificar TShark
tshark --version

# Verificar Aircrack-ng
aircrack-ng --version
```

**Paso 5: Clonar Repositorio**

En Git Bash:

```bash
# Ir a tu carpeta de documentos
cd ~/Documents

# Clonar el repositorio
git clone https://github.com/WIFI-SEC/lab01.git

# Entrar al directorio
cd lab01
```

**Paso 6: Ejecutar Setup Manual**

En Git Bash:

```bash
# Crear estructura de directorios
mkdir -p wifi_lab/{pcaps/{wpa2,wpa3,wep,attacks,misc},outputs,reports}

# Descargar PCAPs manualmente
# Nota: Los scripts de bash pueden tener problemas en Git Bash
# Recomendamos usar WSL2 (Opción 1) para mejor compatibilidad
```

**Paso 7: Usar Wireshark GUI**

1. Abrir **Wireshark** desde el menú inicio
2. Ir a **File** → **Open**
3. Navegar a: `C:\Users\[TuUsuario]\Documents\lab01\wifi_lab\pcaps\wpa2\`
4. Abrir: `wpa_induction.pcap`

**Nota para Windows:** Para mejor experiencia y compatibilidad con los scripts, **recomendamos usar WSL2 (Opción 1)**.

---

### 🍎 Para Usuarios de macOS

**Paso 1: Instalar Homebrew (si no lo tienes)**

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**Paso 2: Clonar el Repositorio**

```bash
cd ~/Documents
git clone https://github.com/WIFI-SEC/lab01.git
cd lab01
```

**Paso 3: Instalación Automática**

```bash
# Dar permisos
chmod +x scripts/setup/*.sh

# Instalar herramientas
bash scripts/setup/install_tools.sh

# Descargar PCAPs
bash scripts/setup/setup_wifi_lab.sh
bash scripts/setup/download_additional_pcaps.sh

# Validar
bash scripts/setup/validate_setup.sh
```

**Paso 4: Comenzar**

```bash
# Ver demo
bash scripts/demo/demo_rapida.sh

# Leer ejercicios
open docs/exercises/EJERCICIOS_PROGRESIVOS.md
```

---

### 🐧 Para Usuarios de Linux

**Paso 1: Clonar el Repositorio**

```bash
cd ~/Documents
git clone https://github.com/WIFI-SEC/lab01.git
cd lab01
```

**Paso 2: Instalación Automática**

```bash
# Dar permisos
chmod +x scripts/setup/*.sh

# Instalar herramientas
bash scripts/setup/install_tools.sh

# Descargar PCAPs
bash scripts/setup/setup_wifi_lab.sh
bash scripts/setup/download_additional_pcaps.sh

# Validar
bash scripts/setup/validate_setup.sh
```

**Paso 3: Comenzar**

```bash
# Ver demo
bash scripts/demo/demo_rapida.sh

# Leer ejercicios
xdg-open docs/exercises/EJERCICIOS_PROGRESIVOS.md
```

---

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
│   │   ├── demo_laboratorio.sh        # Demo completa 🎯
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

---

## 🛠️ Requisitos del Sistema

### Hardware Mínimo
- **CPU**: Dual-core 2.0 GHz o superior
- **RAM**: 4 GB (8 GB recomendado)
- **Disco**: 2 GB de espacio libre
- **Red**: Conexión a Internet para descargar PCAPs

### Software

| Herramienta | Windows | macOS | Linux |
|-------------|---------|-------|-------|
| **Git** | [Git for Windows](https://git-scm.com/download/win) | Incluido en Xcode tools | `apt install git` |
| **Wireshark/tshark** | [Wireshark.org](https://www.wireshark.org/download.html) | `brew install wireshark` | `apt install wireshark tshark` |
| **Aircrack-ng** | [Aircrack-ng.org](https://www.aircrack-ng.org/downloads.html) | `brew install aircrack-ng` | `apt install aircrack-ng` |
| **WSL2** (Windows) | `wsl --install` en PowerShell | N/A | N/A |

### Verificación de Instalación

**Windows (Git Bash o WSL2):**
```bash
git --version
tshark --version
aircrack-ng --version
```

**macOS / Linux:**
```bash
git --version
tshark --version
aircrack-ng --version
```

✅ Si todos muestran su versión, estás listo.

---

## 📚 Ejercicios Progresivos

Ver **[docs/exercises/EJERCICIOS_PROGRESIVOS.md](docs/exercises/EJERCICIOS_PROGRESIVOS.md)** - 10 ejercicios estructurados con teoría detallada:

### Nivel Básico
1. **Explorando PCAPs con tshark**
   - Comandos básicos de tshark
   - Filtros de Wireshark
   - Estructura de frames 802.11

2. **Frames WiFi Básicos**
   - Beacon, Probe Request/Response
   - Authentication y Association
   - Proceso completo de conexión

3. **DHCP y Conexión a Red**
   - Proceso DORA (Discover, Offer, Request, Ack)
   - Lease time y renovación
   - Vulnerabilidades DHCP

### Nivel Intermedio
4. **WPA2 4-Way Handshake Profundo**
   - Análisis de 4 frames EAPOL
   - ANonce y SNonce
   - Verificación con aircrack-ng

5. **Extracción de Nonces y MIC**
   - Componentes criptográficos
   - PTK/PMK derivation
   - Formato para hashcat

6. **DNS Analysis**
   - Queries y responses
   - Detección de DNS tunneling
   - Anomalías de DNS

### Nivel Avanzado
7. **ARP Spoofing Detection**
   - Detección de Man-in-the-Middle
   - ARP storm analysis
   - Múltiples MACs por IP

8. **HTTP Traffic Analysis**
   - Tráfico sin cifrar
   - Captive portals
   - Session hijacking

9. **PMKID Attack Simulation**
   - Extracción de PMKID
   - Cracking offline
   - Mitigaciones

### Escenario Integrador
10. **Auditoría Completa de Red WiFi**
    - Aplicación de todos los conocimientos
    - Generación de reporte profesional
    - Recomendaciones de seguridad

---

## 🎬 Demos del Laboratorio

### Demo Rápida

**Windows (WSL2 o Git Bash):**
```bash
bash scripts/demo/demo_rapida.sh
```

**macOS / Linux:**
```bash
bash scripts/demo/demo_rapida.sh
```

Muestra en 5 minutos:
- ✅ 9 PCAPs disponibles
- ✅ WPA2 Handshake completo (SSID: "Coherer", 4 EAPOL frames)
- ✅ Detección de ARP Spoofing (622 paquetes)
- ✅ HTTP Traffic inseguro (19 requests)
- ✅ 10 ejercicios disponibles

### Demo Completa

```bash
bash scripts/demo/demo_laboratorio.sh
```

Demo interactiva con:
- 7 secciones detalladas
- Análisis paso a paso
- Generación de reporte automático en `wifi_lab/reports/`

**Ver guía completa**: [scripts/demo/README.md](scripts/demo/README.md)

---

## 🔧 Uso del Laboratorio

### Análisis con Wireshark GUI

**Windows:**
1. Abrir Wireshark desde el menú inicio
2. File → Open
3. Navegar a: `C:\Users\[Usuario]\Documents\lab01\wifi_lab\pcaps\wpa2\wpa_induction.pcap`

**macOS:**
```bash
wireshark wifi_lab/pcaps/wpa2/wpa_induction.pcap &
```

**Linux:**
```bash
wireshark wifi_lab/pcaps/wpa2/wpa_induction.pcap &
```

**Filtros útiles en Wireshark:**
- `eapol` → 4-way handshake WPA2
- `wlan.fc.type_subtype == 0x08` → Beacon frames
- `wlan.fc.type_subtype == 0x0c` → Deauth frames
- `http` → HTTP traffic
- `dns` → DNS queries
- `arp` → ARP packets

### Análisis con tshark (CLI)

```bash
# Listar SSIDs de todas las redes
tshark -r wifi_lab/pcaps/wpa2/wpa_induction.pcap -Y "wlan.ssid" -T fields -e wlan.ssid | sort -u | xxd -r -p

# Contar frames EAPOL (handshake)
tshark -r wifi_lab/pcaps/wpa2/wpa_induction.pcap -Y "eapol" | wc -l

# Ver detalles de beacons
tshark -r wifi_lab/pcaps/wpa2/wpa_induction.pcap -Y "wlan.fc.type_subtype == 0x08" -c 5

# Exportar HTTP requests
tshark -r wifi_lab/pcaps/misc/http_captive_portal.cap -Y "http.request" -T fields -e http.host -e http.request.uri
```

**Ver más comandos**: [docs/exercises/CHEATSHEET.md](docs/exercises/CHEATSHEET.md)

### Ejecución de Scripts de Análisis

```bash
# Dar permisos (solo la primera vez)
chmod +x scripts/analysis/*.sh

# Ejecutar análisis de WPA2 handshake
bash scripts/analysis/01_handshake_analysis.sh

# Ver resultados
ls -lh wifi_lab/outputs/
cat wifi_lab/reports/*.txt
```

---

## 🔍 Troubleshooting

### Windows - WSL2

**Problema: "wsl: command not found" en PowerShell**

**Solución:**
- Asegúrate de usar Windows 10 versión 2004+ o Windows 11
- Ejecuta PowerShell **como Administrador**
- Habilita WSL: `dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart`
- Habilita Virtual Machine: `dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart`
- Reinicia el computador
- Ejecuta: `wsl --install -d Ubuntu`

**Problema: "tshark: command not found" en WSL2**

**Solución:**
```bash
sudo apt update
sudo apt install tshark -y
```

**Problema: Permisos al ejecutar tshark en WSL2**

**Solución:**
```bash
# Agregar tu usuario al grupo wireshark
sudo usermod -a -G wireshark $USER

# Recargar grupos (o logout/login)
newgrp wireshark
```

### Windows - Git Bash

**Problema: "tshark: command not found" en Git Bash**

**Solución:**
1. Verificar que Wireshark esté instalado en: `C:\Program Files\Wireshark`
2. Agregar al PATH del sistema (ver instrucciones de instalación arriba)
3. **Reiniciar Git Bash** después de modificar el PATH
4. Verificar: `tshark --version`

**Problema: Scripts no funcionan en Git Bash**

**Solución:**
Los scripts bash pueden tener problemas en Git Bash de Windows.
**Recomendación**: Usa WSL2 para mejor compatibilidad.

Alternativa en Git Bash:
```bash
# Ejecutar con bash explícito
bash ./scripts/setup/setup_wifi_lab.sh
```

### macOS

**Problema: "tshark: command not found"**

**Solución:**
```bash
# Instalar Homebrew si no lo tienes
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Instalar Wireshark
brew install wireshark
```

**Problema: "Permission denied" al ejecutar scripts**

**Solución:**
```bash
chmod +x scripts/setup/*.sh
chmod +x scripts/demo/*.sh
chmod +x scripts/analysis/*.sh
```

### Linux

**Problema: "tshark: command not found"**

**Solución:**
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install wireshark tshark aircrack-ng -y

# Fedora/RHEL
sudo dnf install wireshark-cli aircrack-ng -y

# Arch Linux
sudo pacman -S wireshark-cli aircrack-ng
```

**Problema: PCAPs no se descargan**

**Solución:**
```bash
# Verificar conectividad
ping -c 3 gitlab.com
ping -c 3 raw.githubusercontent.com

# Verificar curl o wget
curl --version
wget --version

# Ejecutar setup nuevamente
bash scripts/setup/setup_wifi_lab.sh
```

**Ver más**: [docs/guides/GUIA_INSTALACION.md](docs/guides/GUIA_INSTALACION.md#troubleshooting)

---

## 📊 Fuentes de PCAPs

Los 9 PCAPs se descargan automáticamente de fuentes públicas confiables:

### Mathy Vanhoef's WiFi Examples
Investigador de seguridad WiFi (descubridor de KRACK y Dragonblood)
- WPA2 handshakes completos
- PMKID attack examples
- WPA3 SAE captures

### Wireshark Sample Captures
Proyecto oficial de Wireshark
- WEP traffic (legacy)
- Deauth attacks
- HTTP/DNS traffic
- EAPOL exchanges
- DHCP process

**Total**: 9 archivos PCAP (840KB) con escenarios realistas.

Todos los PCAPs son de **dominio público** y disponibles para uso educativo.

---

## 🛡️ Consideraciones Éticas

**⚠️ IMPORTANTE**: Este material es **exclusivamente** para análisis defensivo y educación.

### ✅ Está PERMITIDO:
- Analizar PCAPs proporcionados en este laboratorio
- Practicar técnicas de detección de ataques
- Desarrollar reglas de IDS/IPS
- Realizar pruebas en laboratorios controlados con autorización explícita
- Usar conocimientos para defender redes

### ❌ Está PROHIBIDO:
- Atacar redes WiFi sin autorización escrita del propietario
- Capturar tráfico de redes que no te pertenecen
- Usar técnicas aprendidas de forma maliciosa o ilegal
- Distribuir herramientas sin contexto educativo claro
- Realizar pruebas de penetración sin consentimiento

**El uso no autorizado puede resultar en:**
- Consecuencias legales (penas de cárcel y multas)
- Expulsión de instituciones educativas
- Antecedentes penales

**Recuerda**: Un profesional de ciberseguridad actúa siempre con ética y dentro de la ley.

---

## 📖 Referencias

### Papers y Estándares
- [IEEE 802.11i-2004](https://standards.ieee.org/standard/802_11i-2004.html) - Estándar WPA2
- [Wi-Fi Alliance WPA3 Specification](https://www.wi-fi.org/discover-wi-fi/security) (2018)
- [KRACK Attack](https://www.krackattacks.com/) - Mathy Vanhoef (2017)
- [Dragonblood](https://wpa3.mathyvanhoef.com/) - Vanhoef & Ronen (2019)
- [PMKID Attack](https://hashcat.net/forum/thread-7717.html) - Jens Steube (2018)

### Herramientas
- [Wireshark](https://www.wireshark.org/) - Network protocol analyzer
- [Aircrack-ng](https://www.aircrack-ng.org/) - WiFi security suite
- [Hashcat](https://hashcat.net/hashcat/) - Password recovery tool
- [hcxtools](https://github.com/ZerBea/hcxtools) - PCAP conversion tools

### Recursos Educativos
- [OWASP Wireless Security](https://owasp.org/www-community/controls/Wireless_Security)
- [NIST SP 800-153](https://csrc.nist.gov/publications/detail/sp/800-153/final) - WiFi Security Guidelines
- [Wireshark Sample Captures](https://gitlab.com/wireshark/wireshark/-/wikis/SampleCaptures)
- [Aircrack-ng Documentation](https://www.aircrack-ng.org/doku.php)

---

## 👥 Contribuciones

Este es un proyecto educativo abierto. Si encuentras errores o tienes sugerencias:

1. Fork el repositorio
2. Crea una branch (`git checkout -b feature/mejora`)
3. Commit tus cambios (`git commit -am 'Agrega nueva funcionalidad'`)
4. Push a la branch (`git push origin feature/mejora`)
5. Abre un Pull Request

**Áreas donde puedes contribuir:**
- Nuevos PCAPs educativos
- Ejercicios adicionales
- Traducciones
- Corrección de errores
- Mejoras en documentación
- Scripts adicionales de análisis

---

## 📝 Licencia

Este material educativo está disponible bajo **licencia MIT** para uso académico.

Los PCAPs descargados provienen de repositorios públicos y mantienen sus licencias originales.

Ver [LICENSE](LICENSE) para más detalles.

---

## 📧 Contacto

**Autor**: fboiero
**Email**: fboiero@frvm.utn.edu.ar
**Institución**: Universidad Tecnológica Nacional
**Laboratorio**: Blockchain & Ciberseguridad

**Issues**: https://github.com/WIFI-SEC/lab01/issues
**Pull Requests**: https://github.com/WIFI-SEC/lab01/pulls

---

## 🌟 Agradecimientos

- **Mathy Vanhoef** - Investigación en seguridad WiFi y PCAPs de ejemplo
- **Wireshark Project** - Sample captures públicas y herramienta de análisis
- **Jens Steube (Hashcat)** - Descubrimiento del PMKID attack
- **Aircrack-ng Team** - Suite de herramientas WiFi
- **Comunidad de seguridad WiFi** - Compartir conocimiento y mejores prácticas

---

## 📄 Documentación Adicional

### Para Estudiantes
- **[INICIO_RAPIDO.md](docs/guides/INICIO_RAPIDO.md)** - Guía de inicio extendida
- **[TUTORIAL_PASO_A_PASO.md](docs/guides/TUTORIAL_PASO_A_PASO.md)** - Tutorial completo
- **[CHEATSHEET.md](docs/exercises/CHEATSHEET.md)** - Referencia rápida de comandos

### Para Profesores
- **[GUIA_DEMO.md](docs/guides/GUIA_DEMO.md)** - Cómo presentar en clase
- **[INSTRUCTOR_GUIDE.md](docs/guides/INSTRUCTOR_GUIDE.md)** - Guía del instructor con soluciones
- **[REFERENCIA_RAPIDA_CLASE.md](docs/guides/REFERENCIA_RAPIDA_CLASE.md)** - Referencia de 1 página para imprimir

### Recursos Técnicos
- **[EJERCICIOS_PROGRESIVOS.md](docs/exercises/EJERCICIOS_PROGRESIVOS.md)** - 10 ejercicios con teoría detallada
- **[scripts/demo/README.md](scripts/demo/README.md)** - Guía de scripts de demostración

---

## 🎓 Uso en Cursos

Este laboratorio es ideal para:

- **Cursos de Ciberseguridad** - Módulo de seguridad WiFi
- **Cursos de Redes** - Análisis de protocolos 802.11
- **Cursos de Forense Digital** - Análisis de tráfico de red
- **Talleres y Workshops** - Seguridad inalámbrica
- **Autoestudio** - Práctica independiente con guías detalladas

**Tiempo estimado del curso completo**: 15-20 horas (incluyendo todos los ejercicios y prácticas)

---

**¡Happy Hacking (Ethical)!** 🔐

*Compatible con Windows 10/11, macOS 10.15+, Ubuntu 20.04+*

*Última actualización: Octubre 2025*
