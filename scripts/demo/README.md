# 🎬 Scripts de Demostración - README

**Laboratorio WiFi Security - UTN**

---

## 📋 Scripts Disponibles

### ⚡ demo_rapida.sh - Demo de 5 Minutos

Demostración express del laboratorio, ideal para presentaciones cortas.

**Ejecutar:**
```bash
bash demo_rapida.sh
```

**Muestra:**
1. ✅ 9 PCAPs disponibles (840KB)
2. ✅ WPA2 Handshake (SSID + 4 EAPOL frames)
3. ✅ ARP Spoofing detection
4. ✅ HTTP Traffic analysis
5. ✅ 10 ejercicios disponibles

**Duración:** ~5 minutos
**Ideal para:** Introducción rápida, overview del laboratorio

---

### 🎯 demo_laboratorio.sh - Demo Completa

Demostración detallada con análisis paso a paso de todos los componentes.

**Ejecutar:**
```bash
bash demo_laboratorio.sh
```

**Modos:**
- **Interactivo** (recomendado): Pausas entre secciones para explicar
- **Rápido**: Ejecución continua sin pausas

**Contiene:**
1. Verificación del laboratorio (herramientas, PCAPs)
2. Análisis WPA2 4-Way Handshake completo
3. Análisis DHCP (proceso DORA)
4. Detección de ARP Spoofing (MitM)
5. Análisis de tráfico HTTP
6. Extracción de componentes crypto (ANonce, SNonce, MIC)
7. Generación de reporte automático

**Duración:** ~15-20 minutos (interactivo) o ~10 minutos (rápido)
**Ideal para:** Primera clase, capacitación completa, workshop

**Genera:** Reporte en `wifi_lab/reports/demo_YYYYMMDD_HHMMSS.txt`

---

## 🎓 Uso en Clase

### Escenario 1: Primera Clase del Módulo

```
📊 Timing: 2 horas

Minuto 0-10:    Introducción teórica (slides)
Minuto 10-30:   🎬 bash demo_laboratorio.sh (interactivo)
Minuto 30-45:   Explicación de herramientas
Minuto 45-90:   Ejercicio 1 guiado
Minuto 90-110:  Práctica individual
Minuto 110-120: Q&A
```

### Escenario 2: Presentación Ejecutiva

```
📊 Timing: 10 minutos

Minuto 0-2:   Introducción
Minuto 2-7:   🎬 bash demo_rapida.sh
Minuto 7-10:  Preguntas
```

---

## 🖥️ Preparación Pre-Demo

### 1. Verificar Instalación

```bash
bash validate_setup.sh
```

**Debe mostrar:**
- ✅ tshark instalado
- ✅ aircrack-ng instalado
- ✅ 9 PCAPs descargados

### 2. Probar Scripts

```bash
# Test demo rápida (5 min)
bash demo_rapida.sh

# Test demo completa (15 min)
bash demo_laboratorio.sh
```

### 3. Ajustar Terminal

```bash
# Aumentar tamaño de fuente para proyector
# macOS: Cmd + "+"
# Linux: Ctrl + Shift + "+"

# Pantalla completa
# macOS: Cmd + Ctrl + F
# Linux: F11
```

### 4. Recursos Adicionales

```bash
# Tener Wireshark abierto en background
wireshark wifi_lab/pcaps/wpa2/wpa_induction.pcap &

# Tener ejercicios abiertos
open EJERCICIOS_PROGRESIVOS.md  # macOS
xdg-open EJERCICIOS_PROGRESIVOS.md  # Linux
```

---

## 📊 Outputs Esperados

### Demo Rápida

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                  DEMO RÁPIDA: LABORATORIO WIFI SECURITY                      ║
║                     Universidad Tecnológica Nacional                         ║
╚══════════════════════════════════════════════════════════════════════════════╝

⏱️  Demo de 5 minutos - Highlights del laboratorio

▶ 1/5 PCAPs disponibles:
  9 archivos (840K)

▶ 2/5 WPA2 Handshake:
  SSID: Coherer
  EAPOL frames: 4 → Handshake completo ✓

▶ 3/5 ARP Spoofing Detection:
  ARP packets: 622
  ARP replies: 0 ← Storm detectado!

▶ 4/5 HTTP Traffic:
  HTTP requests: 19
  ⚠️ Tráfico en texto claro (inseguro)

▶ 5/5 Ejercicios disponibles:
  📘 Básicos (3): 30 min c/u
  📙 Intermedios (3): 45 min c/u
  📕 Avanzados (3): 60 min c/u
  🎯 Integrador (1): 90-120 min

  Total: 10 ejercicios progresivos (~8h material)
```

### Demo Completa

**Muestra 7 secciones detalladas + genera reporte automático**

Ver ejemplo completo en `GUIA_DEMO.md`

---

## 💡 Tips para Presentación

### ✅ DO (Hacer):

- Ejecutar en **modo interactivo** la primera vez
- **Pausar y explicar** resultados importantes
- Destacar **alertas de seguridad** (ARP spoofing, HTTP)
- Mostrar el **reporte generado** al final
- Conectar con **teoría** vista previamente
- Mencionar **aspecto ético** (análisis defensivo)

### ❌ DON'T (No hacer):

- Ejecutar modo rápido sin preparación
- Saltear explicaciones clave
- Olvidar mencionar la ética
- Ir demasiado técnico sin contexto
- Ignorar preguntas durante la demo

### 🎯 Puntos Clave a Destacar:

1. **4 EAPOL frames = Handshake completo** ⭐
   > "Esto es lo que buscan los atacantes para crackear WiFi"

2. **ARP Storm con 500+ replies** ⚠️
   > "Indicador claro de ataque Man-in-the-Middle"

3. **HTTP sin HTTPS** 🔓
   > "Todo visible: contraseñas, cookies, datos personales"

4. **Nonces (ANonce, SNonce)** 🔑
   > "Componentes criptográficos usados en el cracking"

---

## 🔧 Troubleshooting

### Problema: Script no encuentra PCAPs

**Solución:**
```bash
bash setup_wifi_lab.sh
bash download_additional_pcaps.sh
```

### Problema: tshark no instalado

**Solución:**
```bash
# macOS
brew install wireshark

# Linux
sudo apt install tshark
```

### Problema: Permisos denegados

**Solución:**
```bash
chmod +x demo_laboratorio.sh demo_rapida.sh
```

### Problema: Output muy rápido

**Solución:**
- Elegir modo **interactivo** (opción 1)
- O pausar con `Ctrl+S` / reanudar con `Ctrl+Q`

---

## 📝 Checklist Pre-Presentación

### 1 Día Antes
- [ ] `bash validate_setup.sh` → Todo OK
- [ ] Probar `bash demo_rapida.sh`
- [ ] Probar `bash demo_laboratorio.sh`
- [ ] Verificar 9 PCAPs presentes
- [ ] Preparar slides teóricos

### 1 Hora Antes
- [ ] Terminal en pantalla completa
- [ ] Aumentar tamaño de fuente
- [ ] Wireshark abierto en background
- [ ] EJERCICIOS_PROGRESIVOS.md abierto
- [ ] Verificar proyector

### Durante Presentación
- [ ] Modo interactivo (con pausas)
- [ ] Explicar cada resultado
- [ ] Mostrar Wireshark GUI en paralelo
- [ ] Generar y mostrar reporte
- [ ] Compartir repositorio con alumnos

---

## 📚 Documentación Relacionada

- **GUIA_DEMO.md** - Guía completa de presentación
- **EJERCICIOS_PROGRESIVOS.md** - 10 ejercicios detallados
- **REFERENCIA_RAPIDA_CLASE.md** - Referencia de 1 página
- **INSTRUCTOR_GUIDE.md** - Guía del profesor

---

## 🎥 Grabación (Opcional)

### Con asciinema

```bash
# Instalar
brew install asciinema  # macOS
sudo apt install asciinema  # Linux

# Grabar
asciinema rec demo_wifi_security.cast
bash demo_laboratorio.sh
# Ctrl+D para terminar

# Reproducir
asciinema play demo_wifi_security.cast

# Subir a asciinema.org
asciinema upload demo_wifi_security.cast
```

---

## ✅ Resultados Esperados

Después de la demo, los alumnos deben entender:

1. **Qué es el laboratorio**
   - Análisis de PCAPs reales
   - Herramientas profesionales
   - Enfoque defensivo

2. **Qué aprenderán**
   - Analizar handshakes WPA2
   - Detectar ataques (ARP, MitM, deauth)
   - Analizar tráfico
   - Generar reportes

3. **Cómo empezar**
   - Instalar herramientas
   - Descargar PCAPs
   - Seguir ejercicios progresivos
   - Practicar comandos

---

## 🎯 Métricas de Éxito

Una demo exitosa logra:

- ✅ Captar atención (visual, interactivo)
- ✅ Mostrar capacidades del lab
- ✅ Motivar a practicar
- ✅ Dejar claro el valor educativo
- ✅ Generar preguntas

---

**Universidad Tecnológica Nacional**
**Laboratorio de Blockchain & Ciberseguridad**

*Octubre 2025*

🎓 ¡Éxito con tu presentación! 🔐🚀
