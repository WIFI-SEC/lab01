#!/usr/bin/env bash

# ======================================================
# Script: install_tools.sh
# Descripción: Instalador universal de herramientas para el laboratorio WiFi
# Compatible: macOS, Linux (Ubuntu/Debian/Arch), Windows (WSL)
# ======================================================

set -e

BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

printf "${BOLD}${BLUE}\n"
cat << "EOF"
╔══════════════════════════════════════════════════════════╗
║     Instalador de Herramientas - WiFi Security Lab      ║
╚══════════════════════════════════════════════════════════╝
EOF
printf "${NC}\n"

# ==========================================
# Detectar sistema operativo
# ==========================================
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            case "$ID" in
                ubuntu|debian|linuxmint)
                    echo "debian"
                    ;;
                arch|manjaro)
                    echo "arch"
                    ;;
                fedora|rhel|centos)
                    echo "redhat"
                    ;;
                *)
                    echo "linux"
                    ;;
            esac
        else
            echo "linux"
        fi
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        echo "windows"
    else
        echo "unknown"
    fi
}

OS=$(detect_os)

printf "${GREEN}[+]${NC} Sistema operativo detectado: ${BOLD}$OS${NC}\n"
echo ""

# ==========================================
# Función para verificar si comando existe
# ==========================================
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# ==========================================
# Instalación según el sistema operativo
# ==========================================

case "$OS" in
    macos)
        printf "${BLUE}[macOS]${NC} Instalando herramientas...\n"
        echo ""

        # Verificar si Homebrew está instalado
        if ! command_exists brew; then
            printf "${YELLOW}[!]${NC} Homebrew no está instalado. Instalando...\n"
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        else
            printf "${GREEN}[✓]${NC} Homebrew ya está instalado\n"
        fi

        echo ""
        printf "${GREEN}[+]${NC} Actualizando Homebrew...\n"
        brew update

        echo ""
        printf "${GREEN}[+]${NC} Instalando herramientas requeridas...\n"

        # Herramientas esenciales
        TOOLS="wireshark aircrack-ng wget"
        for tool in $TOOLS; do
            if command_exists "$tool"; then
                printf "${GREEN}[✓]${NC} $tool ya está instalado\n"
            else
                printf "${BLUE}[→]${NC} Instalando $tool...\n"
                brew install "$tool"
            fi
        done

        echo ""
        printf "${GREEN}[+]${NC} Instalando herramientas opcionales...\n"

        # Herramientas opcionales
        OPT_TOOLS="hcxtools hashcat"
        for tool in $OPT_TOOLS; do
            if command_exists "$tool"; then
                printf "${GREEN}[✓]${NC} $tool ya está instalado\n"
            else
                printf "${BLUE}[→]${NC} Instalando $tool (opcional)...\n"
                brew install "$tool" 2>/dev/null || printf "${YELLOW}[!]${NC} No se pudo instalar $tool (opcional)\n"
            fi
        done
        ;;

    debian)
        printf "${BLUE}[Debian/Ubuntu]${NC} Instalando herramientas...\n"
        echo ""

        printf "${GREEN}[+]${NC} Actualizando lista de paquetes...\n"
        sudo apt update

        echo ""
        printf "${GREEN}[+]${NC} Instalando herramientas requeridas...\n"

        TOOLS="wireshark tshark aircrack-ng wget curl"
        for tool in $TOOLS; do
            if command_exists "$tool"; then
                printf "${GREEN}[✓]${NC} $tool ya está instalado\n"
            else
                printf "${BLUE}[→]${NC} Instalando $tool...\n"
                sudo apt install -y "$tool"
            fi
        done

        echo ""
        printf "${GREEN}[+]${NC} Instalando herramientas opcionales...\n"

        # Herramientas opcionales
        if ! command_exists hcxpcapngtool; then
            printf "${BLUE}[→]${NC} Instalando hcxtools...\n"
            sudo apt install -y hcxtools 2>/dev/null || printf "${YELLOW}[!]${NC} hcxtools no disponible en repos estándar\n"
        fi

        if ! command_exists hashcat; then
            printf "${BLUE}[→]${NC} Instalando hashcat...\n"
            sudo apt install -y hashcat 2>/dev/null || printf "${YELLOW}[!]${NC} hashcat no disponible\n"
        fi

        # Agregar usuario al grupo wireshark
        echo ""
        printf "${GREEN}[+]${NC} Configurando permisos de Wireshark...\n"
        sudo usermod -aG wireshark "$USER" 2>/dev/null || true
        printf "${YELLOW}[!]${NC} Necesitas hacer logout/login para que los cambios tomen efecto\n"
        ;;

    arch)
        printf "${BLUE}[Arch Linux]${NC} Instalando herramientas...\n"
        echo ""

        printf "${GREEN}[+]${NC} Actualizando sistema...\n"
        sudo pacman -Sy

        echo ""
        printf "${GREEN}[+]${NC} Instalando herramientas...\n"

        sudo pacman -S --needed wireshark-qt wireshark-cli aircrack-ng wget curl

        # Herramientas opcionales
        sudo pacman -S --needed hcxtools hashcat 2>/dev/null || true

        # Permisos
        sudo usermod -aG wireshark "$USER" 2>/dev/null || true
        ;;

    redhat)
        printf "${BLUE}[RHEL/Fedora/CentOS]${NC} Instalando herramientas...\n"
        echo ""

        printf "${GREEN}[+]${NC} Instalando herramientas...\n"

        sudo dnf install -y wireshark aircrack-ng wget curl

        # Herramientas opcionales
        sudo dnf install -y hashcat 2>/dev/null || true
        ;;

    windows)
        printf "${BLUE}[Windows/WSL]${NC} Detectado Windows Subsystem for Linux\n"
        echo ""

        printf "${YELLOW}[!]${NC} Para Windows, se recomienda usar WSL2 con Ubuntu\n"
        printf "${YELLOW}[!]${NC} Ejecutando instalación para Linux...\n"
        echo ""

        # Tratar como Debian/Ubuntu
        sudo apt update
        sudo apt install -y wireshark tshark aircrack-ng wget curl
        ;;

    *)
        printf "${RED}[✗]${NC} Sistema operativo no soportado: $OSTYPE\n"
        echo ""
        printf "Sistemas soportados:\n"
        printf "  - macOS (con Homebrew)\n"
        printf "  - Ubuntu/Debian\n"
        printf "  - Arch Linux\n"
        printf "  - Fedora/RHEL/CentOS\n"
        printf "  - Windows (con WSL)\n"
        exit 1
        ;;
esac

echo ""
echo ""

# ==========================================
# Verificación de instalación
# ==========================================
printf "${BOLD}${GREEN}Verificando instalación...${NC}\n"
echo ""

check_tool() {
    local tool=$1
    local required=$2

    if command_exists "$tool"; then
        version=$("$tool" --version 2>&1 | head -1)
        printf "${GREEN}[✓]${NC} %-20s ${BOLD}instalado${NC}\n" "$tool"
        printf "    ${version}\n"
        return 0
    else
        if [ "$required" = "required" ]; then
            printf "${RED}[✗]${NC} %-20s ${BOLD}NO INSTALADO${NC}\n" "$tool"
            return 1
        else
            printf "${YELLOW}[!]${NC} %-20s ${BOLD}no instalado${NC} (opcional)\n" "$tool"
            return 0
        fi
    fi
}

ERRORS=0

echo "Herramientas requeridas:"
check_tool "tshark" "required" || ((ERRORS++))
check_tool "aircrack-ng" "required" || ((ERRORS++))
check_tool "wget" "required" || ((ERRORS++))

echo ""
echo "Herramientas opcionales:"
check_tool "wireshark" "optional"
check_tool "hcxpcapngtool" "optional"
check_tool "hashcat" "optional"

echo ""
echo ""

# ==========================================
# Resumen
# ==========================================
if [ $ERRORS -eq 0 ]; then
    printf "${BOLD}${GREEN}✓ Instalación completada exitosamente${NC}\n"
    echo ""
    printf "Próximos pasos:\n"
    printf "  1. Ejecutar: ${BOLD}bash setup_wifi_lab.sh${NC}\n"
    printf "  2. Validar: ${BOLD}bash validate_setup.sh${NC}\n"

    if [[ "$OS" == "debian" ]] || [[ "$OS" == "arch" ]]; then
        echo ""
        printf "${YELLOW}[!]${NC} Importante: Ejecuta ${BOLD}logout${NC} y vuelve a iniciar sesión\n"
        printf "    para que los permisos de Wireshark tomen efecto\n"
    fi
else
    printf "${BOLD}${RED}✗ Instalación incompleta ($ERRORS errores)${NC}\n"
    echo ""
    printf "Por favor, revisa los errores anteriores y vuelve a ejecutar el script.\n"
    exit 1
fi

echo ""
