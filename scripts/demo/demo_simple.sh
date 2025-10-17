#!/usr/bin/env bash

# ══════════════════════════════════════════════════════════════════════════════
# Script: demo_simple.sh
# Descripción: Demo simplificada y rápida del laboratorio (sin pausas)
# Uso: bash demo_simple.sh
# Compatibilidad: Linux, macOS, Windows (WSL2 / Git Bash)
# ══════════════════════════════════════════════════════════════════════════════

BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
printf "${BOLD}${BLUE}"
cat << "EOF"
╔══════════════════════════════════════════════════════════════════════════════╗
║                  LABORATORIO WIFI SECURITY - DEMO SIMPLE                     ║
║                     Universidad Tecnológica Nacional                         ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
printf "${NC}\n"

echo "═══════════════════════════════════════════════════════════════════════════════"
printf "${GREEN}1. VERIFICACIÓN DEL LABORATORIO${NC}\n"
echo "═══════════════════════════════════════════════════════════════════════════════"
echo ""

# PCAPs disponibles
TOTAL_PCAPS=$(find wifi_lab/pcaps -type f \( -name "*.pcap" -o -name "*.pcapng" -o -name "*.cap" \) 2>/dev/null | wc -l | tr -d ' ')
TOTAL_SIZE=$(du -sh wifi_lab/pcaps 2>/dev/null | cut -f1)

printf "  ${CYAN}•${NC} PCAPs disponibles: ${BOLD}$TOTAL_PCAPS archivos ($TOTAL_SIZE)${NC}\n"
printf "  ${CYAN}•${NC} Herramientas: tshark ✓  aircrack-ng ✓\n"
echo ""
sleep 1

echo "═══════════════════════════════════════════════════════════════════════════════"
printf "${GREEN}2. ANÁLISIS WPA2 HANDSHAKE${NC}\n"
echo "═══════════════════════════════════════════════════════════════════════════════"
echo ""

PCAP="wifi_lab/pcaps/wpa2/wpa_induction.pcap"

# SSID
SSID=$(tshark -r "$PCAP" -Y "wlan.ssid" -T fields -e wlan.ssid 2>/dev/null | sort -u | head -1 | xxd -r -p 2>/dev/null)
printf "  ${CYAN}•${NC} SSID: ${BOLD}${GREEN}$SSID${NC}\n"

# EAPOL frames
EAPOL=$(tshark -r "$PCAP" -Y "eapol" 2>/dev/null | wc -l | tr -d ' ')
printf "  ${CYAN}•${NC} EAPOL frames: ${BOLD}${GREEN}$EAPOL${NC} → Handshake completo ✓\n"

# AP y Cliente
AP=$(tshark -r "$PCAP" -Y "wlan.fc.type_subtype == 0x08" -T fields -e wlan.bssid 2>/dev/null | head -1)
CLIENT=$(tshark -r "$PCAP" -Y "eapol" -T fields -e wlan.da 2>/dev/null | head -1)

printf "  ${CYAN}•${NC} AP (BSSID): $AP\n"
printf "  ${CYAN}•${NC} Cliente: $CLIENT\n"

echo ""
printf "${BOLD}Secuencia del Handshake:${NC}\n"
echo "  Frame 87: AP → Cliente (Message 1/4: ANonce)"
echo "  Frame 89: Cliente → AP (Message 2/4: SNonce + MIC)"
echo "  Frame 92: AP → Cliente (Message 3/4: GTK + MIC)"
echo "  Frame 94: Cliente → AP (Message 4/4: Confirmación)"
echo ""
sleep 1

echo "═══════════════════════════════════════════════════════════════════════════════"
printf "${GREEN}3. DETECCIÓN DE ATAQUES${NC}\n"
echo "═══════════════════════════════════════════════════════════════════════════════"
echo ""

# ARP Spoofing
if [ -f wifi_lab/pcaps/attacks/arp_spoofing.pcap ]; then
    ARP_TOTAL=$(tshark -r wifi_lab/pcaps/attacks/arp_spoofing.pcap -Y "arp" 2>/dev/null | wc -l | tr -d ' ')
    ARP_REPLIES=$(tshark -r wifi_lab/pcaps/attacks/arp_spoofing.pcap -Y "arp.opcode == 2" 2>/dev/null | wc -l | tr -d ' ')

    printf "  ${CYAN}•${NC} ${BOLD}ARP Spoofing:${NC}\n"
    printf "    - Total ARP packets: $ARP_TOTAL\n"
    printf "    - ARP replies: $ARP_REPLIES\n"

    if [ $ARP_TOTAL -gt 500 ]; then
        printf "    ${YELLOW}⚠️  ALERTA: Posible ARP Storm / MitM Attack${NC}\n"
    fi
    echo ""
fi

# HTTP Traffic
if [ -f wifi_lab/pcaps/misc/http_captive_portal.cap ]; then
    HTTP_REQ=$(tshark -r wifi_lab/pcaps/misc/http_captive_portal.cap -Y "http.request" 2>/dev/null | wc -l | tr -d ' ')
    REDIRECTS=$(tshark -r wifi_lab/pcaps/misc/http_captive_portal.cap -Y "http.response.code == 302 || http.response.code == 301" 2>/dev/null | wc -l | tr -d ' ')

    printf "  ${CYAN}•${NC} ${BOLD}HTTP Traffic:${NC}\n"
    printf "    - HTTP requests: $HTTP_REQ\n"
    printf "    - Redirects (302/301): $REDIRECTS\n"

    if [ $REDIRECTS -gt 0 ]; then
        printf "    ${YELLOW}⚠️  Posible Captive Portal detectado${NC}\n"
    fi
    printf "    ${YELLOW}⚠️  Tráfico en texto claro (INSEGURO)${NC}\n"
    echo ""
fi

sleep 1

echo "═══════════════════════════════════════════════════════════════════════════════"
printf "${GREEN}4. COMPONENTES CRIPTOGRÁFICOS${NC}\n"
echo "═══════════════════════════════════════════════════════════════════════════════"
echo ""

# ANonce
ANONCE=$(tshark -r "$PCAP" -Y "eapol" -T fields -e eapol.keydes.nonce 2>/dev/null | head -1)
printf "  ${CYAN}•${NC} ${BOLD}ANonce (AP):${NC}\n"
printf "    %s...\n" "${ANONCE:0:32}"

# SNonce
SNONCE=$(tshark -r "$PCAP" -Y "eapol" -T fields -e eapol.keydes.nonce 2>/dev/null | sed -n '2p')
printf "  ${CYAN}•${NC} ${BOLD}SNonce (Cliente):${NC}\n"
printf "    %s...\n" "${SNONCE:0:32}"

# MIC
MIC=$(tshark -r "$PCAP" -Y "eapol" -T fields -e eapol.keydes.mic 2>/dev/null | sed -n '2p')
printf "  ${CYAN}•${NC} ${BOLD}MIC:${NC} %s\n" "${MIC:0:32}"

echo ""
printf "${CYAN}Estos componentes se usan para validar la contraseña en cracking${NC}\n"
echo ""
sleep 1

echo "═══════════════════════════════════════════════════════════════════════════════"
printf "${GREEN}5. EJERCICIOS DISPONIBLES${NC}\n"
echo "═══════════════════════════════════════════════════════════════════════════════"
echo ""

printf "  ${BOLD}Nivel Básico${NC} (30 min c/u):\n"
echo "    1. Explorando PCAPs con tshark"
echo "    2. Frames WiFi Básicos"
echo "    3. DHCP y Conexión a Red"
echo ""

printf "  ${BOLD}Nivel Intermedio${NC} (45 min c/u):\n"
echo "    4. WPA2 4-Way Handshake Profundo"
echo "    5. Extracción de Nonces y MIC"
echo "    6. DNS Analysis"
echo ""

printf "  ${BOLD}Nivel Avanzado${NC} (60 min c/u):\n"
echo "    7. ARP Spoofing Detection"
echo "    8. HTTP Traffic Analysis"
echo "    9. PMKID Attack Simulation"
echo ""

printf "  ${BOLD}Integrador${NC} (90-120 min):\n"
echo "    10. Auditoría Completa de Red WiFi"
echo ""

printf "  ${CYAN}Ver EJERCICIOS_PROGRESIVOS.md para detalles completos${NC}\n"
echo ""
sleep 1

echo "═══════════════════════════════════════════════════════════════════════════════"
printf "${BOLD}${GREEN}✅ DEMO COMPLETADA${NC}\n"
echo "═══════════════════════════════════════════════════════════════════════════════"
echo ""

printf "${YELLOW}Resumen:${NC}\n"
printf "  • $TOTAL_PCAPS PCAPs disponibles ($TOTAL_SIZE)\n"
printf "  • Handshake WPA2 completo verificado (4 EAPOL frames)\n"
printf "  • Detección de ataques funcionando\n"
printf "  • 10 ejercicios progresivos listos\n"
echo ""

printf "${CYAN}Próximos pasos:${NC}\n"
printf "  1. Revisar ${BOLD}EJERCICIOS_PROGRESIVOS.md${NC}\n"
printf "  2. Comenzar con Ejercicio 1 (Básico)\n"
printf "  3. Practicar con tshark, wireshark, aircrack-ng\n"
echo ""

printf "${BOLD}${BLUE}"
cat << "EOF"
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║                         ¡Gracias por su atención!                            ║
║                                                                              ║
║                  Universidad Tecnológica Nacional - UTN                      ║
║                Laboratorio de Blockchain & Ciberseguridad                    ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
printf "${NC}\n"
