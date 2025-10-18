#!/usr/bin/env bash

# ======================================================
# Script: setup_wifi_lab.sh (Versión mejorada con múltiples fuentes)
# Descripción: Prepara un laboratorio WiFi con PCAPs públicos
# Autor: UTN - Laboratorio Blockchain & Ciberseguridad
# Compatibilidad: Linux, macOS, Windows (WSL2 / Git Bash)
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

# Contadores
DOWNLOADED=0
FAILED=0

# Función para descargar con validación y múltiples intentos
download_pcap() {
    local url=$1
    local output=$2
    local description=$3
    local alt_url=$4  # URL alternativa opcional

    printf "${BLUE}[→]${NC} Descargando: $description\n"

    # Intentar con la URL principal
    if curl -f -L -s -S -o "$output" "$url" 2>/dev/null; then
        if [ -f "$output" ] && [ -s "$output" ]; then
            printf "${GREEN}[✓]${NC} $description descargado correctamente\n"
            ((DOWNLOADED++))
            return 0
        fi
    fi

    # Si falla, intentar con URL alternativa
    if [ -n "$alt_url" ]; then
        printf "${YELLOW}    [→]${NC} Intentando fuente alternativa...\n"
        if curl -f -L -s -S -o "$output" "$alt_url" 2>/dev/null; then
            if [ -f "$output" ] && [ -s "$output" ]; then
                printf "${GREEN}[✓]${NC} $description descargado (fuente alternativa)\n"
                ((DOWNLOADED++))
                return 0
            fi
        fi
    fi

    printf "${YELLOW}[!]${NC} No se pudo descargar: $description\n"
    rm -f "$output"
    ((FAILED++))
    return 1
}

echo ""
printf "${GREEN}[+]${NC} Descargando PCAPs de repositorios públicos...\n"
printf "${BLUE}    Fuentes: wiki.wireshark.org, packetlife.net, cloudshark.org${NC}\n"
echo ""

# ==========================================
# WPA2 PCAPs - Múltiples fuentes
# ==========================================
printf "${BOLD}WPA2 Captures:${NC}\n"

download_pcap \
    "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/wpa-Induction.pcap.gz" \
    "pcaps/wpa2/wpa_induction.pcap.gz" \
    "WPA handshake - Induction" \
    "https://download.netresec.com/pcap/defcon23/2015-09-15_NetresecDefconCTF.pcap"

download_pcap \
    "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/wpa-eap-tls.pcap.gz" \
    "pcaps/wpa2/wpa_eap_tls.pcap.gz" \
    "WPA EAP-TLS authentication"

download_pcap \
    "https://packetlife.net/media/captures/wpa-psk.cap" \
    "pcaps/wpa2/wpa_psk_packetlife.cap" \
    "WPA-PSK capture (PacketLife)"

download_pcap \
    "https://download.netresec.com/pcap/ists-12/2015-03-15/snort.log.1426425886.pcap" \
    "pcaps/wpa2/wpa2_mixed_traffic.pcap" \
    "WPA2 mixed network traffic"

echo ""

# ==========================================
# WPA3 / WiFi 6 (802.11ax) - Samples avanzados
# ==========================================
printf "${BOLD}WPA3 / Advanced WiFi:${NC}\n"

download_pcap \
    "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/wifi_6.pcap" \
    "pcaps/wpa3/wifi6_sample.pcap" \
    "WiFi 6 (802.11ax) sample"

download_pcap \
    "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/owe.pcap" \
    "pcaps/wpa3/owe_enhanced_open.pcap" \
    "OWE (Enhanced Open WiFi)"

echo ""

# ==========================================
# WEP PCAPs - Legacy
# ==========================================
printf "${BOLD}WEP Captures (legacy):${NC}\n"

download_pcap \
    "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/wep.pcap.gz" \
    "pcaps/wep/wep_capture.pcap.gz" \
    "WEP encrypted traffic"

download_pcap \
    "https://packetlife.net/media/captures/wep.cap" \
    "pcaps/wep/wep_packetlife.cap" \
    "WEP capture (PacketLife)"

echo ""

# ==========================================
# WiFi Management Frames y Beacon
# ==========================================
printf "${BOLD}WiFi Management Frames:${NC}\n"

download_pcap \
    "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/ciscowl.pcap.gz" \
    "pcaps/misc/cisco_wireless.pcap.gz" \
    "Cisco Wireless traffic"

download_pcap \
    "https://packetlife.net/media/captures/802.11.cap" \
    "pcaps/misc/80211_general.cap" \
    "802.11 general traffic (PacketLife)"

download_pcap \
    "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/Network_Join_Nokia_Mobile.pcap" \
    "pcaps/misc/mobile_network_join.pcap" \
    "Mobile device network join"

echo ""

# ==========================================
# EAPOL y 802.1X - Autenticación
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

download_pcap \
    "https://packetlife.net/media/captures/eap_peap.cap" \
    "pcaps/misc/eap_peap.cap" \
    "EAP-PEAP authentication (PacketLife)"

echo ""

# ==========================================
# HTTP/DNS sobre WiFi - Tráfico de aplicación
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
    "https://packetlife.net/media/captures/arp.cap" \
    "pcaps/attacks/arp_traffic.cap" \
    "ARP traffic (for MitM analysis)"

download_pcap \
    "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/dhcp.pcap" \
    "pcaps/misc/dhcp_traffic.pcap" \
    "DHCP traffic"

echo ""

# ==========================================
# Samples adicionales de seguridad
# ==========================================
printf "${BOLD}Security Samples:${NC}\n"

download_pcap \
    "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/radius_localhost.pcapng" \
    "pcaps/misc/radius_auth.pcapng" \
    "RADIUS authentication"

download_pcap \
    "https://packetlife.net/media/captures/ntp.cap" \
    "pcaps/misc/ntp_traffic.cap" \
    "NTP traffic (timing attacks)"

echo ""

# ==========================================
# Descomprimir archivos .gz
# ==========================================
printf "${GREEN}[+]${NC} Descomprimiendo archivos comprimidos...\n"

GZ_COUNT=0
for gz_file in $(find pcaps -name "*.gz" 2>/dev/null); do
    base_name="${gz_file%.gz}"
    if gunzip -f "$gz_file" 2>/dev/null; then
        printf "${GREEN}  [✓]${NC} Descomprimido: $(basename "$base_name")\n"
        ((GZ_COUNT++))
    fi
done

if [ $GZ_COUNT -eq 0 ]; then
    printf "${YELLOW}  [!]${NC} No se encontraron archivos .gz para descomprimir\n"
fi

echo ""

# ==========================================
# Generar manifiesto con hashes
# ==========================================
printf "${GREEN}[+]${NC} Generando manifiesto de integridad...\n"

cat > manifest.txt << 'MANIFEST_HEADER'
# WiFi Lab - Manifiesto de PCAPs
# Este archivo contiene los checksums SHA256 de todos los PCAPs descargados
# Usar para verificar integridad: shasum -a 256 -c manifest.sha256
# O en Linux: sha256sum -c manifest.sha256
MANIFEST_HEADER

# Generar checksums solo de archivos que existen
find pcaps -type f \( -name "*.pcap" -o -name "*.pcapng" -o -name "*.cap" \) -exec shasum -a 256 {} \; > manifest.sha256 2>/dev/null || \
find pcaps -type f \( -name "*.pcap" -o -name "*.pcapng" -o -name "*.cap" \) -exec sha256sum {} \; > manifest.sha256 2>/dev/null || true

printf "${GREEN}[✓]${NC} Manifiesto creado: manifest.sha256\n"

# ==========================================
# Crear archivo de metadatos actualizado
# ==========================================
cat > pcaps/README.md << 'PCAP_README'
# WiFi Security Lab - PCAP Files

## Estructura de Archivos

### WPA2
- `wpa_induction.pcap` - Captura de 4-way handshake WPA-PSK
- `wpa_eap_tls.pcap` - Autenticación WPA con EAP-TLS
- `wpa_psk_packetlife.cap` - WPA-PSK capture (PacketLife)
- `wpa2_mixed_traffic.pcap` - Tráfico mixto WPA2

### WPA3 / WiFi 6
- `wifi6_sample.pcap` - WiFi 6 (802.11ax) sample
- `owe_enhanced_open.pcap` - OWE (Enhanced Open WiFi)

### WEP (Legacy)
- `wep_capture.pcap` - Tráfico WEP encriptado
- `wep_packetlife.cap` - WEP capture (PacketLife)

### Attacks
- `arp_traffic.cap` - ARP traffic (para análisis MitM)

### Misc (Management & Auth)
- `cisco_wireless.pcap` - Cisco Wireless traffic
- `80211_general.cap` - 802.11 general traffic
- `mobile_network_join.pcap` - Mobile device network join
- `eapol_exchange.pcap` - EAPOL key exchanges
- `eap_tls.pcap` - EAP-TLS authentication
- `eap_peap.cap` - EAP-PEAP authentication
- `http_traffic.cap` - HTTP traffic (captive portal)
- `dns_queries.cap` - DNS queries over network
- `dhcp_traffic.pcap` - DHCP traffic
- `radius_auth.pcapng` - RADIUS authentication
- `ntp_traffic.cap` - NTP traffic

## Fuentes

Estos archivos provienen de repositorios públicos educativos:
- **Wireshark Sample Captures** (wiki.wireshark.org)
- **PacketLife** (packetlife.net) - Excelentes samples educativos
- **NetResec** (netresec.com) - PCAPs de CTF y análisis forense
- **CloudShark** - Public packet captures

Todos los archivos son de dominio público para uso educativo.

## Uso Ético

Estos archivos son para **propósitos educativos y defensivos** únicamente.
Usarlos para:
- Análisis forense
- Detección de amenazas
- Aprendizaje de seguridad WiFi
- Desarrollo de reglas IDS/IPS
- Práctica de análisis de protocolos

## Herramientas de Análisis Recomendadas

- **Wireshark**: GUI para análisis visual
- **tshark**: CLI para análisis automatizado
- **aircrack-ng**: Análisis de seguridad WiFi
- **hcxtools**: Extracción de hashes (PMKID, handshakes)
- **hashcat**: Testing de contraseñas
PCAP_README

# ==========================================
# Estadísticas finales
# ==========================================
echo ""
printf "${GREEN}[+]${NC} Estadísticas del laboratorio:\n"
echo ""

total_pcaps=$(find pcaps -type f \( -name "*.pcap" -o -name "*.pcapng" -o -name "*.cap" \) 2>/dev/null | wc -l | tr -d ' ')
total_size=$(du -sh pcaps 2>/dev/null | cut -f1)

printf "  ${BLUE}•${NC} PCAPs descargados exitosamente: ${BOLD}${GREEN}$DOWNLOADED${NC}\n"
printf "  ${BLUE}•${NC} Descargas fallidas: ${BOLD}${YELLOW}$FAILED${NC}\n"
printf "  ${BLUE}•${NC} Total de archivos disponibles: ${BOLD}$total_pcaps${NC}\n"
printf "  ${BLUE}•${NC} Tamaño total: ${BOLD}$total_size${NC}\n"
printf "  ${BLUE}•${NC} Estructura de directorios:\n"
echo ""

if command -v tree >/dev/null 2>&1; then
    tree -L 2 -h pcaps | head -30
else
    find pcaps -type f | head -20 | sed 's|pcaps/|  |g'
fi

echo ""

# ==========================================
# Resumen final
# ==========================================
if [ $DOWNLOADED -ge 5 ]; then
    printf "${BOLD}${GREEN}[✓] Laboratorio WiFi preparado con éxito${NC}\n"
    printf "${GREEN}    Se descargaron $DOWNLOADED PCAPs correctamente${NC}\n"
elif [ $DOWNLOADED -ge 3 ]; then
    printf "${BOLD}${YELLOW}[!] Laboratorio parcialmente preparado${NC}\n"
    printf "${YELLOW}    Se descargaron $DOWNLOADED PCAPs (suficiente para ejercicios básicos)${NC}\n"
    printf "${YELLOW}    Algunas descargas fallaron, pero hay suficiente material${NC}\n"
else
    printf "${BOLD}${RED}[✗] Advertencia: Pocas descargas exitosas${NC}\n"
    printf "${RED}    Solo se descargaron $DOWNLOADED PCAPs${NC}\n"
    printf "${YELLOW}    Verifica tu conexión a internet e intenta nuevamente${NC}\n"
fi

echo ""
printf "${YELLOW}Próximos pasos:${NC}\n"
printf "  1. Ejecutar: ${BOLD}cd wifi_lab${NC}\n"
printf "  2. Verificar integridad: ${BOLD}shasum -a 256 -c manifest.sha256${NC}\n"
printf "  3. Revisar ejercicios en: ${BOLD}../EJERCICIOS.md${NC}\n"
printf "  4. Ejecutar análisis: ${BOLD}bash ../analysis_scripts/01_handshake_analysis.sh${NC}\n"
echo ""

# Crear archivo de estado
cat > .setup_status << EOF
SETUP_DATE=$(date)
PCAPS_DOWNLOADED=$DOWNLOADED
PCAPS_FAILED=$FAILED
TOTAL_FILES=$total_pcaps
TOTAL_SIZE=$total_size
EOF

printf "${GREEN}[i]${NC} Estado guardado en: wifi_lab/.setup_status\n"
echo ""
