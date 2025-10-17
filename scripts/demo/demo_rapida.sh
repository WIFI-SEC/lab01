#!/usr/bin/env bash

# ══════════════════════════════════════════════════════════════════════════════
# Script: demo_rapida.sh
# Descripción: Demo rápida (5 minutos) del laboratorio WiFi para presentaciones
# Uso: bash demo_rapida.sh
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
║                  DEMO RÁPIDA: LABORATORIO WIFI SECURITY                      ║
║                     Universidad Tecnológica Nacional                         ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
printf "${NC}\n"

echo "⏱️  Demo de 5 minutos - Highlights del laboratorio"
echo ""
sleep 2

# 1. PCAPs disponibles
printf "${GREEN}▶ 1/5${NC} PCAPs disponibles:\n"
find wifi_lab/pcaps -name "*.pcap*" -o -name "*.cap" | wc -l | xargs printf "  %s archivos (" && du -sh wifi_lab/pcaps | cut -f1 | xargs printf "%s)\n"
sleep 2

# 2. WPA2 Handshake
printf "\n${GREEN}▶ 2/5${NC} WPA2 Handshake:\n"
printf "  SSID: ${BOLD}"
tshark -r wifi_lab/pcaps/wpa2/wpa_induction.pcap -Y "wlan.ssid" -T fields -e wlan.ssid 2>/dev/null | sort -u | head -1 | xxd -r -p
printf "${NC}\n"
tshark -r wifi_lab/pcaps/wpa2/wpa_induction.pcap -Y "eapol" 2>/dev/null | wc -l | xargs printf "  EAPOL frames: ${BOLD}%s${NC} → Handshake completo ✓\n"
sleep 2

# 3. ARP Spoofing
if [ -f wifi_lab/pcaps/attacks/arp_spoofing.pcap ]; then
    printf "\n${GREEN}▶ 3/5${NC} ARP Spoofing Detection:\n"
    tshark -r wifi_lab/pcaps/attacks/arp_spoofing.pcap -Y "arp" 2>/dev/null | wc -l | xargs printf "  ARP packets: ${BOLD}%s${NC}\n"
    tshark -r wifi_lab/pcaps/attacks/arp_spoofing.pcap -Y "arp.opcode == 2" 2>/dev/null | wc -l | xargs printf "  ARP replies: ${BOLD}%s${NC} ${YELLOW}← Storm detectado!${NC}\n"
else
    printf "\n${GREEN}▶ 3/5${NC} ARP Spoofing: PCAP no disponible\n"
fi
sleep 2

# 4. HTTP Traffic
if [ -f wifi_lab/pcaps/misc/http_captive_portal.cap ]; then
    printf "\n${GREEN}▶ 4/5${NC} HTTP Traffic:\n"
    tshark -r wifi_lab/pcaps/misc/http_captive_portal.cap -Y "http.request" 2>/dev/null | wc -l | xargs printf "  HTTP requests: ${BOLD}%s${NC}\n"
    printf "  ${YELLOW}⚠️ Tráfico en texto claro (inseguro)${NC}\n"
else
    printf "\n${GREEN}▶ 4/5${NC} HTTP Traffic: PCAP no disponible\n"
fi
sleep 2

# 5. Ejercicios disponibles
printf "\n${GREEN}▶ 5/5${NC} Ejercicios disponibles:\n"
echo "  📘 Básicos (3): 30 min c/u"
echo "  📙 Intermedios (3): 45 min c/u"
echo "  📕 Avanzados (3): 60 min c/u"
echo "  🎯 Integrador (1): 90-120 min"
echo ""
printf "  ${BOLD}Total: 10 ejercicios progresivos (~8h material)${NC}\n"
sleep 2

# Resumen
echo ""
printf "${CYAN}═══════════════════════════════════════════════════════════════${NC}\n"
printf "${BOLD}✅ Demo completa${NC}\n"
printf "${CYAN}═══════════════════════════════════════════════════════════════${NC}\n"
echo ""
echo "📚 Ver EJERCICIOS_PROGRESIVOS.md para ejercicios completos"
echo "🎓 Ejecutar: bash demo_laboratorio.sh (demo completa ~15 min)"
echo ""
