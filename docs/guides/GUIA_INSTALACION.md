# 🛠️ Guía de Instalación - Laboratorio WiFi Security

## Instalación Automática (Recomendado)

### Paso 1: Instalar Herramientas

El script `install_tools.sh` detecta automáticamente tu sistema operativo e instala todo lo necesario.

```bash
bash install_tools.sh
```

**Sistemas soportados:**
- ✅ macOS (con Homebrew)
- ✅ Linux (Ubuntu/Debian)
- ✅ Linux (Arch/Manjaro)
- ✅ Linux (Fedora/RHEL/CentOS)
- ✅ Windows (con WSL2)

---

## Instalación Manual por Sistema Operativo

### macOS

```bash
# Instalar Homebrew (si no está instalado)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Herramientas requeridas
brew install wireshark aircrack-ng wget

# Herramientas opcionales (recomendadas)
brew install hcxtools hashcat
```

**Verificar:**
```bash
tshark --version
aircrack-ng --version
```

---

### Ubuntu / Debian / Linux Mint

```bash
# Actualizar repositorios
sudo apt update

# Herramientas requeridas
sudo apt install -y wireshark tshark aircrack-ng wget curl

# Herramientas opcionales
sudo apt install -y hcxtools hashcat

# Agregar usuario al grupo wireshark
sudo usermod -aG wireshark $USER

# IMPORTANTE: Hacer logout y login para aplicar cambios
```

**Verificar:**
```bash
tshark --version
aircrack-ng --version
```

---

### Arch Linux / Manjaro

```bash
# Actualizar sistema
sudo pacman -Sy

# Herramientas requeridas
sudo pacman -S wireshark-qt wireshark-cli aircrack-ng wget curl

# Herramientas opcionales
sudo pacman -S hcxtools hashcat

# Permisos
sudo usermod -aG wireshark $USER
```

---

### Fedora / RHEL / CentOS

```bash
# Herramientas requeridas
sudo dnf install -y wireshark aircrack-ng wget curl

# Herramientas opcionales
sudo dnf install -y hashcat

# Para hcxtools, compilar desde fuente:
git clone https://github.com/ZerBea/hcxtools.git
cd hcxtools
make
sudo make install
```

---

### Windows (con WSL2)

**Paso 1: Instalar WSL2**

Abrir PowerShell como administrador:

```powershell
wsl --install
```

Reiniciar la computadora.

**Paso 2: Instalar Ubuntu en WSL2**

```powershell
wsl --install -d Ubuntu
```

**Paso 3: Dentro de WSL2, instalar herramientas**

```bash
sudo apt update
sudo apt install -y wireshark tshark aircrack-ng wget curl
```

**Alternativa: Instalación Nativa en Windows**

1. **Wireshark**: Descargar desde https://www.wireshark.org/download.html
2. **Aircrack-ng**: Descargar desde https://www.aircrack-ng.org/downloads.html
3. **Git Bash**: Para ejecutar scripts bash

---

## Setup del Laboratorio

Una vez instaladas las herramientas:

```bash
# 1. Clonar o descargar el repositorio
cd ~/Documents
git clone [REPOSITORY_URL] wifisec
cd wifisec

# 2. Ejecutar setup (descarga PCAPs automáticamente)
bash setup_wifi_lab.sh

# 3. Validar instalación
bash validate_setup.sh
```

---

## Resolución de Problemas

### "Permission denied" al ejecutar scripts

```bash
chmod +x *.sh
chmod +x analysis_scripts/*.sh
```

### "tshark: Couldn't run /usr/bin/dumpcap in child process"

**macOS:**
```bash
brew install --cask wireshark
# Instala ChmodBPF automáticamente
```

**Linux:**
```bash
sudo usermod -aG wireshark $USER
# Logout y login nuevamente
```

### Wireshark no muestra interfaces de red

**Linux:**
```bash
sudo dpkg-reconfigure wireshark-common
# Seleccionar "Yes" cuando pregunte si usuarios no-root pueden capturar
sudo usermod -aG wireshark $USER
```

Luego hacer logout/login.

### "curl: command not found"

**Debian/Ubuntu:**
```bash
sudo apt install curl
```

**macOS:**
```bash
brew install curl
```

### PCAPs no se descargan

1. Verificar conexión a internet
2. Algunas URLs pueden estar temporalmente caídas
3. El script intenta múltiples fuentes automáticamente
4. Al menos deben descargarse 5-6 PCAPs

Si persiste el problema:
```bash
# Reintentar
rm -rf wifi_lab
bash setup_wifi_lab.sh
```

---

## Verificación de Instalación

Ejecuta el script de validación:

```bash
bash validate_setup.sh
```

**Deberías ver:**
- ✅ tshark: instalado
- ✅ aircrack-ng: instalado
- ✅ wget/curl: instalado
- ✅ Directorio wifi_lab creado
- ✅ Al menos 5-6 PCAPs descargados

---

## Herramientas Requeridas vs Opcionales

### ✅ REQUERIDAS (Esenciales)

| Herramienta | Uso | Instalación |
|-------------|-----|-------------|
| **tshark** | Análisis de PCAPs en CLI | `brew install wireshark` (macOS)<br>`apt install tshark` (Linux) |
| **aircrack-ng** | Análisis WiFi, validación handshakes | `brew install aircrack-ng` (macOS)<br>`apt install aircrack-ng` (Linux) |
| **wget/curl** | Descarga de PCAPs | Generalmente preinstalado |

### ⚠️ OPCIONALES (Recomendadas)

| Herramienta | Uso | Instalación |
|-------------|-----|-------------|
| **Wireshark GUI** | Análisis visual | `brew install wireshark` (macOS)<br>`apt install wireshark` (Linux) |
| **hcxtools** | Extracción de PMKID | `brew install hcxtools` (macOS)<br>`apt install hcxtools` (Linux) |
| **hashcat** | Demostración de cracking | `brew install hashcat` (macOS)<br>`apt install hashcat` (Linux) |

---

## Instalación para Clase (Profesor)

### Una Semana Antes

Enviar a los alumnos:

```
Asunto: Preparación para Laboratorio WiFi Security

Estimados estudiantes,

Para el laboratorio del [FECHA], necesitan:

1. Instalar herramientas:
   - macOS: brew install wireshark aircrack-ng
   - Linux: sudo apt install wireshark tshark aircrack-ng

2. Verificar instalación:
   tshark --version
   aircrack-ng --version

3. Clonar repositorio:
   git clone [URL]
   cd wifisec

4. Ejecutar setup:
   bash setup_wifi_lab.sh

5. Validar:
   bash validate_setup.sh

Cualquier problema, consultar en horario de oficina.

Saludos,
[Profesor]
```

### Día de la Clase

1. **Primeros 15 minutos**: Verificar que todos tengan herramientas instaladas
2. **Alternativas**:
   - Máquina virtual pre-configurada (Kali Linux)
   - Laptop de respaldo con todo instalado
   - USB con PCAPs pre-descargados

---

## Desinstalación

Si necesitas eliminar las herramientas:

### macOS

```bash
brew uninstall wireshark aircrack-ng hcxtools hashcat
```

### Ubuntu/Debian

```bash
sudo apt remove wireshark tshark aircrack-ng hcxtools hashcat
sudo apt autoremove
```

### Arch Linux

```bash
sudo pacman -R wireshark-qt wireshark-cli aircrack-ng hcxtools hashcat
```

### Eliminar archivos del laboratorio

```bash
rm -rf wifi_lab
```

---

## Próximos Pasos

Una vez instalado todo:

1. **Leer**: `INICIO_RAPIDO.md` - Setup rápido
2. **Revisar**: `EJERCICIOS.md` - Guía de ejercicios
3. **Ejecutar**: `bash analysis_scripts/01_handshake_analysis.sh`

---

## Soporte

**Problemas con instalación:**
- Revisar esta guía
- Ejecutar `bash validate_setup.sh` para diagnóstico
- Revisar sección de troubleshooting

**Durante la clase:**
- Consultar al profesor
- Revisar `INSTRUCTOR_GUIDE.md`

---

**Última actualización:** Octubre 2025

¡Disfruta el laboratorio! 🔐
