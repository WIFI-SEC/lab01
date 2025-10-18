#!/usr/bin/env bash

# ======================================================
# Script: validate_setup.sh
# Descripción: Valida que el laboratorio WiFi esté correctamente configurado
# Compatibilidad: Linux, macOS, Windows (WSL2 / Git Bash)
# ======================================================

BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ERRORS=0
WARNINGS=0
SUCCESS=0

printf "${BOLD}${BLUE}"
cat << "EOF"
╔══════════════════════════════════════════════════════════╗
║     Validación de Laboratorio WiFi                      ║
╚══════════════════════════════════════════════════════════╝
EOF
printf "${NC}\n"

# ==========================================
# Función para verificar comandos
# ==========================================
check_command() {
    local cmd=$1
    local description=$2
    local required=$3  # "required" o "optional"

    if command -v "$cmd" >/dev/null 2>&1; then
        version=$("$cmd" --version 2>&1 | head -1)
        printf "${GREEN}[✓]${NC} $description: ${BOLD}instalado${NC}\n"
        printf "    Versión: $version\n"
        ((SUCCESS++))
        return 0
    else
        if [ "$required" = "required" ]; then
            printf "${RED}[✗]${NC} $description: ${BOLD}NO INSTALADO${NC} (requerido)\n"
            ((ERRORS++))
        else
            printf "${YELLOW}[!]${NC} $description: ${BOLD}NO INSTALADO${NC} (opcional)\n"
            ((WARNINGS++))
        fi
        return 1
    fi
}

# ==========================================
# Verificar herramientas requeridas
# ==========================================
printf "${BOLD}Verificando herramientas requeridas...${NC}\n"
echo ""

check_command "tshark" "Tshark (Wireshark CLI)" "required"
check_command "aircrack-ng" "Aircrack-ng" "required"
check_command "wget" "wget" "required"
check_command "sha256sum" "sha256sum" "required" || check_command "shasum" "shasum (alternativa a sha256sum)" "required"

echo ""
printf "${BOLD}Verificando herramientas opcionales...${NC}\n"
echo ""

check_command "wireshark" "Wireshark (GUI)" "optional"
check_command "hcxpcapngtool" "hcxtools (PMKID extraction)" "optional"
check_command "hashcat" "Hashcat (password recovery)" "optional"
check_command "tree" "tree (visualización de directorios)" "optional"
check_command "capinfos" "capinfos (PCAP info)" "optional"

echo ""

# ==========================================
# Verificar estructura de directorios
# ==========================================
printf "${BOLD}Verificando estructura de directorios...${NC}\n"
echo ""

check_directory() {
    local dir=$1
    local description=$2

    if [ -d "$dir" ]; then
        count=$(find "$dir" -type f 2>/dev/null | wc -l | tr -d ' ')
        printf "${GREEN}[✓]${NC} $description: ${BOLD}OK${NC} ($count archivos)\n"
        ((SUCCESS++))
        return 0
    else
        printf "${YELLOW}[!]${NC} $description: ${BOLD}NO EXISTE${NC}\n"
        printf "    Ejecutar: ./setup_wifi_lab.sh\n"
        ((WARNINGS++))
        return 1
    fi
}

if [ -d "wifi_lab" ]; then
    check_directory "wifi_lab/pcaps/wpa2" "Directorio WPA2 PCAPs"
    check_directory "wifi_lab/pcaps/wpa3" "Directorio WPA3 PCAPs"
    check_directory "wifi_lab/pcaps/wep" "Directorio WEP PCAPs"
    check_directory "wifi_lab/pcaps/attacks" "Directorio Attack PCAPs"
    check_directory "wifi_lab/pcaps/misc" "Directorio Misc PCAPs"
    check_directory "wifi_lab/outputs" "Directorio Outputs"
    check_directory "wifi_lab/reports" "Directorio Reports"

    # Verificar manifest
    echo ""
    if [ -f "wifi_lab/manifest.sha256" ]; then
        printf "${GREEN}[✓]${NC} Manifest de integridad: ${BOLD}OK${NC}\n"
        ((SUCCESS++))
    else
        printf "${YELLOW}[!]${NC} Manifest de integridad: ${BOLD}NO ENCONTRADO${NC}\n"
        ((WARNINGS++))
    fi
else
    printf "${YELLOW}[!]${NC} Directorio ${BOLD}wifi_lab${NC} no existe\n"
    printf "    Ejecutar primero: ./setup_wifi_lab.sh\n"
    ((WARNINGS++))
fi

echo ""

# ==========================================
# Verificar scripts de análisis
# ==========================================
printf "${BOLD}Verificando scripts de análisis...${NC}\n"
echo ""

check_script() {
    local script=$1
    local description=$2

    if [ -f "$script" ]; then
        if [ -x "$script" ]; then
            printf "${GREEN}[✓]${NC} $description: ${BOLD}OK${NC} (ejecutable)\n"
            ((SUCCESS++))
        else
            printf "${YELLOW}[!]${NC} $description: ${BOLD}OK pero no ejecutable${NC}\n"
            printf "    Ejecutar: chmod +x $script\n"
            ((WARNINGS++))
        fi
        return 0
    else
        printf "${RED}[✗]${NC} $description: ${BOLD}NO ENCONTRADO${NC}\n"
        ((ERRORS++))
        return 1
    fi
}

check_script "analysis_scripts/01_handshake_analysis.sh" "Ejercicio 1: Handshake Analysis"
check_script "analysis_scripts/02_pmkid_analysis.sh" "Ejercicio 2: PMKID Analysis"
check_script "analysis_scripts/03_deauth_detection.sh" "Ejercicio 3: Deauth Detection"
check_script "analysis_scripts/04_wpa3_analysis.sh" "Ejercicio 4: WPA3 Analysis"
check_script "analysis_scripts/05_traffic_analysis.sh" "Ejercicio 5: Traffic Analysis"

echo ""

# ==========================================
# Verificar PCAPs descargados
# ==========================================
if [ -d "wifi_lab/pcaps" ]; then
    printf "${BOLD}Verificando PCAPs descargados...${NC}\n"
    echo ""

    TOTAL_PCAPS=$(find wifi_lab/pcaps -type f \( -name "*.pcap" -o -name "*.pcapng" -o -name "*.cap" \) 2>/dev/null | wc -l | tr -d ' ')

    if [ "$TOTAL_PCAPS" -gt 0 ]; then
        printf "${GREEN}[✓]${NC} Total de PCAPs encontrados: ${BOLD}$TOTAL_PCAPS${NC}\n"
        ((SUCCESS++))

        echo ""
        echo "Desglose por categoría:"

        for category in wpa2 wpa3 wep attacks misc; do
            count=$(find "wifi_lab/pcaps/$category" -type f 2>/dev/null | wc -l | tr -d ' ')
            if [ "$count" -gt 0 ]; then
                printf "  ${BLUE}•${NC} $category: $count archivos\n"
            fi
        done

        # Verificar integridad con checksums
        echo ""
        if [ -f "wifi_lab/manifest.sha256" ]; then
            echo "Verificando integridad (checksums)..."

            cd wifi_lab

            if sha256sum -c manifest.sha256 >/dev/null 2>&1 || shasum -a 256 -c manifest.sha256 >/dev/null 2>&1; then
                printf "${GREEN}[✓]${NC} Integridad de PCAPs: ${BOLD}VERIFICADA${NC}\n"
                ((SUCCESS++))
            else
                printf "${YELLOW}[!]${NC} Integridad de PCAPs: ${BOLD}NO PUDO VERIFICARSE${NC}\n"
                printf "    Algunos archivos pueden haberse corrompido o modificado\n"
                ((WARNINGS++))
            fi

            cd ..
        fi
    else
        printf "${RED}[✗]${NC} No se encontraron PCAPs\n"
        printf "    Ejecutar: ./setup_wifi_lab.sh\n"
        ((ERRORS++))
    fi

    echo ""
fi

# ==========================================
# Verificar documentación
# ==========================================
printf "${BOLD}Verificando documentación...${NC}\n"
echo ""

check_file() {
    local file=$1
    local description=$2

    if [ -f "$file" ]; then
        size=$(wc -l < "$file" | tr -d ' ')
        printf "${GREEN}[✓]${NC} $description: ${BOLD}OK${NC} ($size líneas)\n"
        ((SUCCESS++))
        return 0
    else
        printf "${RED}[✗]${NC} $description: ${BOLD}NO ENCONTRADO${NC}\n"
        ((ERRORS++))
        return 1
    fi
}

check_file "README.md" "README principal"
check_file "EJERCICIOS.md" "Guía de ejercicios"
check_file "setup_wifi_lab.sh" "Script de setup"

echo ""

# ==========================================
# Verificar permisos de captura (opcional)
# ==========================================
printf "${BOLD}Verificando permisos de captura...${NC}\n"
echo ""

if [ "$(uname)" = "Darwin" ]; then
    # macOS
    if [ -e "/dev/bpf0" ]; then
        printf "${GREEN}[✓]${NC} BPF devices: ${BOLD}DISPONIBLES${NC}\n"
        ((SUCCESS++))
    else
        printf "${YELLOW}[!]${NC} BPF devices: ${BOLD}NO DISPONIBLES${NC}\n"
        printf "    Para capturar tráfico, instalar: brew install --cask wireshark\n"
        ((WARNINGS++))
    fi
elif [ "$(uname)" = "Linux" ]; then
    # Linux
    if groups | grep -q wireshark; then
        printf "${GREEN}[✓]${NC} Usuario en grupo wireshark: ${BOLD}SÍ${NC}\n"
        ((SUCCESS++))
    else
        printf "${YELLOW}[!]${NC} Usuario en grupo wireshark: ${BOLD}NO${NC}\n"
        printf "    Para capturar sin sudo: sudo usermod -aG wireshark \$USER\n"
        ((WARNINGS++))
    fi
fi

echo ""

# ==========================================
# Test básico de tshark
# ==========================================
if command -v tshark >/dev/null 2>&1 && [ "$TOTAL_PCAPS" -gt 0 ]; then
    printf "${BOLD}Ejecutando test básico de tshark...${NC}\n"
    echo ""

    TEST_PCAP=$(find wifi_lab/pcaps -type f \( -name "*.pcap" -o -name "*.pcapng" \) 2>/dev/null | head -1)

    if [ -n "$TEST_PCAP" ]; then
        echo "Analizando: $TEST_PCAP"

        PACKET_COUNT=$(tshark -r "$TEST_PCAP" 2>/dev/null | wc -l | tr -d ' ')

        if [ "$PACKET_COUNT" -gt 0 ]; then
            printf "${GREEN}[✓]${NC} tshark funciona correctamente: ${BOLD}$PACKET_COUNT paquetes leídos${NC}\n"
            ((SUCCESS++))
        else
            printf "${RED}[✗]${NC} tshark no pudo leer el PCAP\n"
            ((ERRORS++))
        fi
    fi

    echo ""
fi

# ==========================================
# Resumen final
# ==========================================
printf "${BOLD}╔══════════════════════════════════════════════════════════╗${NC}\n"
printf "${BOLD}║                    RESUMEN DE VALIDACIÓN                 ║${NC}\n"
printf "${BOLD}╚══════════════════════════════════════════════════════════╝${NC}\n"
echo ""

TOTAL=$((SUCCESS + WARNINGS + ERRORS))

printf "${GREEN}  ✓ Verificaciones exitosas:${NC} ${BOLD}$SUCCESS${NC}\n"
printf "${YELLOW}  ! Advertencias:${NC}             ${BOLD}$WARNINGS${NC}\n"
printf "${RED}  ✗ Errores:${NC}                  ${BOLD}$ERRORS${NC}\n"
echo ""

# ==========================================
# Recomendaciones
# ==========================================
if [ $ERRORS -gt 0 ] || [ $WARNINGS -gt 0 ]; then
    printf "${BOLD}Recomendaciones:${NC}\n"
    echo ""

    if [ $ERRORS -gt 0 ]; then
        printf "${RED}ERRORES CRÍTICOS:${NC}\n"

        if ! command -v tshark >/dev/null 2>&1; then
            echo "  1. Instalar Wireshark/tshark:"
            echo "     macOS:  brew install wireshark"
            echo "     Linux:  sudo apt install tshark"
            echo ""
        fi

        if ! command -v aircrack-ng >/dev/null 2>&1; then
            echo "  2. Instalar aircrack-ng:"
            echo "     macOS:  brew install aircrack-ng"
            echo "     Linux:  sudo apt install aircrack-ng"
            echo ""
        fi

        if [ ! -d "wifi_lab" ]; then
            echo "  3. Ejecutar setup para descargar PCAPs:"
            echo "     ./setup_wifi_lab.sh"
            echo ""
        fi
    fi

    if [ $WARNINGS -gt 0 ]; then
        printf "${YELLOW}MEJORAS SUGERIDAS:${NC}\n"

        if ! command -v wireshark >/dev/null 2>&1; then
            echo "  • Instalar Wireshark GUI para análisis visual"
            echo ""
        fi

        if ! command -v hcxpcapngtool >/dev/null 2>&1; then
            echo "  • Instalar hcxtools para ejercicios de PMKID:"
            echo "    macOS:  brew install hcxtools"
            echo "    Linux:  sudo apt install hcxtools"
            echo ""
        fi

        if [ -d "analysis_scripts" ]; then
            echo "  • Hacer scripts ejecutables:"
            echo "    chmod +x analysis_scripts/*.sh"
            echo ""
        fi
    fi
fi

# ==========================================
# Próximos pasos
# ==========================================
if [ $ERRORS -eq 0 ]; then
    echo ""
    printf "${GREEN}${BOLD}✓ Laboratorio correctamente configurado!${NC}\n"
    echo ""
    printf "${BOLD}Próximos pasos:${NC}\n"
    echo "  1. Revisar guía de ejercicios:  cat EJERCICIOS.md"
    echo "  2. Ejecutar primer ejercicio:   cd analysis_scripts && ./01_handshake_analysis.sh"
    echo "  3. Explorar PCAPs con Wireshark: wireshark wifi_lab/pcaps/wpa2/*.pcap"
    echo ""
else
    echo ""
    printf "${RED}${BOLD}✗ Configuración incompleta${NC}\n"
    echo ""
    echo "Resolver los errores críticos antes de comenzar los ejercicios."
    echo ""
fi

# ==========================================
# Exit code
# ==========================================
if [ $ERRORS -gt 0 ]; then
    exit 1
else
    exit 0
fi
