#!/bin/bash

# ======================================================
# Script: validate_setup.sh
# Descripción: Valida que el laboratorio WiFi esté correctamente configurado
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

echo -e "${BOLD}${BLUE}"
cat << "EOF"
╔══════════════════════════════════════════════════════════╗
║     Validación de Laboratorio WiFi                      ║
╚══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# ==========================================
# Función para verificar comandos
# ==========================================
check_command() {
    local cmd=$1
    local description=$2
    local required=$3  # "required" o "optional"

    if command -v "$cmd" &> /dev/null; then
        version=$("$cmd" --version 2>&1 | head -1)
        echo -e "${GREEN}[✓]${NC} $description: ${BOLD}instalado${NC}"
        echo -e "    Versión: $version"
        ((SUCCESS++))
        return 0
    else
        if [ "$required" = "required" ]; then
            echo -e "${RED}[✗]${NC} $description: ${BOLD}NO INSTALADO${NC} (requerido)"
            ((ERRORS++))
        else
            echo -e "${YELLOW}[!]${NC} $description: ${BOLD}NO INSTALADO${NC} (opcional)"
            ((WARNINGS++))
        fi
        return 1
    fi
}

# ==========================================
# Verificar herramientas requeridas
# ==========================================
echo -e "${BOLD}Verificando herramientas requeridas...${NC}"
echo ""

check_command "tshark" "Tshark (Wireshark CLI)" "required"
check_command "aircrack-ng" "Aircrack-ng" "required"
check_command "wget" "wget" "required"
check_command "sha256sum" "sha256sum" "required" || check_command "shasum" "shasum (alternativa a sha256sum)" "required"

echo ""
echo -e "${BOLD}Verificando herramientas opcionales...${NC}"
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
echo -e "${BOLD}Verificando estructura de directorios...${NC}"
echo ""

check_directory() {
    local dir=$1
    local description=$2

    if [ -d "$dir" ]; then
        count=$(find "$dir" -type f 2>/dev/null | wc -l | tr -d ' ')
        echo -e "${GREEN}[✓]${NC} $description: ${BOLD}OK${NC} ($count archivos)"
        ((SUCCESS++))
        return 0
    else
        echo -e "${YELLOW}[!]${NC} $description: ${BOLD}NO EXISTE${NC}"
        echo -e "    Ejecutar: ./setup_wifi_lab.sh"
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
        echo -e "${GREEN}[✓]${NC} Manifest de integridad: ${BOLD}OK${NC}"
        ((SUCCESS++))
    else
        echo -e "${YELLOW}[!]${NC} Manifest de integridad: ${BOLD}NO ENCONTRADO${NC}"
        ((WARNINGS++))
    fi
else
    echo -e "${YELLOW}[!]${NC} Directorio ${BOLD}wifi_lab${NC} no existe"
    echo -e "    Ejecutar primero: ./setup_wifi_lab.sh"
    ((WARNINGS++))
fi

echo ""

# ==========================================
# Verificar scripts de análisis
# ==========================================
echo -e "${BOLD}Verificando scripts de análisis...${NC}"
echo ""

check_script() {
    local script=$1
    local description=$2

    if [ -f "$script" ]; then
        if [ -x "$script" ]; then
            echo -e "${GREEN}[✓]${NC} $description: ${BOLD}OK${NC} (ejecutable)"
            ((SUCCESS++))
        else
            echo -e "${YELLOW}[!]${NC} $description: ${BOLD}OK pero no ejecutable${NC}"
            echo -e "    Ejecutar: chmod +x $script"
            ((WARNINGS++))
        fi
        return 0
    else
        echo -e "${RED}[✗]${NC} $description: ${BOLD}NO ENCONTRADO${NC}"
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
    echo -e "${BOLD}Verificando PCAPs descargados...${NC}"
    echo ""

    TOTAL_PCAPS=$(find wifi_lab/pcaps -type f \( -name "*.pcap" -o -name "*.pcapng" -o -name "*.cap" \) 2>/dev/null | wc -l | tr -d ' ')

    if [ "$TOTAL_PCAPS" -gt 0 ]; then
        echo -e "${GREEN}[✓]${NC} Total de PCAPs encontrados: ${BOLD}$TOTAL_PCAPS${NC}"
        ((SUCCESS++))

        echo ""
        echo "Desglose por categoría:"

        for category in wpa2 wpa3 wep attacks misc; do
            count=$(find "wifi_lab/pcaps/$category" -type f 2>/dev/null | wc -l | tr -d ' ')
            if [ "$count" -gt 0 ]; then
                echo -e "  ${BLUE}•${NC} $category: $count archivos"
            fi
        done

        # Verificar integridad con checksums
        echo ""
        if [ -f "wifi_lab/manifest.sha256" ]; then
            echo "Verificando integridad (checksums)..."

            cd wifi_lab

            if sha256sum -c manifest.sha256 &>/dev/null || shasum -a 256 -c manifest.sha256 &>/dev/null; then
                echo -e "${GREEN}[✓]${NC} Integridad de PCAPs: ${BOLD}VERIFICADA${NC}"
                ((SUCCESS++))
            else
                echo -e "${YELLOW}[!]${NC} Integridad de PCAPs: ${BOLD}NO PUDO VERIFICARSE${NC}"
                echo -e "    Algunos archivos pueden haberse corrompido o modificado"
                ((WARNINGS++))
            fi

            cd ..
        fi
    else
        echo -e "${RED}[✗]${NC} No se encontraron PCAPs"
        echo -e "    Ejecutar: ./setup_wifi_lab.sh"
        ((ERRORS++))
    fi

    echo ""
fi

# ==========================================
# Verificar documentación
# ==========================================
echo -e "${BOLD}Verificando documentación...${NC}"
echo ""

check_file() {
    local file=$1
    local description=$2

    if [ -f "$file" ]; then
        size=$(wc -l < "$file" | tr -d ' ')
        echo -e "${GREEN}[✓]${NC} $description: ${BOLD}OK${NC} ($size líneas)"
        ((SUCCESS++))
        return 0
    else
        echo -e "${RED}[✗]${NC} $description: ${BOLD}NO ENCONTRADO${NC}"
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
echo -e "${BOLD}Verificando permisos de captura...${NC}"
echo ""

if [ "$(uname)" = "Darwin" ]; then
    # macOS
    if [ -e "/dev/bpf0" ]; then
        echo -e "${GREEN}[✓]${NC} BPF devices: ${BOLD}DISPONIBLES${NC}"
        ((SUCCESS++))
    else
        echo -e "${YELLOW}[!]${NC} BPF devices: ${BOLD}NO DISPONIBLES${NC}"
        echo -e "    Para capturar tráfico, instalar: brew install --cask wireshark"
        ((WARNINGS++))
    fi
elif [ "$(uname)" = "Linux" ]; then
    # Linux
    if groups | grep -q wireshark; then
        echo -e "${GREEN}[✓]${NC} Usuario en grupo wireshark: ${BOLD}SÍ${NC}"
        ((SUCCESS++))
    else
        echo -e "${YELLOW}[!]${NC} Usuario en grupo wireshark: ${BOLD}NO${NC}"
        echo -e "    Para capturar sin sudo: sudo usermod -aG wireshark \$USER"
        ((WARNINGS++))
    fi
fi

echo ""

# ==========================================
# Test básico de tshark
# ==========================================
if command -v tshark &> /dev/null && [ "$TOTAL_PCAPS" -gt 0 ]; then
    echo -e "${BOLD}Ejecutando test básico de tshark...${NC}"
    echo ""

    TEST_PCAP=$(find wifi_lab/pcaps -type f \( -name "*.pcap" -o -name "*.pcapng" \) 2>/dev/null | head -1)

    if [ -n "$TEST_PCAP" ]; then
        echo "Analizando: $TEST_PCAP"

        PACKET_COUNT=$(tshark -r "$TEST_PCAP" 2>/dev/null | wc -l | tr -d ' ')

        if [ "$PACKET_COUNT" -gt 0 ]; then
            echo -e "${GREEN}[✓]${NC} tshark funciona correctamente: ${BOLD}$PACKET_COUNT paquetes leídos${NC}"
            ((SUCCESS++))
        else
            echo -e "${RED}[✗]${NC} tshark no pudo leer el PCAP"
            ((ERRORS++))
        fi
    fi

    echo ""
fi

# ==========================================
# Resumen final
# ==========================================
echo -e "${BOLD}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║                    RESUMEN DE VALIDACIÓN                 ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

TOTAL=$((SUCCESS + WARNINGS + ERRORS))

echo -e "${GREEN}  ✓ Verificaciones exitosas:${NC} ${BOLD}$SUCCESS${NC}"
echo -e "${YELLOW}  ! Advertencias:${NC}             ${BOLD}$WARNINGS${NC}"
echo -e "${RED}  ✗ Errores:${NC}                  ${BOLD}$ERRORS${NC}"
echo ""

# ==========================================
# Recomendaciones
# ==========================================
if [ $ERRORS -gt 0 ] || [ $WARNINGS -gt 0 ]; then
    echo -e "${BOLD}Recomendaciones:${NC}"
    echo ""

    if [ $ERRORS -gt 0 ]; then
        echo -e "${RED}ERRORES CRÍTICOS:${NC}"

        if ! command -v tshark &> /dev/null; then
            echo "  1. Instalar Wireshark/tshark:"
            echo "     macOS:  brew install wireshark"
            echo "     Linux:  sudo apt install tshark"
            echo ""
        fi

        if ! command -v aircrack-ng &> /dev/null; then
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
        echo -e "${YELLOW}MEJORAS SUGERIDAS:${NC}"

        if ! command -v wireshark &> /dev/null; then
            echo "  • Instalar Wireshark GUI para análisis visual"
            echo ""
        fi

        if ! command -v hcxpcapngtool &> /dev/null; then
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
    echo -e "${GREEN}${BOLD}✓ Laboratorio correctamente configurado!${NC}"
    echo ""
    echo -e "${BOLD}Próximos pasos:${NC}"
    echo "  1. Revisar guía de ejercicios:  cat EJERCICIOS.md"
    echo "  2. Ejecutar primer ejercicio:   cd analysis_scripts && ./01_handshake_analysis.sh"
    echo "  3. Explorar PCAPs con Wireshark: wireshark wifi_lab/pcaps/wpa2/*.pcap"
    echo ""
else
    echo ""
    echo -e "${RED}${BOLD}✗ Configuración incompleta${NC}"
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
