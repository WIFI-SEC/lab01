#!/bin/bash

# Script para descargar PCAPs adicionales específicos para ejercicios

BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

printf "${BOLD}${BLUE}\n"
cat << "EOF"
╔══════════════════════════════════════════════════════════╗
║   Descarga de PCAPs Adicionales para Ejercicios        ║
║   Escenarios Realistas de Ataque y Defensa             ║
╚══════════════════════════════════════════════════════════╝
EOF
printf "${NC}\n"

cd wifi_lab || exit 1

DOWNLOADED=0
FAILED=0

download_pcap() {
    local url=$1
    local output=$2
    local description=$3
    local alt_url=$4

    printf "${BLUE}[→]${NC} Descargando: $description\n"

    if curl -f -L -s -S -o "$output" "$url" 2>/dev/null; then
        if [ -f "$output" ] && [ -s "$output" ]; then
            printf "${GREEN}[✓]${NC} $description descargado correctamente\n"
            ((DOWNLOADED++))
            return 0
        fi
    fi

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
printf "${GREEN}[+]${NC} Descargando PCAPs adicionales específicos...\n"
echo ""

# ==========================================
# ESCENARIO 1: Ataque de Deauthentication
# ==========================================
printf "${BOLD}Escenario 1: Ataque de Deauthentication${NC}\n"

download_pcap \
    "https://download.netresec.com/pcap/maccdc-2012/maccdc2012_00000.pcap.gz" \
    "pcaps/attacks/deauth_attack.pcap.gz" \
    "Deauthentication attack capture"

download_pcap \
    "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/wifi_deauth.pcap" \
    "pcaps/attacks/wifi_deauth.pcap" \
    "WiFi deauth frames"

echo ""

# ==========================================
# ESCENARIO 2: Evil Twin / Rogue AP
# ==========================================
printf "${BOLD}Escenario 2: Evil Twin / Rogue AP${NC}\n"

download_pcap \
    "https://download.netresec.com/pcap/defcon23/2015-09-15_NetresecDefconCTF.pcap" \
    "pcaps/attacks/rogue_ap_traffic.pcap" \
    "Rogue AP traffic capture"

echo ""

# ==========================================
# ESCENARIO 3: WEP Cracking (Legacy)
# ==========================================
printf "${BOLD}Escenario 3: WEP Cracking${NC}\n"

download_pcap \
    "https://download.netresec.com/pcap/defcon18/Defcon18-Forensics.pcap.gz" \
    "pcaps/wep/wep_crack_sample.pcap.gz" \
    "WEP encrypted traffic for cracking"

download_pcap \
    "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/wep_64_psk.pcap" \
    "pcaps/wep/wep_64bit.pcap" \
    "WEP 64-bit PSK capture"

echo ""

# ==========================================
# ESCENARIO 4: Captive Portal y DNS
# ==========================================
printf "${BOLD}Escenario 4: Captive Portal${NC}\n"

download_pcap \
    "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/dns-remoteshell.pcap" \
    "pcaps/misc/dns_tunnel.pcap" \
    "DNS tunneling example"

download_pcap \
    "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/http_with_jpegs.cap.gz" \
    "pcaps/misc/http_captive_portal.cap.gz" \
    "HTTP traffic (captive portal simulation)"

echo ""

# ==========================================
# ESCENARIO 5: WPA2 con múltiples clientes
# ==========================================
printf "${BOLD}Escenario 5: WPA2 Multi-Client${NC}\n"

download_pcap \
    "https://download.netresec.com/pcap/ists-12/2015-03-15/snort.log.1426423592.pcap" \
    "pcaps/wpa2/wpa2_multi_client.pcap" \
    "WPA2 network with multiple clients"

download_pcap \
    "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/wpa-eap-tls-2.pcap.gz" \
    "pcaps/wpa2/wpa_enterprise.pcap.gz" \
    "WPA2-Enterprise (802.1X) capture"

echo ""

# ==========================================
# ESCENARIO 6: ARP Spoofing y MitM
# ==========================================
printf "${BOLD}Escenario 6: ARP Spoofing / MitM${NC}\n"

download_pcap \
    "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/arp-storm.pcap" \
    "pcaps/attacks/arp_spoofing.pcap" \
    "ARP spoofing attack"

download_pcap \
    "https://download.netresec.com/pcap/maccdc-2010/maccdc2010_00000.pcap.gz" \
    "pcaps/attacks/mitm_scenario.pcap.gz" \
    "Man-in-the-Middle scenario"

echo ""

# ==========================================
# ESCENARIO 7: Beacon Flooding
# ==========================================
printf "${BOLD}Escenario 7: WiFi Discovery${NC}\n"

download_pcap \
    "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/wlan-probe-req.pcap" \
    "pcaps/misc/probe_requests.pcap" \
    "WiFi probe requests (device tracking)"

download_pcap \
    "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/Bluetooth-capture-01.cap" \
    "pcaps/misc/bluetooth_wifi.cap" \
    "Bluetooth and WiFi coexistence"

echo ""

# ==========================================
# ESCENARIO 8: Tráfico SSL/TLS sobre WiFi
# ==========================================
printf "${BOLD}Escenario 8: SSL/TLS Traffic${NC}\n"

download_pcap \
    "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/ssl-sample.pcap" \
    "pcaps/misc/ssl_handshake.pcap" \
    "SSL/TLS handshake over WiFi"

download_pcap \
    "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/snakeoil2_070531.tgz" \
    "pcaps/misc/tls_keys.tgz" \
    "TLS with decryption keys"

echo ""

# ==========================================
# Descomprimir .gz
# ==========================================
printf "${GREEN}[+]${NC} Descomprimiendo archivos .gz y .tgz...\n"

for gz_file in $(find pcaps -name "*.gz" 2>/dev/null); do
    if [[ "$gz_file" == *.tgz ]]; then
        # Extraer .tgz
        tar -xzf "$gz_file" -C "$(dirname "$gz_file")" 2>/dev/null && rm -f "$gz_file"
    else
        # Descomprimir .gz
        gunzip -f "$gz_file" 2>/dev/null
    fi
done

echo ""

# ==========================================
# Estadísticas finales
# ==========================================
printf "${GREEN}[+]${NC} Descarga de PCAPs adicionales completada\n"
echo ""

total_pcaps=$(find pcaps -type f \( -name "*.pcap" -o -name "*.pcapng" -o -name "*.cap" \) 2>/dev/null | wc -l | tr -d ' ')
total_size=$(du -sh pcaps 2>/dev/null | cut -f1)

printf "  ${BLUE}•${NC} Nuevos PCAPs descargados: ${BOLD}${GREEN}$DOWNLOADED${NC}\n"
printf "  ${BLUE}•${NC} Descargas fallidas: ${BOLD}${YELLOW}$FAILED${NC}\n"
printf "  ${BLUE}•${NC} Total de archivos disponibles: ${BOLD}$total_pcaps${NC}\n"
printf "  ${BLUE}•${NC} Tamaño total: ${BOLD}$total_size${NC}\n"

echo ""

if [ $DOWNLOADED -ge 5 ]; then
    printf "${BOLD}${GREEN}[✓] PCAPs adicionales descargados con éxito${NC}\n"
else
    printf "${BOLD}${YELLOW}[!] Algunos PCAPs no pudieron descargarse${NC}\n"
    printf "${YELLOW}    Esto es normal, algunas URLs pueden no estar disponibles${NC}\n"
fi

echo ""
printf "${YELLOW}Próximo paso:${NC} Ejecutar ejercicios mejorados con escenarios realistas\n"
echo ""
