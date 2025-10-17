# 🎬 Guía de Demostración del Laboratorio WiFi Security

**Para presentar en clase**

---

## 📋 Scripts de Demostración Disponibles

### 1. **demo_rapida.sh** - Demo Rápida (5 minutos) ⚡

**Uso:**
```bash
bash demo_rapida.sh
```

**Contenido:**
- ✅ PCAPs disponibles (count)
- ✅ WPA2 Handshake verificado
- ✅ ARP Spoofing detection
- ✅ HTTP Traffic analysis
- ✅ Ejercicios disponibles

**Ideal para:**
- Introducción al laboratorio
- Presentación inicial de clase
- Overview rápido del material

**Duración:** ~5 minutos

---

### 2. **demo_laboratorio.sh** - Demo Completa (15-20 minutos) 🎯

**Uso:**
```bash
bash demo_laboratorio.sh
```

**Dos modos disponibles:**
1. **Interactivo** (recomendado): Con pausas entre secciones
2. **Rápido**: Sin pausas, ejecución continua

**Contenido detallado:**

#### Sección 1: Verificación del Laboratorio
- Herramientas instaladas (tshark, aircrack-ng)
- Estructura de directorios
- Lista de 9 PCAPs disponibles (840KB)

#### Sección 2: Análisis WPA2 4-Way Handshake
- Extracción de SSID
- Identificación de 4 frames EAPOL
- Desglose de mensajes (1/4, 2/4, 3/4, 4/4)
- Verificación con aircrack-ng

#### Sección 3: Análisis DHCP
- Proceso DORA (Discover, Offer, Request, Ack)
- Identificación de tipos de mensaje

#### Sección 4: Detección de ARP Spoofing
- Conteo de paquetes ARP
- Análisis de requests vs replies
- Detección de IPs con múltiples MACs
- Alertas de ataque MitM

#### Sección 5: Análisis HTTP
- HTTP requests sin cifrar
- Hosts contactados
- Detección de captive portals (redirects)
- Advertencias de seguridad

#### Sección 6: Extracción Crypto
- ANonce del AP
- SNonce del cliente
- MIC (Message Integrity Code)

#### Sección 7: Generación de Reporte
- Reporte completo en texto
- Guardado en wifi_lab/reports/

**Ideal para:**
- Demostración completa del laboratorio
- Primera clase del módulo
- Capacitación de profesores

**Duración:** ~15-20 minutos (interactivo) o ~10 minutos (rápido)

---

## 🎓 Cómo Usar en Clase

### Escenario 1: Primera Clase (Introducción)

**Timing:** Clase de 2 horas

```
Minuto 0-10:   Teoría WiFi (slides)
Minuto 10-25:  🎬 bash demo_laboratorio.sh (modo interactivo)
Minuto 25-40:  Explicación de herramientas (tshark, wireshark, aircrack-ng)
Minuto 40-90:  Ejercicio 1 guiado (Explorando PCAPs)
Minuto 90-110: Práctica individual
Minuto 110-120: Q&A y resumen
```

### Escenario 2: Presentación Ejecutiva

**Timing:** 10 minutos

```
Minuto 0-2:    Introducción al laboratorio
Minuto 2-7:    🎬 bash demo_rapida.sh
Minuto 7-10:   Q&A rápida
```

### Escenario 3: Workshop de Profesores

**Timing:** 30 minutos

```
Minuto 0-5:    Overview del proyecto
Minuto 5-25:   🎬 bash demo_laboratorio.sh (modo interactivo)
Minuto 25-30:  Revisión de EJERCICIOS_PROGRESIVOS.md
```

---

## 💡 Tips para la Demostración

### Preparación Pre-Demo

```bash
# 1. Verificar que todo esté instalado
bash validate_setup.sh

# 2. Hacer una prueba del script
bash demo_rapida.sh

# 3. Tener Wireshark abierto en background para mostrar GUI
wireshark wifi_lab/pcaps/wpa2/wpa_induction.pcap &
```

### Durante la Demo

✅ **DO:**
- Explicar cada resultado mientras aparece
- Pausar en alertas importantes (ARP spoofing, HTTP inseguro)
- Mostrar el reporte generado al final
- Conectar con teoría vista previamente

❌ **DON'T:**
- Ejecutar en modo rápido la primera vez (muy confuso)
- Saltear explicaciones de resultados clave
- Olvidar mencionar el aspecto ético (análisis defensivo)

### Puntos Clave a Destacar

1. **4 EAPOL frames = Handshake completo** ⭐
   - "Esto es lo que buscan los atacantes para crackear WiFi"

2. **ARP Storm con 500+ replies** ⚠️
   - "Indicador claro de ataque Man-in-the-Middle"

3. **HTTP sin HTTPS** 🔓
   - "Todo visible en texto claro: contraseñas, cookies, datos"

4. **Nonces (ANonce, SNonce)** 🔑
   - "Componentes criptográficos usados en el cracking"

---

## 📊 Outputs Esperados

### Demo Rápida (demo_rapida.sh)

```
═══════════════════════════════════════════════════════════════════════════════
              DEMO RÁPIDA: LABORATORIO WIFI SECURITY
                   Universidad Tecnológica Nacional
═══════════════════════════════════════════════════════════════════════════════

⏱️  Demo de 5 minutos - Highlights del laboratorio

▶ 1/5 PCAPs disponibles:
  9 archivos (840K)

▶ 2/5 WPA2 Handshake:
  SSID: Coherer
  EAPOL frames: 4 → Handshake completo ✓

▶ 3/5 ARP Spoofing Detection:
  ARP packets: 1000
  ARP replies: 500 ← Storm detectado!

▶ 4/5 HTTP Traffic:
  HTTP requests: 158
  ⚠️ Tráfico en texto claro (inseguro)

▶ 5/5 Ejercicios disponibles:
  📘 Básicos (3): 30 min c/u
  📙 Intermedios (3): 45 min c/u
  📕 Avanzados (3): 60 min c/u
  🎯 Integrador (1): 90-120 min

  Total: 10 ejercicios progresivos (~8h material)

═══════════════════════════════════════════════════════════════
✅ Demo completa
═══════════════════════════════════════════════════════════════
```

### Demo Completa (demo_laboratorio.sh)

Genera un reporte completo en:
```
wifi_lab/reports/demo_YYYYMMDD_HHMMSS.txt
```

Contiene:
- Resumen del laboratorio
- Análisis de cada PCAP
- Detección de ataques
- Recomendaciones de seguridad
- Lista completa de ejercicios

---

## 🎥 Grabación de la Demo (Opcional)

### Grabar Terminal con asciinema

```bash
# Instalar asciinema
brew install asciinema  # macOS
# o
sudo apt install asciinema  # Linux

# Grabar demo
asciinema rec demo_wifi_lab.cast

# Ejecutar demo
bash demo_laboratorio.sh

# Ctrl+D para terminar grabación

# Reproducir
asciinema play demo_wifi_lab.cast
```

### Captura de Pantalla para Slides

```bash
# Ejecutar y capturar screenshots en puntos clave:
# - Banner inicial
# - Análisis de handshake (4 EAPOL frames)
# - Alerta de ARP spoofing
# - Advertencia de HTTP inseguro
# - Reporte final generado
```

---

## 📝 Checklist Pre-Presentación

### 1 Día Antes

- [ ] Ejecutar `bash validate_setup.sh`
- [ ] Probar `bash demo_rapida.sh`
- [ ] Probar `bash demo_laboratorio.sh` (modo interactivo)
- [ ] Verificar que todos los 9 PCAPs estén presentes
- [ ] Preparar slides introductorios (teoría WiFi)

### 1 Hora Antes

- [ ] Abrir terminal en pantalla completa
- [ ] Aumentar tamaño de fuente del terminal (para proyector)
- [ ] Tener Wireshark abierto en background
- [ ] Tener EJERCICIOS_PROGRESIVOS.md abierto en editor
- [ ] Verificar conexión a proyector

### Durante Presentación

- [ ] Ejecutar demo con pausas (modo interactivo)
- [ ] Explicar cada resultado importante
- [ ] Mostrar GUI de Wireshark en paralelo
- [ ] Generar reporte y mostrarlo
- [ ] Compartir link al repositorio con alumnos

---

## 🔧 Troubleshooting

### Si algo falla durante la demo:

**Problema:** Script no encuentra PCAPs
```bash
# Solución rápida
bash setup_wifi_lab.sh
bash download_additional_pcaps.sh
```

**Problema:** tshark no instalado
```bash
# macOS
brew install wireshark

# Linux
sudo apt install tshark
```

**Problema:** Permisos denegados
```bash
chmod +x demo_laboratorio.sh demo_rapida.sh
```

**Problema:** Output muy rápido
```bash
# Ejecutar en modo interactivo (opción 1)
# O pausar manualmente con Ctrl+S / Ctrl+Q
```

---

## 📚 Recursos Complementarios para la Presentación

### Para Mostrar Después de la Demo:

1. **EJERCICIOS_PROGRESIVOS.md**
   - Abrir en editor y mostrar estructura
   - Destacar progresión Básico → Avanzado

2. **Wireshark GUI**
   - Abrir `wpa_induction.pcap`
   - Filtrar `eapol` para mostrar los 4 frames visualmente
   - Mostrar cómo se ve el handshake en GUI

3. **Comandos en Vivo**
   ```bash
   # Permitir que alumnos vean comandos reales
   tshark -r wifi_lab/pcaps/wpa2/wpa_induction.pcap -Y "eapol"
   aircrack-ng wifi_lab/pcaps/wpa2/wpa_induction.pcap
   ```

---

## ✅ Resultados Esperados de la Demo

Después de ejecutar la demo, los alumnos deben entender:

1. **Qué es el laboratorio**
   - Análisis de PCAPs reales
   - Herramientas profesionales (tshark, aircrack-ng)
   - Enfoque defensivo y ético

2. **Qué aprenderán**
   - Analizar handshakes WPA2
   - Detectar ataques (ARP spoofing, deauth, MitM)
   - Analizar tráfico de red
   - Generar reportes de seguridad

3. **Cómo está estructurado**
   - 10 ejercicios progresivos
   - 9 PCAPs con escenarios realistas
   - Documentación completa
   - Comandos paso a paso

4. **Qué necesitan hacer**
   - Instalar herramientas (`install_tools.sh`)
   - Descargar PCAPs (`setup_wifi_lab.sh`)
   - Seguir ejercicios progresivos
   - Practicar y generar reportes

---

## 🎯 Métricas de Éxito

Una demo exitosa debe lograr:

- ✅ Captar la atención (visual, interactivo)
- ✅ Mostrar capacidades del laboratorio
- ✅ Motivar a los alumnos a practicar
- ✅ Dejar claro el valor educativo
- ✅ Generar preguntas y discusión

---

**Universidad Tecnológica Nacional**
**Laboratorio de Blockchain & Ciberseguridad**

*Última actualización: Octubre 2025*

¡Éxito con tu presentación! 🎓🔐🚀
