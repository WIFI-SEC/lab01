# Guía del Instructor - Laboratorio de Seguridad WiFi

**Universidad Tecnológica Nacional - Laboratorio Blockchain & Ciberseguridad**

---

## Índice

1. [Resumen Ejecutivo](#resumen-ejecutivo)
2. [Preparación del Laboratorio](#preparación-del-laboratorio)
3. [Estructura de la Clase](#estructura-de-la-clase)
4. [Soluciones y Respuestas](#soluciones-y-respuestas)
5. [Troubleshooting](#troubleshooting)
6. [Evaluación](#evaluación)

---

## Resumen Ejecutivo

Este laboratorio proporciona una experiencia práctica completa de análisis de seguridad WiFi **sin necesidad de realizar capturas en vivo**. Los PCAPs se descargan automáticamente de repositorios públicos (Wireshark, Mathy Vanhoef).

### Ventajas de este Enfoque

✅ **Sin hardware especial**: No requiere adaptadores WiFi con modo monitor
✅ **Sin riesgos legales**: No se captura tráfico real de redes
✅ **Reproducible**: Mismos PCAPs para todos los estudiantes
✅ **Escalable**: Funciona para clases de cualquier tamaño
✅ **Enfoque defensivo**: Énfasis en detección y mitigación

### Duración Estimada

- **Setup inicial**: 15 minutos
- **5 ejercicios**: ~4 horas (45-60 min c/u)
- **Evaluación**: 1 hora
- **Total**: 1 clase de 6 horas o 2 clases de 3 horas

---

## Preparación del Laboratorio

### Pre-clase (1 semana antes)

#### 1. Compartir Requisitos con Estudiantes

Enviar email con:

```
Asunto: Preparación para Laboratorio de Seguridad WiFi

Estimados estudiantes,

Para el laboratorio práctico de seguridad WiFi del [FECHA], necesitan tener instalado:

macOS:
  brew install wireshark aircrack-ng hcxtools

Linux:
  sudo apt update
  sudo apt install wireshark tshark aircrack-ng hcxtools

Windows:
  - Descargar Wireshark: https://www.wireshark.org/download.html
  - Descargar Aircrack-ng: https://www.aircrack-ng.org/
  - Considerar usar WSL2 (Windows Subsystem for Linux)

Verificar instalación ejecutando:
  tshark --version
  aircrack-ng --version

Saludos,
[Profesor]
```

#### 2. Probar el Setup

```bash
# Clonar repositorio (o crear desde cero)
cd ~/Documents
mkdir wifi_lab_test
cd wifi_lab_test

# Copiar archivos del repositorio
# Ejecutar setup
./setup_wifi_lab.sh

# Validar
./validate_setup.sh

# Probar ejercicio
cd analysis_scripts
./01_handshake_analysis.sh
```

#### 3. Preparar Máquina de Respaldo

En caso de que algunos estudiantes tengan problemas de instalación:

- **Opción A**: Máquina virtual pre-configurada (Kali Linux, Parrot OS)
- **Opción B**: Cloud instance (AWS, Azure) con VNC
- **Opción C**: Ejecutar en proyector y que sigan paso a paso

---

## Día del Laboratorio

### Agenda Sugerida (Clase de 6 horas)

```
09:00 - 09:15   Setup y verificación de entorno
09:15 - 09:30   Introducción teórica (repaso)
09:30 - 10:15   Ejercicio 1: WPA2 Handshake (45min)
10:15 - 10:30   Break
10:30 - 11:10   Ejercicio 2: PMKID Attack (40min)
11:10 - 12:00   Ejercicio 3: Deauth Detection (50min)
12:00 - 13:00   Almuerzo
13:00 - 14:00   Ejercicio 4: WPA3 Analysis (60min)
14:00 - 14:15   Break
14:15 - 15:10   Ejercicio 5: Traffic Analysis (55min)
15:10 - 15:30   Q&A y cierre
```

### Setup Inicial (15 min)

#### Verificar Instalaciones

```bash
# Pedir a todos que ejecuten
./validate_setup.sh

# Revisar quién tiene errores
# Asistir individualmente mientras otros avanzan
```

#### Ejecutar Setup del Lab

```bash
# Todos ejecutan simultáneamente
./setup_wifi_lab.sh

# Esto descarga ~10-20 MB de PCAPs
# En red lenta, considerar distribuir en USB
```

### Introducción Teórica (15 min)

**Slides sugeridos**:

1. **Repaso WiFi 101**
   - Frames: Management, Control, Data
   - SSID, BSSID, Channels
   - WEP → WPA → WPA2 → WPA3

2. **Anatomía de un Ataque WiFi**
   - Reconocimiento (wardriving, beacons)
   - Captura de handshake
   - Cracking offline
   - Post-exploitation

3. **Enfoque Defensivo**
   - Detección temprana
   - Hardening
   - Respuesta a incidentes

4. **Herramientas del Lab**
   - Wireshark/tshark
   - aircrack-ng
   - hcxtools

---

## Guiado por Ejercicio

### Ejercicio 1: WPA2 Handshake

**Objetivo pedagógico**: Comprender el 4-way handshake

#### Puntos Clave a Enfatizar

- Los 4 mensajes EAPOL y su función
- Nonces (ANonce, SNonce)
- MIC (Message Integrity Check)
- PTK derivation

#### Demostración en Vivo (10 min)

```bash
# Abrir PCAP en Wireshark
wireshark wifi_lab/pcaps/wpa2/wpa2_handshake_example.pcapng

# Aplicar filtro
eapol

# Mostrar frame-by-frame
# Frame 1: AP → Client (ANonce)
# Frame 2: Client → AP (SNonce, MIC)
# Frame 3: AP → Client (GTK, MIC)
# Frame 4: Client → AP (ACK)
```

#### Preguntas para Discusión

1. **¿Por qué el handshake se captura en plaintext?**
   - Porque ocurre *antes* del cifrado de datos
   - Solo establece las claves, no contiene la contraseña

2. **¿Por qué un atacante forza reconexión con deauth?**
   - Para capturar handshake completo
   - Solo ocurre al conectarse

3. **¿Qué hace vulnerable al WPA2-PSK?**
   - Contraseña débil + diccionario offline
   - No hay rate limiting en cracking offline

#### Solución Esperada

- Identificación de 4 frames EAPOL
- Extracción de SSID, BSSID, MACs
- Exportación a formato hashcat
- (Opcional) Intentar cracking con wordlist débil

---

### Ejercicio 2: PMKID Attack

**Objetivo pedagógico**: Técnicas modernas de ataque WiFi

#### Puntos Clave a Enfatizar

- PMKID está en RSN Information Element
- No requiere cliente conectado
- Menos detectable (pasivo)
- No todos los APs son vulnerables

#### Demostración

```bash
# Buscar PMKID en PCAP
tshark -r wifi_lab/pcaps/wpa2/pmkid_attack_example.pcapng -Y "wlan.rsn.pmkid"

# Extraer con hcxtools
hcxpcapngtool -o pmkid.22000 wifi_lab/pcaps/wpa2/pmkid_attack_example.pcapng

# Mostrar hash
cat pmkid.22000
```

#### Timeline Histórico

- **Antes (2018)**: Necesitabas capturar handshake completo
- **Agosto 2018**: Jens Steube descubre PMKID attack
- **Impacto**: Simplificó ataques contra WiFi
- **Mitigación**: Firmware updates, WPA3

---

### Ejercicio 3: Deauth Detection

**Objetivo pedagógico**: Detección de ataques DoS en WiFi

#### Puntos Clave a Enfatizar

- Deauth legítimo vs malicioso
- Broadcast deauth (ff:ff:ff:ff:ff:ff) = red flag
- Reason codes
- 802.11w como mitigación

#### Demostración de Ataque (Teórico)

**⚠️ SOLO explicar, NO ejecutar**

```bash
# Herramienta común (solo referencia educativa)
# aireplay-ng --deauth 100 -a [BSSID] wlan0mon

# Efectos:
# - Todos los clientes desconectados
# - Reconexión automática captura handshake
# - DoS contra red
```

#### Detección en IDS

Mostrar ejemplo de regla Suricata:

```yaml
alert wifi any any -> any any (
  msg:"WiFi Deauth Flood Detected";
  content:"|c0 00|";
  threshold: type threshold, track by_src, count 10, seconds 5;
  classtype:denial-of-service;
)
```

---

### Ejercicio 4: WPA3 Analysis

**Objetivo pedagógico**: Evolución de seguridad WiFi

#### Puntos Clave a Enfatizar

- SAE (Dragonfly) vs PSK
- Forward secrecy
- Obligatoriedad de 802.11w
- Dragonblood vulnerabilities (parcheadas)

#### Comparación Visual

Crear tabla en pizarra:

| Característica | WPA2 | WPA3 |
|----------------|------|------|
| Auth | PSK | SAE |
| Offline Attack | Vulnerable | Resistente |
| Forward Secrecy | No | Sí |
| KRACK | Vulnerable | Protegido |
| PMF (802.11w) | Opcional | Obligatorio |

#### Caso de Estudio: Dragonblood

- **2019**: Investigadores encuentran vulnerabilidades
- **CVE-2019-9494**: Timing attack
- **Impacto**: Parcial (difícil de explotar)
- **Respuesta**: Parches rápidos
- **Lección**: Incluso WPA3 no es perfecto

---

### Ejercicio 5: Traffic Analysis

**Objetivo pedagógico**: Riesgos en WiFi público

#### Demostración de MitM (Teórico)

**Scenario**: Café con WiFi público

1. **Atacante** configura Evil Twin
2. **Víctima** se conecta al AP falso
3. **Atacante** hace SSL stripping
4. **Víctima** envía credenciales en HTTP
5. **Atacante** captura datos

#### Mitigaciones Prácticas

- **Para usuarios**: VPN, HTTPS Everywhere
- **Para admins**: WPA3, 802.1X, WIDS
- **Para developers**: HSTS, certificate pinning

---

## Soluciones y Respuestas

### Ejercicio 1: Respuestas

1. **¿Cuántos mensajes EAPOL?** → 4
2. **Información intercambiada**:
   - Msg 1: ANonce
   - Msg 2: SNonce + MIC
   - Msg 3: GTK + MIC
   - Msg 4: ACK
3. **Detectar KRACK**: Buscar nonces repetidos
4. **Herramientas**: aircrack-ng, hashcat, john

### Ejercicio 2: Respuestas

1. **Info para crackear PMKID**:
   - PMKID hash
   - MAC_AP
   - MAC_STA
   - SSID
2. **Menos detectable**: No genera deauth ni tráfico anómalo
3. **Diferencias**:
   - PMK: Pairwise Master Key (derivado de PSK)
   - PMKID: Hash del PMK para identificación
   - PTK: Pairwise Transient Key (para sesión)

### Ejercicio 3: Respuestas

1. **Legítimo vs Malicioso**:
   - Legítimo: Único, reason code normal
   - Malicioso: Múltiples, broadcast, rate alto
2. **802.11w**: Cifra management frames
3. **Reason codes sospechosos**: 6, 7 (frames desde no-autenticado)
4. **Comando**: `tshark -r X -Y "wlan.fc.type_subtype == 0x0c"`

### Ejercicio 4: Respuestas

1. **SAE resuelve**: Ataques de diccionario offline
2. **802.11w obligatorio**: Proteger contra deauth attacks
3. **Forward secrecy**: Claves de sesión únicas, comprometer una no afecta otras
4. **Dragonblood**: Vulnerabilidades en implementación de SAE (timing attacks)
5. **Transition mode**: Durante migración, pero cuidado con downgrades

### Ejercicio 5: Respuestas

1. **Riesgos HTTP en WiFi público**: Sniffing, credentials in plaintext, session hijacking
2. **SSL Stripping**: MitM convierte HTTPS a HTTP transparentemente
3. **DNS Tunneling**: Exfiltrar datos en queries DNS (detectar por longitud)
4. **Headers defensivos**: HSTS, CSP, X-Frame-Options
5. **Detectar MitM**: ARP spoofing, DNS anomalías, certificate changes

---

## Troubleshooting

### Problema: "tshark: command not found"

**Solución**:
```bash
# macOS
brew install wireshark

# Linux
sudo apt install tshark
```

### Problema: PCAPs no se descargan

**Causas**:
- Firewall corporativo
- Red sin internet
- Repositorios caídos

**Solución**:
1. Distribuir PCAPs en USB
2. Usar mirror local (nginx)
3. Descargar manualmente y compartir

### Problema: "Permission denied" en Wireshark

**Solución macOS**:
```bash
brew install --cask wireshark
# Instala ChmodBPF automáticamente
```

**Solución Linux**:
```bash
sudo usermod -aG wireshark $USER
# Logout y login
```

### Problema: Scripts no ejecutables

```bash
chmod +x *.sh
chmod +x analysis_scripts/*.sh
```

### Problema: Hashcat no funciona (sin GPU)

**Alternativa**: Usar John the Ripper (solo CPU)

```bash
# Convertir a formato John
hccap2john handshake.hccap > hash.john

# Crackear
john --wordlist=wordlist.txt hash.john
```

---

## Evaluación

### Rúbrica Sugerida

| Criterio | Puntos | Descripción |
|----------|--------|-------------|
| **Completitud** | 30 | Todos los ejercicios realizados |
| **Precisión Técnica** | 30 | Respuestas correctas y detalladas |
| **Análisis Crítico** | 20 | Interpretación de resultados |
| **Propuestas de Mitigación** | 20 | Soluciones realistas |
| **TOTAL** | **100** | |

### Entregables Esperados

```
apellido_nombre_wifi_lab/
├── reportes/
│   ├── ejercicio1_handshake.pdf
│   ├── ejercicio2_pmkid.pdf
│   ├── ejercicio3_deauth.pdf
│   ├── ejercicio4_wpa3.pdf
│   └── ejercicio5_traffic.pdf
├── screenshots/
│   └── (evidencia en Wireshark)
└── README.txt (resumen ejecutivo)
```

### Criterios de Evaluación por Ejercicio

#### Ejercicio 1 (20 pts)
- [ ] Identificó 4 frames EAPOL (5 pts)
- [ ] Extrajo SSID/BSSID correctamente (5 pts)
- [ ] Explicó función de cada mensaje (5 pts)
- [ ] Exportó handshake para hashcat (5 pts)

#### Ejercicio 2 (20 pts)
- [ ] Encontró PMKIDs en PCAP (5 pts)
- [ ] Explicó ventajas sobre handshake (5 pts)
- [ ] Comparó métodos de ataque (5 pts)
- [ ] Propuso mitigaciones (5 pts)

#### Ejercicio 3 (20 pts)
- [ ] Detectó deauth frames (5 pts)
- [ ] Analizó reason codes (5 pts)
- [ ] Identificó patrones de ataque (5 pts)
- [ ] Creó reglas de detección (5 pts)

#### Ejercicio 4 (20 pts)
- [ ] Explicó SAE vs PSK (5 pts)
- [ ] Identificó mejoras WPA3 (5 pts)
- [ ] Describió Dragonblood (5 pts)
- [ ] Creó plan de migración (5 pts)

#### Ejercicio 5 (20 pts)
- [ ] Analizó tráfico HTTP (5 pts)
- [ ] Detectó datos sensibles (5 pts)
- [ ] Identificó indicadores MitM (5 pts)
- [ ] Propuso defensa en profundidad (5 pts)

---

## Extensiones y Ejercicios Adicionales

### Para Estudiantes Avanzados

1. **Crear reglas personalizadas de Suricata/Snort**
2. **Desarrollar script Python para parsear PCAPs**
3. **Implementar honeypot WiFi para detectar ataques**
4. **Analizar tráfico cifrado (metadata analysis)**
5. **Crear dashboard en Grafana con métricas WiFi**

### Proyectos Finales Sugeridos

- **Red Team vs Blue Team**: Simular ataque y defensa
- **Auditoría WiFi corporativa**: Metodología completa
- **WIDS casero**: Usando Raspberry Pi + Kismet
- **Análisis forense**: Reconstruir timeline de incidente

---

## Recursos Adicionales

### Papers Recomendados

- "KRACK Attacks: Breaking WPA2" - Mathy Vanhoef (2017)
- "Dragonblood: Analyzing WPA3's Dragonfly Handshake" - Vanhoef & Ronen (2019)
- "PMKID Attack" - Jens Steube (2018)

### Libros

- "Hacking Exposed Wireless" - Cache & Wright
- "802.11 Wireless Networks: The Definitive Guide" - Gast
- "Practical Packet Analysis" - Sanders

### Cursos Online

- WiFi Security on Pluralsight
- Wireless Security OSWP (Offensive Security)
- SANS SEC617 (Wireless Penetration Testing)

---

## Feedback y Mejora Continua

### Post-Clase

1. **Encuesta a estudiantes**:
   - ¿Ejercicios muy difíciles/fáciles?
   - ¿Suficiente tiempo?
   - ¿Herramientas funcionaron?

2. **Auto-evaluación**:
   - ¿Qué ejercicio tomó más tiempo?
   - ¿Hubo problemas técnicos recurrentes?
   - ¿Preguntas que no pude responder?

3. **Actualizar material**:
   - Agregar nuevos PCAPs
   - Incorporar vulnerabilidades recientes
   - Mejorar troubleshooting guide

---

## Contacto y Soporte

**Autor del Laboratorio**: [Tu Nombre]
**Email**: [email@utn.edu.ar]
**GitHub**: [github.com/tu-usuario/wifisec]

Para reportar bugs o sugerir mejoras, abrir issue en GitHub.

---

**¡Éxito con el laboratorio!** 🎓🔐

*Última actualización: Octubre 2025*
