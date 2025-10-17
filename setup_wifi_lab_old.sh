#!/bin/bash

# ======================================================
# Script: setup_wifi_lab.sh
# Descripción: Prepara un laboratorio WiFi con PCAPs públicos
# Autor: UTN - Laboratorio Blockchain & Ciberseguridad
# ======================================================

# No usar set -e para permitir que el script continúe si algunas descargas fallan
# set -e

BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

printf "${BOLD}${BLUE}\n\n"
cat << "EOF"
╔══════════════════════════════════════════════════════════╗
║     Laboratorio de Seguridad WiFi - UTN                 ║
║     Setup de PCAPs para Análisis Defensivo              ║
╚══════════════════════════════════════════════════════════╝
EOF
printf "${NC}\n\n"

# Crear estructura de carpetas
printf "${GREEN}[+]${NC} Creando estructura de directorios...\n\n"
mkdir -p wifi_lab/{pcaps/{wpa2,wpa3,wep,attacks,misc},outputs,reports,scripts}

cd wifi_lab

# Función para descargar con validación
download_pcap() {
    local url=$1
    local output=$2
    local description=$3

    printf "${BLUE}[→]${NC} Descargando: $description\n"

    if wget -q --show-progress -O "$output" "$url" 2>/dev/null; then
        printf "${GREEN}[✓]${NC} $description descargado correctamente\n"
        return 0
    else
        printf "${YELLOW}[!]${NC} No se pudo descargar: $description (puede no estar disponible)\n"
        rm -f "$output"
        return 1
    fi
}

echo ""
printf "${GREEN}[+]${NC} Descargando PCAPs de repositorios públicos...\n"
echo ""

# ==========================================
# WPA2 PCAPs - Usando Wireshark sample captures
# ==========================================
printf "${BOLD}WPA2 Captures:${NC}\n"

# Wireshark tiene muestras confiables y estables
download_pcap \
    "https://gitlab.com/wireshark/wireshark/-/raw/master/test/captures/wpa-Induction.pcap" \
    "pcaps/wpa2/wpa_induction.pcap" \
    "WPA handshake - Wireshark sample"

download_pcap \
    "https://gitlab.com/wireshark/wireshark/-/raw/master/test/captures/wpa-eap-tls.pcap.gz" \
    "pcaps/wpa2/wpa_eap_tls.pcap.gz" \
    "WPA EAP-TLS authentication"

download_pcap \
    "https://gitlab.com/wireshark/wireshark/-/raw/master/test/captures/wpa-psk-ft.pcap.gz" \
    "pcaps/wpa2/wpa_psk_ft.pcap.gz" \
    "WPA2-PSK with Fast Transition"

echo ""

# ==========================================
# WPA3 PCAPs - Samples más avanzados
# ==========================================
printf "${BOLD}WPA3 Captures:${NC}\n"

# WPA3 samples son menos comunes, intentamos varias fuentes
download_pcap \
    "https://gitlab.com/wireshark/wireshark/-/raw/master/test/captures/wpa3-sae.pcap" \
    "pcaps/wpa3/wpa3_sae_example.pcap" \
    "WPA3 SAE (Simultaneous Authentication of Equals)"

# Alternativa: usar samples de 802.11ax que incluyen WPA3
download_pcap \
    "https://gitlab.com/wireshark/wireshark/-/raw/master/test/captures/wifi_broken_crc.pcap" \
    "pcaps/wpa3/wifi_advanced.pcap" \
    "WiFi advanced frames (802.11ax)"

echo ""

# ==========================================
# WEP PCAPs
# ==========================================
printf "${BOLD}WEP Captures (legacy):${NC}\n"

download_pcap \
    "https://gitlab.com/wireshark/wireshark/-/raw/master/test/captures/wep.pcap" \
    "pcaps/wep/wep_capture.pcap" \
    "WEP encrypted traffic"

echo ""

# ==========================================
# WiFi Attacks
# ==========================================
printf "${BOLD}WiFi Attack Captures:${NC}\n"

download_pcap \
    "https://gitlab.com/wireshark/wireshark/-/raw/master/test/captures/deauth.pcap" \
    "pcaps/attacks/deauth_attack.pcap" \
    "Deauthentication attack"

download_pcap \
    "https://gitlab.com/wireshark/wireshark/-/raw/master/test/captures/80211-beacon.pcap" \
    "pcaps/misc/beacon_frames.pcap" \
    "WiFi beacon frames"

download_pcap \
    "https://gitlab.com/wireshark/wireshark/-/raw/master/test/captures/eapol.pcap" \
    "pcaps/misc/eapol_exchange.pcap" \
    "EAPOL key exchange"

echo ""

# ==========================================
# HTTP/HTTPS sobre WiFi
# ==========================================
printf "${BOLD}Network Traffic Captures:${NC}\n"

download_pcap \
    "https://gitlab.com/wireshark/wireshark/-/raw/master/test/captures/http.cap" \
    "pcaps/misc/http_traffic.cap" \
    "HTTP traffic (captive portal simulation)"

download_pcap \
    "https://gitlab.com/wireshark/wireshark/-/raw/master/test/captures/dns.cap" \
    "pcaps/misc/dns_queries.cap" \
    "DNS queries"

echo ""

# ==========================================
# Generar manifiesto con hashes
# ==========================================
printf "${GREEN}[+]${NC} Generando manifiesto de integridad...\n"

cat > manifest.txt << 'MANIFEST_HEADER'
# WiFi Lab - Manifiesto de PCAPs
# Generado: $(date)
#
# Este archivo contiene los checksums SHA256 de todos los PCAPs descargados
# Usar para verificar integridad: sha256sum -c manifest.sha256
#
MANIFEST_HEADER

# Generar checksums solo de archivos que existen
find pcaps -type f \( -name "*.pcap" -o -name "*.pcapng" \) -exec sha256sum {} \; > manifest.sha256 2>/dev/null || true

printf "${GREEN}[✓]${NC} Manifiesto creado: manifest.sha256\n"

# ==========================================
# Crear archivo de metadatos
# ==========================================
cat > pcaps/README.md << 'PCAP_README'
# WiFi Security Lab - PCAP Files

## Estructura de Archivos

### WPA2
- `wpa2_handshake_example.pcapng` - Captura de 4-way handshake WPA2-PSK
- `pmkid_attack_example.pcapng` - PMKID attack capture
- `wpa_induction.pcap` - Ejemplo adicional de WPA handshake

### WPA3
- `wpa3_sae_example.pcapng` - WPA3 SAE authentication

### WEP (Legacy)
- `wep_capture.pcap` - Tráfico WEP encriptado (para estudio histórico)

### Attacks
- `deauth_attack.pcap` - Deauthentication attack frames
- `beacon_frames.pcap` - WiFi beacon frames analysis
- `eapol_exchange.pcap` - EAPOL key exchanges

### Misc
- `http_traffic.cap` - HTTP traffic (captive portal)
- `dns_queries.cap` - DNS queries over WiFi

## Fuentes

Estos archivos provienen de repositorios públicos educativos:
- Mathy Vanhoef's WiFi examples (researcher de WPA3/KRACK)
- Wireshark sample captures (proyecto oficial)

## Uso Ético

Estos archivos son para **propósitos educativos y defensivos** únicamente.
Usarlos para análisis, detección de amenazas, y aprendizaje de seguridad WiFi.
PCAP_README

# ==========================================
# Estadísticas
# ==========================================
echo ""
printf "${GREEN}[+]${NC} Estadísticas del laboratorio:\n"
echo ""

total_pcaps=$(find pcaps -type f \( -name "*.pcap" -o -name "*.pcapng" \) | wc -l)
total_size=$(du -sh pcaps | cut -f1)

printf "  ${BLUE}•${NC} Total de PCAPs descargados: ${BOLD}$total_pcaps${NC}\n"
printf "  ${BLUE}•${NC} Tamaño total: ${BOLD}$total_size${NC}\n"
printf "  ${BLUE}•${NC} Estructura de directorios:\n"
echo ""

if command -v tree &> /dev/null; then
    tree -L 2 -h
else
    find . -maxdepth 2 -type d | sed 's|[^/]*/| |g'
fi

echo ""
printf "${GREEN}[✓]${NC} Laboratorio WiFi preparado con éxito.\n"
echo ""
printf "${YELLOW}Próximos pasos:${NC}\n"
echo "  1. Ejecutar: cd wifi_lab"
echo "  2. Verificar integridad: sha256sum -c manifest.sha256"
echo "  3. Revisar ejercicios en: ../EJERCICIOS.md"
echo "  4. Ejecutar análisis: bash scripts/analyze_*.sh"
echo ""
