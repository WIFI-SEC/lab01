# 📊 Resumen del Proyecto: Laboratorio WiFi Security - UTN

**Universidad Tecnológica Nacional**
**Laboratorio de Blockchain & Ciberseguridad**

**Fecha**: Octubre 2025
**Autor**: fboiero <fboiero@frvm.utn.edu.ar>
**Repositorio**: https://github.com/WIFI-SEC/lab01.git

---

## 🎯 Visión General del Proyecto

Este repositorio contiene un **laboratorio completo de seguridad WiFi** diseñado para uso educativo en la Universidad Tecnológica Nacional. El proyecto proporciona material práctico para que los estudiantes aprendan análisis forense de tráfico WiFi, detección de ataques y técnicas defensivas utilizando herramientas profesionales.

### Características Principales

✅ **9 PCAPs realistas** (840KB) de fuentes públicas confiables
✅ **10 ejercicios progresivos** estructurados por dificultad
✅ **3 scripts de demostración** para presentaciones en clase
✅ **5 scripts de análisis** automatizados por tema
✅ **Documentación completa** para profesores y alumnos
✅ **Setup automatizado** con validación de integridad
✅ **Enfoque ético** en análisis defensivo

---

## 📁 Estructura del Repositorio

```
lab01/                                  # Raíz del proyecto
│
├── README.md                           # Documentación principal ⭐
├── LICENSE                             # Licencia MIT
├── PROYECTO_RESUMEN.md                 # Este documento
│
├── docs/                               # 📚 Documentación completa
│   │
│   ├── exercises/                      # Material de ejercicios
│   │   ├── EJERCICIOS_PROGRESIVOS.md  # 10 ejercicios estructurados (30KB) ⭐
│   │   ├── EJERCICIOS.md              # Ejercicios originales (24KB)
│   │   └── CHEATSHEET.md              # Referencia rápida de comandos (13KB)
│   │
│   └── guides/                         # Guías para instructores
│       ├── GUIA_DEMO.md               # Cómo presentar el laboratorio (15KB)
│       ├── GUIA_INSTALACION.md        # Instalación detallada (19KB)
│       ├── INICIO_RAPIDO.md           # Quick start extendido (12KB)
│       ├── INSTRUCTOR_GUIDE.md        # Soluciones y respuestas (59KB) 🔒
│       ├── TUTORIAL_PASO_A_PASO.md    # Tutorial completo (40KB)
│       └── REFERENCIA_RAPIDA_CLASE.md # Referencia de 1 página (8KB)
│
├── scripts/                            # 🔧 Scripts del laboratorio
│   │
│   ├── setup/                          # Instalación y configuración
│   │   ├── install_tools.sh           # Instalar herramientas (tshark, aircrack-ng)
│   │   ├── setup_wifi_lab.sh          # Setup inicial (descarga 6 PCAPs)
│   │   ├── download_additional_pcaps.sh # Descarga 3 PCAPs adicionales
│   │   ├── validate_setup.sh          # Validación con SHA256
│   │   └── create_test_wordlist.sh    # Wordlist para cracking
│   │
│   ├── demo/                           # Demostraciones para clase
│   │   ├── README.md                  # Guía de uso de demos
│   │   ├── demo_rapida.sh             # Demo express 5 min ⚡
│   │   ├── demo_laboratorio.sh        # Demo completa 15-20 min 🎯
│   │   └── demo_simple.sh             # Demo simplificada (backup)
│   │
│   └── analysis/                       # Scripts de análisis por tema
│       ├── 01_handshake_analysis.sh   # WPA2 4-way handshake
│       ├── 02_pmkid_analysis.sh       # PMKID attack analysis
│       ├── 03_deauth_detection.sh     # Detección de deauth attacks
│       ├── 04_wpa3_analysis.sh        # WPA3 SAE analysis
│       └── 05_traffic_analysis.sh     # HTTP/DNS traffic
│
└── wifi_lab/                           # 🗂️ Directorio del laboratorio (generado)
    │
    ├── pcaps/                          # PCAPs organizados por categoría
    │   ├── wpa2/                       # 2 archivos (207KB)
    │   │   ├── wpa_induction.pcap     # Handshake completo ⭐
    │   │   └── wpa_eap_tls.pcap       # Enterprise WPA2
    │   │
    │   ├── wpa3/                       # 1 archivo (32KB)
    │   │   └── cisco_wireless.pcap    # WPA3 SAE
    │   │
    │   ├── wep/                        # 1 archivo (161KB)
    │   │   └── mobile_network_join.pcap
    │   │
    │   ├── attacks/                    # 2 archivos (48KB)
    │   │   ├── arp_spoofing.pcap      # MitM attack ⭐
    │   │   └── radius_auth.pcapng     # RADIUS
    │   │
    │   └── misc/                       # 3 archivos (344KB)
    │       ├── http_captive_portal.cap # HTTP inseguro ⭐
    │       ├── dhcp_traffic.pcap      # DHCP DORA process
    │       └── dns_tunnel.pcap        # DNS tunneling
    │
    ├── outputs/                        # Resultados de análisis
    ├── reports/                        # Reportes generados
    ├── manifest.sha256                 # Checksums de integridad
    └── manifest.txt                    # Lista de PCAPs
```

---

## 📊 Estadísticas del Proyecto

### Archivos y Código

| Categoría | Cantidad | Tamaño Total |
|-----------|----------|--------------|
| **Scripts Bash** | 13 | ~45KB |
| **Documentos Markdown** | 11 | ~220KB |
| **PCAPs** | 9 | 840KB |
| **Total archivos** | 33+ | ~1.1MB |

### Contenido Educativo

| Componente | Cantidad | Tiempo Estimado |
|------------|----------|-----------------|
| **Ejercicios Básicos** | 3 | 90 min total |
| **Ejercicios Intermedios** | 3 | 135 min total |
| **Ejercicios Avanzados** | 3 | 180 min total |
| **Ejercicio Integrador** | 1 | 90-120 min |
| **Total ejercicios** | 10 | ~8 horas |

### Demos

| Demo | Duración | Secciones | Genera Reporte |
|------|----------|-----------|----------------|
| demo_rapida.sh | 5 min | 5 highlights | No |
| demo_laboratorio.sh | 15-20 min | 7 secciones | Sí ✓ |
| demo_simple.sh | 10 min | Simplificado | No |

---

## 🎓 Material Educativo Detallado

### 1. Ejercicios Progresivos (docs/exercises/EJERCICIOS_PROGRESIVOS.md)

**Nivel Básico** (30 min c/u):
1. **Explorando PCAPs con tshark**
   - Comandos básicos de tshark
   - Filtros simples
   - Estadísticas de tráfico
   - PCAP: `wpa_induction.pcap`

2. **Frames WiFi Básicos**
   - Beacon frames
   - Probe Request/Response
   - Association/Reassociation
   - PCAP: `wpa_induction.pcap`

3. **DHCP y Conexión a Red**
   - Proceso DORA (Discover, Offer, Request, Ack)
   - Opciones DHCP
   - Detección de DHCP rogue
   - PCAP: `dhcp_traffic.pcap`

**Nivel Intermedio** (45 min c/u):
4. **WPA2 4-Way Handshake Profundo**
   - Los 4 mensajes EAPOL
   - PTK/PMK derivation
   - Verificación con aircrack-ng
   - PCAP: `wpa_induction.pcap` ⭐

5. **Extracción de Nonces y MIC**
   - ANonce y SNonce
   - Message Integrity Code (MIC)
   - Formato para hashcat
   - PCAP: `wpa_induction.pcap`

6. **DNS Analysis**
   - Queries y responses
   - DNS tunneling detection
   - Anomalías de DNS
   - PCAP: `dns_tunnel.pcap`

**Nivel Avanzado** (60 min c/u):
7. **ARP Spoofing Detection**
   - ARP storm detection
   - Múltiples MACs por IP
   - MitM indicators
   - PCAP: `arp_spoofing.pcap` ⭐

8. **HTTP Traffic Analysis**
   - HTTP sin cifrar
   - Captive portals
   - Redirects sospechosos
   - PCAP: `http_captive_portal.cap` ⭐

9. **PMKID Attack Simulation**
   - Extracción de PMKID
   - Conversión a formato hashcat
   - Cracking offline
   - PCAP: `wpa_induction.pcap`

**Escenario Integrador** (90-120 min):
10. **Auditoría Completa de Red WiFi**
    - Análisis de múltiples PCAPs
    - Detección de todas las amenazas
    - Generación de reporte completo
    - Recomendaciones de mitigación

### 2. Scripts de Demostración (scripts/demo/)

#### Demo Rápida (5 minutos)
```bash
bash scripts/demo/demo_rapida.sh
```

**Contenido**:
- ✓ PCAPs disponibles: 9 archivos (840KB)
- ✓ WPA2 Handshake: SSID "Coherer", 4 EAPOL frames
- ✓ ARP Spoofing: 622 paquetes detectados
- ✓ HTTP Traffic: 19 requests sin cifrar
- ✓ Ejercicios disponibles: 10 progresivos

**Ideal para**: Presentación ejecutiva, introducción rápida

#### Demo Completa (15-20 minutos)
```bash
bash scripts/demo/demo_laboratorio.sh
```

**7 Secciones**:
1. Verificación del laboratorio (herramientas, PCAPs)
2. Análisis WPA2 4-Way Handshake (4 EAPOL frames)
3. Análisis DHCP (proceso DORA)
4. Detección ARP Spoofing (622 paquetes)
5. Análisis HTTP (19 requests, captive portal)
6. Extracción crypto (ANonce, SNonce, MIC)
7. Generación de reporte automático

**Modos**:
- **Interactivo**: Pausas entre secciones (recomendado clase)
- **Rápido**: Sin pausas (grabación)

**Genera**: `wifi_lab/reports/demo_YYYYMMDD_HHMMSS.txt`

**Ideal para**: Primera clase, capacitación profesores, workshop

### 3. Scripts de Análisis (scripts/analysis/)

| Script | Tema | PCAP Usado | Conceptos |
|--------|------|------------|-----------|
| 01_handshake_analysis.sh | WPA2 Handshake | wpa_induction.pcap | EAPOL, PTK, PMK, nonces |
| 02_pmkid_analysis.sh | PMKID Attack | wpa_induction.pcap | PMKID, RSN IE, hashcat |
| 03_deauth_detection.sh | Deauth Attacks | (simulado) | Management frames, reason codes |
| 04_wpa3_analysis.sh | WPA3 SAE | cisco_wireless.pcap | Dragonfly, SAE, forward secrecy |
| 05_traffic_analysis.sh | HTTP/DNS | http_captive_portal.cap | MitM, SSL stripping, tunneling |

---

## 🛠️ Guías de Instalación y Uso

### Quick Start Completo

```bash
# 1. Clonar repositorio
git clone https://github.com/WIFI-SEC/lab01.git
cd lab01

# 2. Instalar herramientas (macOS/Linux)
bash scripts/setup/install_tools.sh

# 3. Setup del laboratorio
bash scripts/setup/setup_wifi_lab.sh

# 4. Descargar PCAPs adicionales (recomendado)
bash scripts/setup/download_additional_pcaps.sh

# 5. Validar instalación
bash scripts/setup/validate_setup.sh

# 6. Ver demo (primera vez recomendado)
bash scripts/demo/demo_rapida.sh

# 7. Empezar con ejercicios
# Ver docs/exercises/EJERCICIOS_PROGRESIVOS.md
```

### Herramientas Requeridas

| Herramienta | Versión Mínima | Uso |
|-------------|----------------|-----|
| **tshark/Wireshark** | 3.0+ | Análisis de PCAPs |
| **aircrack-ng** | 1.6+ | Verificación handshakes, cracking |
| **hcxtools** | 6.0+ | Conversión PCAP → hashcat |
| **bash** | 4.0+ | Ejecución de scripts |
| **curl/wget** | Cualquiera | Descarga de PCAPs |

### Validación de Setup

```bash
bash scripts/setup/validate_setup.sh
```

**Verifica**:
- ✓ Herramientas instaladas (tshark, aircrack-ng)
- ✓ 9 PCAPs presentes
- ✓ Integridad SHA256 correcta
- ✓ Permisos de ejecución en scripts
- ✓ Estructura de directorios completa

---

## 📚 Documentación Completa

### Para Estudiantes

1. **INICIO_RAPIDO.md** (docs/guides/)
   - Quick start extendido
   - Primeros pasos
   - Comandos básicos

2. **TUTORIAL_PASO_A_PASO.md** (docs/guides/)
   - Tutorial completo guiado
   - Screenshots y ejemplos
   - Troubleshooting

3. **EJERCICIOS_PROGRESIVOS.md** (docs/exercises/) ⭐
   - 10 ejercicios detallados
   - Paso a paso con comandos
   - Outputs esperados
   - Preguntas y respuestas

4. **CHEATSHEET.md** (docs/exercises/)
   - Comandos útiles de tshark
   - Filtros de Wireshark
   - Comandos aircrack-ng
   - Referencia rápida

### Para Profesores

1. **GUIA_DEMO.md** (docs/guides/)
   - Cómo presentar en clase
   - Escenarios de uso (2h clase, 10min presentación, 30min workshop)
   - Tips de presentación
   - Checklist pre-clase

2. **INSTRUCTOR_GUIDE.md** (docs/guides/) 🔒
   - Soluciones completas
   - Respuestas a ejercicios
   - Explicaciones técnicas
   - Criterios de evaluación

3. **REFERENCIA_RAPIDA_CLASE.md** (docs/guides/)
   - Referencia de 1 página
   - Comandos clave
   - Para imprimir y distribuir

4. **GUIA_INSTALACION.md** (docs/guides/)
   - Instalación detallada
   - Troubleshooting completo
   - Configuración avanzada

---

## 🔍 PCAPs Incluidos

### 1. WPA2 (2 archivos, 207KB)

**wpa_induction.pcap** (175KB) ⭐ **[PRINCIPAL]**
- SSID: "Coherer"
- 4 EAPOL frames (handshake completo)
- AP: `00:0c:41:82:b2:55`
- Cliente: `00:0d:93:82:36:3a`
- **Usado en**: Ejercicios 1, 2, 4, 5, 9
- **Fuente**: Wireshark Sample Captures

**wpa_eap_tls.pcap** (32KB)
- WPA2-Enterprise con EAP-TLS
- **Usado en**: Ejercicio avanzado (opcional)

### 2. WPA3 (1 archivo, 32KB)

**cisco_wireless.pcap** (32KB)
- WPA3 SAE (Dragonfly)
- **Usado en**: Ejercicio 4 (WPA3 analysis)

### 3. Attacks (2 archivos, 48KB)

**arp_spoofing.pcap** (46KB) ⭐
- 622 paquetes ARP
- 622 requests, 0 replies (ARP storm)
- **Usado en**: Ejercicio 7 (ARP Spoofing Detection)
- **Fuente**: Wireshark Sample Captures

**radius_auth.pcapng** (2.9KB)
- RADIUS authentication
- **Usado en**: Ejercicio avanzado (opcional)

### 4. Misc (3 archivos, 344KB)

**http_captive_portal.cap** (319KB) ⭐
- 19 HTTP requests sin cifrar
- Hosts: 10.1.1.1, opera.com, advertising.com
- **Usado en**: Ejercicio 8 (HTTP Traffic Analysis)
- **Fuente**: Wireshark Sample Captures

**dhcp_traffic.pcap** (1.4KB)
- Proceso DORA completo (4 frames)
- **Usado en**: Ejercicio 3 (DHCP)

**dns_tunnel.pcap** (24KB)
- DNS queries sospechosas
- **Usado en**: Ejercicio 6 (DNS Analysis)

### 5. WEP (1 archivo, 161KB)

**mobile_network_join.pcap** (161KB)
- WEP (legacy, inseguro)
- **Usado en**: Ejercicio histórico

---

## 🎬 Casos de Uso

### Caso 1: Primera Clase del Módulo (2 horas)

```
Minuto 0-10:    Introducción teórica (slides WiFi)
Minuto 10-30:   🎬 bash scripts/demo/demo_laboratorio.sh (interactivo)
Minuto 30-45:   Explicación de herramientas (tshark, wireshark)
Minuto 45-90:   Ejercicio 1 guiado (Explorando PCAPs)
Minuto 90-110:  Práctica individual
Minuto 110-120: Q&A y resumen
```

**Resultado**: Alumnos listos para empezar ejercicios

### Caso 2: Presentación Ejecutiva (10 minutos)

```
Minuto 0-2:   Introducción al laboratorio
Minuto 2-7:   🎬 bash scripts/demo/demo_rapida.sh
Minuto 7-10:  Q&A rápida
```

**Resultado**: Overview completo del laboratorio

### Caso 3: Workshop de Profesores (30 minutos)

```
Minuto 0-5:    Overview del proyecto
Minuto 5-25:   🎬 bash scripts/demo/demo_laboratorio.sh (interactivo)
Minuto 25-30:  Revisión de docs/exercises/EJERCICIOS_PROGRESIVOS.md
```

**Resultado**: Profesores capacitados para usar el laboratorio

---

## 🔐 Consideraciones Éticas

### Uso Permitido ✅

- Analizar PCAPs proporcionados
- Practicar detección de ataques
- Desarrollar reglas IDS/IPS
- Testear en laboratorios controlados con autorización
- Educación y formación defensiva

### Uso Prohibido ❌

- Atacar redes WiFi sin autorización
- Capturar tráfico de redes ajenas
- Uso malicioso de técnicas aprendidas
- Distribución sin contexto educativo

**⚠️ El uso no autorizado puede resultar en consecuencias legales**

---

## 📈 Mejoras Implementadas

### Versión Inicial → Versión Actual

| Aspecto | Antes | Después | Mejora |
|---------|-------|---------|--------|
| **PCAPs** | 6 archivos (420KB) | 9 archivos (840KB) | +50% |
| **Ejercicios** | 5 ejercicios | 10 ejercicios progresivos | +100% |
| **Niveles** | 1 nivel | 3 niveles + integrador | +300% |
| **Demos** | 0 | 3 scripts completos | ∞ |
| **Documentación** | Básica | 11 documentos detallados | +1000% |
| **Organización** | Plana | Estructura modular | Profesional |

### Cambios Recientes (Última Actualización)

✅ **Reorganización de estructura**:
- Archivos movidos a `docs/`, `scripts/setup/`, `scripts/demo/`, `scripts/analysis/`
- Archivos redundantes archivados en `.archive/` (ignorado por git)
- README.md actualizado con nueva estructura

✅ **Mejoras en demos**:
- Fix en `demo_laboratorio.sh` (handshake display, aircrack-ng hanging)
- Creación de `demo_simple.sh` (versión robusta)
- Documentación en `scripts/demo/README.md`

✅ **Documentación mejorada**:
- README.md con estructura completa y clara
- PROYECTO_RESUMEN.md (este documento)
- Enlaces actualizados a nueva estructura

---

## 🚀 Próximos Pasos Recomendados

### Para Estudiantes

1. ✅ Ejecutar `bash scripts/setup/validate_setup.sh`
2. ✅ Ver demo rápida: `bash scripts/demo/demo_rapida.sh`
3. ✅ Abrir `docs/exercises/EJERCICIOS_PROGRESIVOS.md`
4. ✅ Empezar con Ejercicio 1 (Básico)
5. ✅ Practicar comandos del `docs/exercises/CHEATSHEET.md`

### Para Profesores

1. ✅ Leer `docs/guides/GUIA_DEMO.md`
2. ✅ Probar `bash scripts/demo/demo_laboratorio.sh`
3. ✅ Revisar `docs/guides/INSTRUCTOR_GUIDE.md`
4. ✅ Preparar slides teóricos complementarios
5. ✅ Planear sesión según caso de uso

### Para Contribuidores

1. ✅ Fork del repositorio
2. ✅ Agregar nuevos PCAPs (categoría apropiada)
3. ✅ Crear ejercicios adicionales
4. ✅ Mejorar scripts de análisis
5. ✅ Pull request con cambios

---

## 📊 Métricas de Éxito

### Indicadores de un Laboratorio Exitoso

✅ **Instalación sin problemas** (>95% estudiantes)
✅ **Completar 3+ ejercicios básicos** (primera clase)
✅ **Entender WPA2 handshake** (ejercicio 4)
✅ **Detectar ataques** (ejercicios 7-8)
✅ **Generar reportes** (ejercicio 10)

### Feedback Esperado

- "Ahora entiendo cómo funciona WPA2"
- "Puedo detectar ataques en PCAPs reales"
- "Las demos fueron muy claras"
- "Los ejercicios progresivos ayudan mucho"
- "Quiero seguir practicando"

---

## 📧 Soporte y Contacto

**Autor**: fboiero
**Email**: fboiero@frvm.utn.edu.ar
**Institución**: Universidad Tecnológica Nacional
**Laboratorio**: Blockchain & Ciberseguridad

**Repositorio**: https://github.com/WIFI-SEC/lab01.git

**Reportar Issues**: https://github.com/WIFI-SEC/lab01/issues

---

## 📝 Licencia

**MIT License** - Uso académico y educativo

Ver [LICENSE](LICENSE) para detalles completos.

Los PCAPs descargados mantienen sus licencias originales (dominio público educativo).

---

## 🙏 Agradecimientos

- **Mathy Vanhoef** - Investigador de KRACK y Dragonblood, PCAPs de ejemplo
- **Wireshark Project** - Sample captures públicas
- **Jens Steube (Hashcat)** - PMKID attack discovery
- **Aircrack-ng Team** - Suite de herramientas WiFi
- **Comunidad de seguridad WiFi** - Por compartir conocimiento

---

## 📅 Historial de Versiones

### v1.0 (Octubre 2025) - Versión Inicial Completa
- ✅ 9 PCAPs (840KB)
- ✅ 10 ejercicios progresivos
- ✅ 3 scripts de demo
- ✅ 5 scripts de análisis
- ✅ 11 documentos de guía
- ✅ Setup automatizado
- ✅ Validación SHA256
- ✅ Estructura organizada
- ✅ README completo

---

**Universidad Tecnológica Nacional**
**Laboratorio de Blockchain & Ciberseguridad**

🔐 **Material Educativo - Análisis Defensivo - Uso Ético**

*Última actualización: Octubre 2025*

---

