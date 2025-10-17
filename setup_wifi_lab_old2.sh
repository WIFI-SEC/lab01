#!/bin/bash

# ======================================================
# Script: setup_wifi_lab.sh (Versión actualizada)
# Descripción: Prepara un laboratorio WiFi con PCAPs públicos
# Autor: UTN - Laboratorio Blockchain & Ciberseguridad
# ======================================================

# Colores
BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

printf "${BOLD}${BLUE}\n"
cat << "EOF"
╔══════════════════════════════════════════════════════════╗
║     Laboratorio de Seguridad WiFi - UTN                 ║
║     Setup de PCAPs para Análisis Defensivo              ║
╚══════════════════════════════════════════════════════════╝
EOF
printf "${NC}\n"

# Crear estructura de carpetas
printf "${GREEN}[+]${NC} Creando estructura de directorios...\n"
mkdir -p wifi_lab/{pcaps/{wpa2,wpa3,wep,attacks,misc},outputs,reports,scripts}

cd wifi_lab

# Función para descargar con validación
download_pcap() {
    local url=$1
    local output=$2
    local description=$3

    printf "${BLUE}[→]${NC} Descargando: $description\n"

    if curl -f -L -s -o "$output" "$url" 2>/dev/null; then
        if [ -f "$output" ] && [ -s "$output" ]; then
            printf "${GREEN}[✓]${NC} $description descargado correctamente\n"
            return 0
        fi
    fi

    printf "${YELLOW}[!]${NC} No se pudo descargar: $description\n"
    rm -f "$output"
    return 1
}

echo ""
printf "${GREEN}[+]${NC} Descargando PCAPs de repositorios públicos...\n"
echo ""

# ==========================================
# WPA2 PCAPs - URLs verificadas de wiki.wireshark.org
# ==========================================
printf "${BOLD}WPA2 Captures:${NC}\n"

download_pcap \
    "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/wpa-Induction.pcap.gz" \
    "pcaps/wpa2/wpa_induction.pcap.gz" \
    "WPA handshake - Induction"

download_pcap \
    "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/wpa-eap-tls.pcap.gz" \
    "pcaps/wpa2/wpa_eap_tls.pcap.gz" \
    "WPA EAP-TLS authentication"

download_pcap \
    "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/wpa2-psk-ft.pcap.gz" \
    "pcaps/wpa2/wpa2_psk_ft.pcap.gz" \
    "WPA2-PSK with Fast Transition"

download_pcap \
    "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/wpa-psk-final.pcap.gz" \
    "pcaps/wpa2/wpa_psk_final.pcap.gz" \
    "WPA-PSK final handshake"

echo ""

# ==========================================
# WPA3 / WiFi 6 (802.11ax)
# ==========================================
printf "${BOLD}WPA3 / WiFi 6 Captures:${NC}\n"

download_pcap \
    "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/wifi_sae.pcap.gz" \
    "pcaps/wpa3/wifi_sae.pcap.gz" \
    "WiFi SAE (WPA3) authentication"

download_pcap \
    "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/wifi_protected_setup.pcap.gz" \
    "pcaps/wpa3/wifi_protected_setup.pcap.gz" \
    "WiFi Protected Setup (WPS)"

echo ""

# ==========================================
# WEP PCAPs
# ==========================================
printf "${BOLD}WEP Captures (legacy):${NC}\n"

download_pcap \
    "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/wep.pcap.gz" \
    "pcaps/wep/wep_capture.pcap.gz" \
    "WEP encrypted traffic"

download_pcap \
    "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/wep-0x0f.pcap.gz" \
    "pcaps/wep/wep_0x0f.pcap.gz" \
    "WEP with key 0x0F"

echo ""

# ==========================================
# WiFi Management Frames
# ==========================================
printf "${BOLD}WiFi Management Frames:${NC}\n"

download_pcap \
    "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/802.11-probe-req.cap.gz" \
    "pcaps/attacks/80211_probe_req.cap.gz" \
    "802.11 Probe Requests"

download_pcap \
    "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/80211-beacon.pcap.gz" \
    "pcaps/misc/80211_beacon.pcap.gz" \
    "802.11 Beacon frames"

download_pcap \
    "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/ciscowl.pcap.gz" \
    "pcaps/misc/cisco_wireless.pcap.gz" \
    "Cisco Wireless traffic"

echo ""

# ==========================================
# EAPOL y 802.1X
# ==========================================
printf "${BOLD}EAPOL / 802.1X Captures:${NC}\n"

download_pcap \
    "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/eapol.pcap.gz" \
    "pcaps/misc/eapol_exchange.pcap.gz" \
    "EAPOL key exchange"

download_pcap \
    "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/eap-tls.pcap.gz" \
    "pcaps/misc/eap_tls.pcap.gz" \
    "EAP-TLS authentication"

echo ""

# ==========================================
# HTTP/DNS sobre redes
# ==========================================
printf "${BOLD}Network Traffic Captures:${NC}\n"

download_pcap \
    "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/http.cap.gz" \
    "pcaps/misc/http_traffic.cap.gz" \
    "HTTP traffic"

download_pcap \
    "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/dns.cap.gz" \
    "pcaps/misc/dns_queries.cap.gz" \
    "DNS queries"

download_pcap \
    "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/arp-storm.pcap.gz" \
    "pcaps/attacks/arp_storm.pcap.gz" \
    "ARP storm (potential MitM)"

echo ""

# ==========================================
# Descomprimir archivos .gz
# ==========================================
printf "${GREEN}[+]${NC} Descomprimiendo archivos...\n"

for gz_file in $(find pcaps -name "*.gz" 2>/dev/null); do
    base_name="${gz_file%.gz}"
    if gunzip -f "$gz_file" 2>/dev/null; then
        printf "${GREEN}  [✓]${NC} Descomprimido: $(basename $base_name)\n"
    fi
done

echo ""

# ==========================================
# Generar manifiesto con hashes
# ==========================================
printf "${GREEN}[+]${NC} Generando manifiesto de integridad...\n"

cat > manifest.txt << 'MANIFEST_HEADER'
# WiFi Lab - Manifiesto de PCAPs
# Este archivo contiene los checksums SHA256 de todos los PCAPs descargados
# Usar para verificar integridad: shasum -a 256 -c manifest.sha256
#
MANIFEST_HEADER

# Generar checksums solo de archivos que existen
find pcaps -type f \( -name "*.pcap" -o -name "*.pcapng" -o -name "*.cap" \) -exec shasum -a 256 {} \; > manifest.sha256 2>/dev/null || \
find pcaps -type f \( -name "*.pcap" -o -name "*.pcapng" -o -name "*.cap" \) -exec sha256sum {} \; > manifest.sha256 2>/dev/null || true

printf "${GREEN}[✓]${NC} Manifiesto creado: manifest.sha256\n"

# ==========================================
# Crear archivo de metadatos
# ==========================================
cat > pcaps/README.md << 'PCAP_README'
# WiFi Security Lab - PCAP Files

## Estructura de Archivos

### WPA2
- `wpa_induction.pcap` - Captura de 4-way handshake WPA-PSK
- `wpa_eap_tls.pcap` - Autenticación WPA con EAP-TLS
- `wpa2_psk_ft.pcap` - WPA2-PSK con Fast Transition (802.11r)
- `wpa_psk_final.pcap` - Handshake WPA-PSK completo

### WPA3
- `wifi_sae.pcap` - WiFi SAE (WPA3) authentication
- `wifi_protected_setup.pcap` - WPS (WiFi Protected Setup)

### WEP (Legacy)
- `wep_capture.pcap` - Tráfico WEP encriptado
- `wep_0x0f.pcap` - WEP con clave específica

### Attacks
- `80211_probe_req.cap` - Probe requests (reconocimiento)
- `arp_storm.pcap` - ARP storm (posible MitM)

### Misc
- `80211_beacon.pcap` - WiFi beacon frames analysis
- `eapol_exchange.pcap` - EAPOL key exchanges
- `eap_tls.pcap` - EAP-TLS authentication
- `cisco_wireless.pcap` - Cisco wireless traffic
- `http_traffic.cap` - HTTP traffic (captive portal simulation)
- `dns_queries.cap` - DNS queries over network

## Fuentes

Estos archivos provienen de repositorios públicos educativos:
- Wireshark Sample Captures (wiki.wireshark.org)
- Todos los archivos son de dominio público para uso educativo

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

total_pcaps=$(find pcaps -type f \( -name "*.pcap" -o -name "*.pcapng" -o -name "*.cap" \) | wc -l | tr -d ' ')
total_size=$(du -sh pcaps | cut -f1)

printf "  ${BLUE}•${NC} Total de PCAPs descargados: ${BOLD}$total_pcaps${NC}\n"
printf "  ${BLUE}•${NC} Tamaño total: ${BOLD}$total_size${NC}\n"
printf "  ${BLUE}•${NC} Estructura de directorios:\n"
echo ""

if command -v tree &> /dev/null; then
    tree -L 2 -h pcaps
else
    find pcaps -type f | head -20
fi

echo ""
printf "${GREEN}[✓]${NC} Laboratorio WiFi preparado con éxito.\n"
echo ""
printf "${YELLOW}Próximos pasos:${NC}\n"
echo "  1. Ejecutar: cd wifi_lab"
echo "  2. Verificar integridad: shasum -a 256 -c manifest.sha256"
echo "  3. Revisar ejercicios en: ../EJERCICIOS.md"
echo "  4. Ejecutar análisis: bash ../analysis_scripts/01_handshake_analysis.sh"
echo ""
