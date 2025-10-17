# 🚀 Inicio Rápido - Laboratorio WiFi Security

## Para el Profesor

### Setup Inicial (5 minutos)

```bash
# 1. Instalar herramientas requeridas
brew install wireshark aircrack-ng

# 2. Ejecutar setup del laboratorio
bash setup_wifi_lab.sh

# 3. Validar instalación
bash validate_setup.sh

# 4. Probar ejercicio 1
bash analysis_scripts/01_handshake_analysis.sh
```

---

## Para los Alumnos

### Instalación de Herramientas

**macOS:**
```bash
brew install wireshark aircrack-ng
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt update
sudo apt install wireshark tshark aircrack-ng
```

**Verificar instalación:**
```bash
tshark --version
aircrack-ng --version
```

### Setup del Laboratorio

```bash
# 1. Clonar repositorio o descargar archivos
cd ~/Documents/wifisec

# 2. Ejecutar setup (descarga PCAPs)
bash setup_wifi_lab.sh

# 3. Verificar que todo esté OK
bash validate_setup.sh
```

### Ejecutar Ejercicios

```bash
# Ejercicio 1: WPA2 4-Way Handshake
bash analysis_scripts/01_handshake_analysis.sh

# Ejercicio 2: PMKID Attack
bash analysis_scripts/02_pmkid_analysis.sh

# Ejercicio 3: Deauth Detection
bash analysis_scripts/03_deauth_detection.sh

# Ejercicio 4: WPA3 Analysis
bash analysis_scripts/04_wpa3_analysis.sh

# Ejercicio 5: Traffic Analysis
bash analysis_scripts/05_traffic_analysis.sh
```

---

## 📊 Estado Actual

### ✅ Lo que Ya Funciona

- **3 PCAPs descargados** (~248KB total)
  - `wpa_induction.pcap` - WPA handshake completo con 4 frames EAPOL ⭐
  - `wpa_eap_tls.pcap` - Autenticación EAP-TLS
  - `cisco_wireless.pcap` - Tráfico WiFi de Cisco

- **5 scripts de análisis listos**
  - Todos ejecutables y funcionales
  - Con teoría, análisis y preguntas

- **Documentación completa**
  - README.md (general)
  - EJERCICIOS.md (para alumnos)
  - INSTRUCTOR_GUIDE.md (para profesor)
  - CHEATSHEET.md (referencia rápida)

### ⚠️ Opcional (Recomendado)

```bash
# Para ejercicios avanzados de PMKID
brew install hcxtools

# Para demostración de cracking (opcional)
brew install hashcat
```

---

## 🎯 Ejercicio 1: Quick Test

Verifica que todo funciona con el ejercicio principal:

```bash
# Ejecutar análisis
bash analysis_scripts/01_handshake_analysis.sh

# Deberías ver:
# ✓ 4 frames EAPOL encontrados
# ✓ SSID y BSSID extraídos
# ✓ PCAP exportado para aircrack-ng
```

**Abrir en Wireshark:**
```bash
wireshark wifi_lab/pcaps/wpa2/wpa_induction.pcap -Y 'eapol'
```

Deberías ver 4 frames EAPOL:
- Frame 87: Message 1 of 4 (AP → Client)
- Frame 89: Message 2 of 4 (Client → AP)
- Frame 92: Message 3 of 4 (AP → Client)
- Frame 94: Message 4 of 4 (Client → AP)

---

## 📁 Estructura de Archivos

```
wifisec/
├── README.md                    # Documentación principal
├── EJERCICIOS.md               # Guía para alumnos
├── INSTRUCTOR_GUIDE.md         # Guía para profesor
├── CHEATSHEET.md               # Comandos útiles
├── INICIO_RAPIDO.md            # Este archivo
├── setup_wifi_lab.sh           # Setup principal
├── validate_setup.sh           # Validación
├── analysis_scripts/           # Scripts de ejercicios
│   ├── 01_handshake_analysis.sh
│   ├── 02_pmkid_analysis.sh
│   ├── 03_deauth_detection.sh
│   ├── 04_wpa3_analysis.sh
│   └── 05_traffic_analysis.sh
└── wifi_lab/                   # Creado por setup
    ├── pcaps/                  # PCAPs descargados
    ├── outputs/                # Resultados
    └── reports/                # Reportes
```

---

## 🔧 Troubleshooting Común

### Error: "tshark: command not found"

```bash
# macOS
brew install wireshark

# Linux
sudo apt install tshark
```

### Error: "aircrack-ng: command not found"

```bash
# macOS
brew install aircrack-ng

# Linux
sudo apt install aircrack-ng
```

### Scripts no ejecutables

```bash
chmod +x *.sh
chmod +x analysis_scripts/*.sh
```

### PCAPs no se descargan

- Verificar conexión a internet
- Algunas URLs pueden estar temporalmente caídas
- Al menos deben descargarse 2-3 PCAPs esenciales

---

## 📖 Documentos Importantes

| Archivo | Para Quién | Contenido |
|---------|-----------|-----------|
| **README.md** | Todos | Overview del proyecto |
| **EJERCICIOS.md** | Alumnos | Guía detallada de ejercicios |
| **INSTRUCTOR_GUIDE.md** | Profesor | Soluciones, timing, tips |
| **CHEATSHEET.md** | Todos | Comandos de referencia rápida |
| **INICIO_RAPIDO.md** | Todos | Setup rápido (este archivo) |

---

## 🎓 Para la Clase

### Antes de la Clase

1. **Enviar a alumnos** (1 semana antes):
   - Lista de herramientas a instalar
   - Link al repositorio
   - Instrucciones de este archivo

2. **Probar todo** (1 día antes):
   ```bash
   rm -rf wifi_lab
   bash setup_wifi_lab.sh
   bash validate_setup.sh
   bash analysis_scripts/01_handshake_analysis.sh
   ```

### Durante la Clase

1. **Setup (15 min)**
   - Verificar que todos tengan herramientas instaladas
   - Ejecutar setup_wifi_lab.sh

2. **Ejercicios (4 horas)**
   - Ejercicio 1: 45 min
   - Ejercicio 2: 40 min
   - Break: 15 min
   - Ejercicio 3: 50 min
   - Ejercicio 4: 60 min
   - Ejercicio 5: 55 min

3. **Q&A y Cierre (30 min)**

---

## 💡 Tips para el Profesor

1. **Máquina de respaldo**: Tener laptop con todo instalado por si algún alumno tiene problemas

2. **USB con PCAPs**: Por si la red es lenta, distribuir PCAPs en USB

3. **Proyector**: Mostrar análisis en vivo con Wireshark

4. **Grupos**: Trabajar en pares para discusión

5. **Énfasis defensivo**: Recordar siempre el enfoque de seguridad defensiva

---

## 📞 Soporte

**Problemas técnicos:**
- Revisar `validate_setup.sh` output
- Consultar INSTRUCTOR_GUIDE.md sección Troubleshooting
- Verificar versiones de herramientas

**Preguntas sobre ejercicios:**
- Ver INSTRUCTOR_GUIDE.md para respuestas
- CHEATSHEET.md para comandos

---

## ✅ Checklist Pre-Clase

Para el profesor, verificar:

- [ ] Wireshark instalado
- [ ] aircrack-ng instalado
- [ ] `bash setup_wifi_lab.sh` ejecutado exitosamente
- [ ] Al menos 3 PCAPs descargados
- [ ] `bash validate_setup.sh` sin errores críticos
- [ ] Ejercicio 1 probado y funcional
- [ ] Documentación revisada
- [ ] Proyector/pantalla configurado
- [ ] Alumnos notificados 1 semana antes

Para los alumnos, verificar:

- [ ] Herramientas instaladas (tshark, aircrack-ng)
- [ ] Repositorio clonado/descargado
- [ ] Setup ejecutado (`bash setup_wifi_lab.sh`)
- [ ] Validación OK (`bash validate_setup.sh`)
- [ ] Laptop con batería cargada
- [ ] EJERCICIOS.md leído

---

## 🎉 ¡Listo!

Si completaste el checklist, estás listo para impartir la clase.

**Comando final de verificación:**
```bash
bash validate_setup.sh && echo "✅ TODO LISTO PARA LA CLASE"
```

---

**Última actualización:** Octubre 2025
**Versión:** 1.0
**Autor:** UTN - Laboratorio Blockchain & Ciberseguridad
