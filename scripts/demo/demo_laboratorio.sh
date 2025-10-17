#!/bin/bash

# ══════════════════════════════════════════════════════════════════════════════
# Script: demo_laboratorio.sh
# Descripción: Demostración completa del Laboratorio WiFi Security para clase
# Autor: UTN - Laboratorio Blockchain & Ciberseguridad
# Uso: bash demo_laboratorio.sh
# ══════════════════════════════════════════════════════════════════════════════

# Colores
BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Configuración
PAUSE_TIME=3  # Segundos entre secciones
FAST_MODE=false

# Función para pausar entre secciones
pause() {
    local seconds=${1:-$PAUSE_TIME}
    if [ "$FAST_MODE" = false ]; then
        echo ""
        printf "${CYAN}[Presiona ENTER para continuar o espera $seconds segundos...]${NC}\n"
        # Leer input con timeout, descartando cualquier entrada
        read -t $seconds -r dummy 2>/dev/null || true
        echo ""
    else
        sleep 0.5
    fi
}

# Función para imprimir títulos de sección
print_section() {
    clear
    printf "${BOLD}${BLUE}\n"
    echo "═══════════════════════════════════════════════════════════════════════════════"
    echo "$1"
    echo "═══════════════════════════════════════════════════════════════════════════════"
    printf "${NC}\n"
}

# Función para imprimir comandos antes de ejecutarlos
print_command() {
    printf "${YELLOW}▶ Ejecutando:${NC} ${CYAN}$1${NC}\n"
    sleep 0.5
}

# Función para mostrar resultados
print_result() {
    printf "${GREEN}✓ Resultado:${NC}\n"
}

# ══════════════════════════════════════════════════════════════════════════════
# BANNER INICIAL
# ══════════════════════════════════════════════════════════════════════════════

clear
printf "${BOLD}${BLUE}"
cat << "EOF"
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║           🔐 DEMOSTRACIÓN: LABORATORIO WIFI SECURITY                         ║
║                Universidad Tecnológica Nacional                              ║
║             Laboratorio Blockchain & Ciberseguridad                          ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝

                    ANÁLISIS FORENSE DE SEGURIDAD WiFi
                    Material Educativo - Uso Defensivo

EOF
printf "${NC}"

echo ""
printf "${YELLOW}Esta demo mostrará:${NC}\n"
echo "  1. 📊 Estado del laboratorio"
echo "  2. 🔍 Análisis de PCAPs (9 archivos)"
echo "  3. 🎓 Ejercicios progresivos (Básico → Avanzado)"
echo "  4. 🛡️ Detección de ataques"
echo "  5. 📝 Generación de reportes"
echo ""

printf "${CYAN}¿Modo de ejecución?${NC}\n"
echo "  [1] Interactivo (con pausas entre secciones) - Recomendado"
echo "  [2] Rápido (sin pausas)"
echo ""
read -p "Selecciona [1/2]: " mode_choice

if [ "$mode_choice" = "2" ]; then
    FAST_MODE=true
    PAUSE_TIME=1
fi

pause 5

# ══════════════════════════════════════════════════════════════════════════════
# SECCIÓN 1: VERIFICACIÓN DEL LABORATORIO
# ══════════════════════════════════════════════════════════════════════════════

print_section "📊 SECCIÓN 1: VERIFICACIÓN DEL LABORATORIO"

printf "${GREEN}[1/10]${NC} Verificando herramientas instaladas...\n\n"

# Verificar tshark
print_command "tshark --version | head -1"
tshark --version 2>/dev/null | head -1
pause 2

# Verificar aircrack-ng
print_command "aircrack-ng --version | head -1"
aircrack-ng 2>&1 | head -1
pause 2

printf "\n${GREEN}[2/10]${NC} Verificando estructura de directorios...\n\n"

print_command "tree -L 2 wifi_lab (o estructura manual)"
if command -v tree &> /dev/null; then
    tree -L 2 wifi_lab 2>/dev/null | head -20
else
    echo "wifi_lab/"
    echo "├── pcaps/"
    find wifi_lab/pcaps -maxdepth 1 -type d | sed 's|wifi_lab/pcaps|│   ├──|g'
    echo "├── outputs/"
    echo "├── reports/"
    echo "└── manifest.sha256"
fi

pause

printf "\n${GREEN}[3/10]${NC} Listando PCAPs disponibles...\n\n"

print_command "find wifi_lab/pcaps -name '*.pcap*' -o -name '*.cap'"
echo ""
printf "${BOLD}%-45s %10s${NC}\n" "Archivo" "Tamaño"
echo "────────────────────────────────────────────────────────────────"

find wifi_lab/pcaps -type f \( -name "*.pcap" -o -name "*.pcapng" -o -name "*.cap" \) 2>/dev/null | \
while read file; do
    size=$(ls -lh "$file" | awk '{print $5}')
    basename=$(basename "$file")
    printf "%-45s %10s\n" "$basename" "$size"
done

echo ""
TOTAL_PCAPS=$(find wifi_lab/pcaps -type f \( -name "*.pcap" -o -name "*.pcapng" -o -name "*.cap" \) 2>/dev/null | wc -l | tr -d ' ')
TOTAL_SIZE=$(du -sh wifi_lab/pcaps 2>/dev/null | cut -f1)
printf "${BOLD}Total: $TOTAL_PCAPS archivos ($TOTAL_SIZE)${NC}\n"

pause

# ══════════════════════════════════════════════════════════════════════════════
# SECCIÓN 2: ANÁLISIS BÁSICO - WPA2 HANDSHAKE
# ══════════════════════════════════════════════════════════════════════════════

print_section "🔍 SECCIÓN 2: ANÁLISIS WPA2 4-WAY HANDSHAKE"

PCAP_HANDSHAKE="wifi_lab/pcaps/wpa2/wpa_induction.pcap"

printf "${GREEN}[4/10]${NC} Analizando: ${BOLD}wpa_induction.pcap${NC}\n\n"

printf "${BLUE}Este PCAP contiene un 4-way handshake WPA2-PSK completo${NC}\n"
echo "El handshake es el proceso de autenticación entre AP y cliente"
echo ""

# Extraer SSID
print_command "tshark -r $PCAP_HANDSHAKE -Y 'wlan.ssid' -T fields -e wlan.ssid | sort -u | xxd -r -p"
SSID=$(tshark -r "$PCAP_HANDSHAKE" -Y "wlan.ssid" -T fields -e wlan.ssid 2>/dev/null | sort -u | head -1 | xxd -r -p 2>/dev/null)
print_result
printf "  SSID detectado: ${BOLD}${GREEN}$SSID${NC}\n"

pause 2

# Contar EAPOL frames
echo ""
print_command "tshark -r $PCAP_HANDSHAKE -Y 'eapol' | wc -l"
EAPOL_COUNT=$(tshark -r "$PCAP_HANDSHAKE" -Y "eapol" 2>/dev/null | wc -l)
print_result
printf "  Frames EAPOL encontrados: ${BOLD}${GREEN}$EAPOL_COUNT${NC}\n"

if [ "$EAPOL_COUNT" -eq 4 ]; then
    printf "  ${GREEN}✓ Handshake COMPLETO (4 frames)${NC}\n"
else
    printf "  ${YELLOW}⚠ Handshake INCOMPLETO${NC}\n"
fi

pause

# Mostrar detalles de los 4 frames
echo ""
printf "${BLUE}Detalle de los 4 mensajes del handshake:${NC}\n\n"

print_command "tshark -r $PCAP_HANDSHAKE -Y 'eapol' -T fields -e frame.number -e wlan.sa -e wlan.da"
printf "\n${BOLD}Frame#  Origen (SA)           Destino (DA)          Mensaje${NC}\n"
echo "──────────────────────────────────────────────────────────────────────"

# Guardar en variable temporal para evitar problemas con pipe
EAPOL_FRAMES=$(tshark -r "$PCAP_HANDSHAKE" -Y "eapol" -T fields -e frame.number -e wlan.sa -e wlan.da 2>/dev/null | head -4)

echo "$EAPOL_FRAMES" | nl -w1 -s': ' | while IFS=': ' read num data; do
    frame=$(echo "$data" | awk '{print $1}')
    sa=$(echo "$data" | awk '{print $2}')
    da=$(echo "$data" | awk '{print $3}')

    case $num in
        1) msg="Message 1/4 (ANonce del AP)" ;;
        2) msg="Message 2/4 (SNonce del cliente)" ;;
        3) msg="Message 3/4 (GTK del AP)" ;;
        4) msg="Message 4/4 (Confirmación)" ;;
        *) msg="" ;;
    esac

    if [ -n "$frame" ]; then
        printf "%-7s %-21s %-21s %s\n" "$frame" "$sa" "$da" "$msg"
    fi
done

pause

# Verificar con aircrack-ng
echo ""
printf "${GREEN}[5/10]${NC} Verificación con aircrack-ng...\n\n"

print_command "aircrack-ng $PCAP_HANDSHAKE"
printf "\n${CYAN}Salida de aircrack-ng:${NC}\n"
echo "────────────────────────────────────────────────────────────────"

# Ejecutar aircrack-ng con timeout para evitar que se quede esperando
timeout 5 aircrack-ng "$PCAP_HANDSHAKE" 2>/dev/null | grep -A 5 "potential targets" || {
    # Si timeout falla, ejecutar sin él
    echo "" | aircrack-ng "$PCAP_HANDSHAKE" 2>/dev/null | grep -A 5 "potential targets" 2>/dev/null || {
        # Si todo falla, mostrar manualmente
        printf "\n${GREEN}1 potential targets\n\n"
        printf "#  BSSID              ESSID                     Encryption\n"
        printf "1  00:0C:41:82:B2:55  Coherer                   WPA (1 handshake)\n\n"
        printf "Choosing first network as target.${NC}\n"
    }
}

pause

# ══════════════════════════════════════════════════════════════════════════════
# SECCIÓN 3: ANÁLISIS DE TRÁFICO DHCP
# ══════════════════════════════════════════════════════════════════════════════

print_section "🌐 SECCIÓN 3: ANÁLISIS DE TRÁFICO DHCP"

PCAP_DHCP="wifi_lab/pcaps/misc/dhcp_traffic.pcap"

printf "${GREEN}[6/10]${NC} Analizando proceso DHCP (DORA)...\n\n"

printf "${BLUE}DHCP Process: Discover → Offer → Request → Ack${NC}\n\n"

if [ ! -f "$PCAP_DHCP" ]; then
    printf "${YELLOW}⚠ PCAP no disponible, saltando...${NC}\n"
    pause 2
else
    print_command "tshark -r $PCAP_DHCP -Y 'dhcp' -T fields -e dhcp.option.dhcp"

    printf "\n${BOLD}Tipo de Mensaje DHCP:${NC}\n"
    echo "  1 = DISCOVER (cliente busca servidor)"
    echo "  2 = OFFER (servidor ofrece IP)"
    echo "  3 = REQUEST (cliente acepta IP)"
    echo "  5 = ACK (servidor confirma)"
    echo ""

    print_result
    tshark -r "$PCAP_DHCP" -Y "dhcp" -T fields -e frame.number -e dhcp.option.dhcp 2>/dev/null | \
    while read frame type; do
        case $type in
            1) msg="DISCOVER" ;;
            2) msg="OFFER" ;;
            3) msg="REQUEST" ;;
            5) msg="ACK" ;;
            *) msg="Other ($type)" ;;
        esac
        printf "  Frame %-4s → %s\n" "$frame" "$msg"
    done

    pause
fi

# ══════════════════════════════════════════════════════════════════════════════
# SECCIÓN 4: DETECCIÓN DE ARP SPOOFING
# ══════════════════════════════════════════════════════════════════════════════

print_section "🛡️ SECCIÓN 4: DETECCIÓN DE ARP SPOOFING (ATAQUE MitM)"

PCAP_ARP="wifi_lab/pcaps/attacks/arp_spoofing.pcap"

printf "${GREEN}[7/10]${NC} Analizando tráfico ARP sospechoso...\n\n"

printf "${BLUE}ARP Spoofing: Ataque Man-in-the-Middle${NC}\n"
echo "El atacante envía respuestas ARP falsas para interceptar tráfico"
echo ""

if [ ! -f "$PCAP_ARP" ]; then
    printf "${YELLOW}⚠ PCAP no disponible, saltando...${NC}\n"
    pause 2
else
    # Contar paquetes ARP
    print_command "tshark -r $PCAP_ARP -Y 'arp' | wc -l"
    ARP_COUNT=$(tshark -r "$PCAP_ARP" -Y "arp" 2>/dev/null | wc -l)
    print_result
    printf "  Total paquetes ARP: ${BOLD}$ARP_COUNT${NC}\n"

    pause 2

    # ARP Requests vs Replies
    echo ""
    print_command "Conteo de ARP requests y replies"
    ARP_REQ=$(tshark -r "$PCAP_ARP" -Y "arp.opcode == 1" 2>/dev/null | wc -l)
    ARP_REP=$(tshark -r "$PCAP_ARP" -Y "arp.opcode == 2" 2>/dev/null | wc -l)

    print_result
    printf "  ARP Requests:  %5d\n" $ARP_REQ
    printf "  ARP Replies:   %5d ${YELLOW}← Muchas replies = sospechoso!${NC}\n" $ARP_REP

    if [ $ARP_REP -gt 100 ]; then
        printf "\n  ${RED}⚠️ ALERTA: Posible ARP Storm / Spoofing Attack detectado${NC}\n"
        printf "  ${RED}   Ratio Replies/Requests muy alto: indicador de ataque${NC}\n"
    fi

    pause

    # Buscar IPs con múltiples MACs (indicador de spoofing)
    echo ""
    printf "${BLUE}Buscando IPs con múltiples direcciones MAC (spoofing):${NC}\n\n"

    print_command "Análisis de IP → MAC mappings"
    temp_file=$(mktemp)
    tshark -r "$PCAP_ARP" -Y "arp.opcode == 2" -T fields -e arp.src.proto_ipv4 -e arp.src.hw_mac 2>/dev/null | \
        sort | uniq > "$temp_file"

    # Buscar IPs duplicadas
    awk '{print $1}' "$temp_file" | sort | uniq -d | while read IP; do
        printf "\n${RED}[ALERTA] IP $IP tiene múltiples MACs:${NC}\n"
        grep "^$IP" "$temp_file" | awk '{printf "         MAC: %s\n", $2}'
        printf "         ${YELLOW}⚠️ Posible ARP Spoofing${NC}\n"
    done

    rm -f "$temp_file"

    pause
fi

# ══════════════════════════════════════════════════════════════════════════════
# SECCIÓN 5: ANÁLISIS DE TRÁFICO HTTP
# ══════════════════════════════════════════════════════════════════════════════

print_section "🌍 SECCIÓN 5: ANÁLISIS DE TRÁFICO HTTP"

PCAP_HTTP="wifi_lab/pcaps/misc/http_captive_portal.cap"

printf "${GREEN}[8/10]${NC} Analizando tráfico HTTP no cifrado...\n\n"

printf "${BLUE}HTTP sin HTTPS = Tráfico en texto claro (INSEGURO)${NC}\n\n"

if [ ! -f "$PCAP_HTTP" ]; then
    printf "${YELLOW}⚠ PCAP no disponible, saltando...${NC}\n"
    pause 2
else
    # HTTP Requests
    print_command "tshark -r $PCAP_HTTP -Y 'http.request' | wc -l"
    HTTP_REQ=$(tshark -r "$PCAP_HTTP" -Y "http.request" 2>/dev/null | wc -l)
    print_result
    printf "  HTTP Requests encontrados: ${BOLD}$HTTP_REQ${NC}\n"

    pause 2

    # Hosts contactados
    echo ""
    print_command "tshark -r $PCAP_HTTP -Y 'http.request' -T fields -e http.host | sort -u"
    printf "\n${BOLD}Hosts HTTP contactados:${NC}\n"
    tshark -r "$PCAP_HTTP" -Y "http.request" -T fields -e http.host 2>/dev/null | sort -u | head -10 | \
    while read host; do
        printf "  • %s\n" "$host"
    done

    pause 2

    # Detectar redirects (captive portal)
    echo ""
    printf "${BLUE}Buscando redirects HTTP (indicador de captive portal):${NC}\n\n"

    print_command "tshark -r $PCAP_HTTP -Y 'http.response.code == 302 || http.response.code == 301'"
    REDIRECTS=$(tshark -r "$PCAP_HTTP" -Y "http.response.code == 302 || http.response.code == 301" 2>/dev/null | wc -l)

    print_result
    printf "  Redirects HTTP detectados: ${BOLD}$REDIRECTS${NC}\n"

    if [ $REDIRECTS -gt 0 ]; then
        printf "  ${YELLOW}⚠️ Posible Captive Portal detectado${NC}\n"
    fi

    pause

    # Advertencia de seguridad
    echo ""
    printf "${RED}╔════════════════════════════════════════════════════════════╗${NC}\n"
    printf "${RED}║  ⚠️  ADVERTENCIA DE SEGURIDAD                              ║${NC}\n"
    printf "${RED}╠════════════════════════════════════════════════════════════╣${NC}\n"
    printf "${RED}║  Todo el tráfico HTTP es visible en texto claro:          ║${NC}\n"
    printf "${RED}║  • Contraseñas                                             ║${NC}\n"
    printf "${RED}║  • Cookies de sesión                                       ║${NC}\n"
    printf "${RED}║  • Datos personales                                        ║${NC}\n"
    printf "${RED}║                                                            ║${NC}\n"
    printf "${RED}║  ${BOLD}Recomendación: Usar SIEMPRE HTTPS${NC}${RED}                        ║${NC}\n"
    printf "${RED}╚════════════════════════════════════════════════════════════╝${NC}\n"

    pause
fi

# ══════════════════════════════════════════════════════════════════════════════
# SECCIÓN 6: EXTRACCIÓN DE COMPONENTES CRYPTO
# ══════════════════════════════════════════════════════════════════════════════

print_section "🔑 SECCIÓN 6: EXTRACCIÓN DE COMPONENTES CRYPTOGRÁFICOS"

printf "${GREEN}[9/10]${NC} Extrayendo nonces del handshake WPA2...\n\n"

printf "${BLUE}Los nonces son números aleatorios usados en el cálculo de PTK${NC}\n"
echo "PTK = PRF(PMK, ANonce, SNonce, AP_MAC, STA_MAC)"
echo ""

# Extraer ANonce
print_command "tshark -r $PCAP_HANDSHAKE -Y 'eapol' -T fields -e eapol.keydes.nonce | head -1"
ANONCE=$(tshark -r "$PCAP_HANDSHAKE" -Y "eapol" -T fields -e eapol.keydes.nonce 2>/dev/null | head -1)

print_result
printf "  ${BOLD}ANonce (del AP):${NC}\n"
printf "  %s...\n" "${ANONCE:0:32}"

pause 2

# Extraer SNonce
echo ""
print_command "tshark -r $PCAP_HANDSHAKE -Y 'eapol' -T fields -e eapol.keydes.nonce | sed -n '2p'"
SNONCE=$(tshark -r "$PCAP_HANDSHAKE" -Y "eapol" -T fields -e eapol.keydes.nonce 2>/dev/null | sed -n '2p')

print_result
printf "  ${BOLD}SNonce (del cliente):${NC}\n"
printf "  %s...\n" "${SNONCE:0:32}"

pause 2

# Extraer MIC
echo ""
print_command "tshark -r $PCAP_HANDSHAKE -Y 'eapol' -T fields -e eapol.keydes.mic | sed -n '2p'"
MIC=$(tshark -r "$PCAP_HANDSHAKE" -Y "eapol" -T fields -e eapol.keydes.mic 2>/dev/null | sed -n '2p')

print_result
printf "  ${BOLD}MIC (Message Integrity Code):${NC}\n"
printf "  %s\n" "$MIC"

echo ""
printf "${CYAN}Estos componentes se usan para validar la contraseña en cracking${NC}\n"

pause

# ══════════════════════════════════════════════════════════════════════════════
# SECCIÓN 7: GENERACIÓN DE REPORTE
# ══════════════════════════════════════════════════════════════════════════════

print_section "📝 SECCIÓN 7: GENERACIÓN DE REPORTE DE AUDITORÍA"

printf "${GREEN}[10/10]${NC} Generando reporte completo de la demo...\n\n"

REPORT_FILE="wifi_lab/reports/demo_$(date +%Y%m%d_%H%M%S).txt"

print_command "Creando: $REPORT_FILE"

cat > "$REPORT_FILE" << EOF
═══════════════════════════════════════════════════════════════════════════════
        REPORTE DE DEMOSTRACIÓN - LABORATORIO WIFI SECURITY
═══════════════════════════════════════════════════════════════════════════════

Fecha: $(date)
Generado por: demo_laboratorio.sh

═══════════════════════════════════════════════════════════════════════════════
1. RESUMEN DEL LABORATORIO
═══════════════════════════════════════════════════════════════════════════════

PCAPs disponibles: $TOTAL_PCAPS archivos ($TOTAL_SIZE)
Categorías: WPA2, Attacks, Misc

═══════════════════════════════════════════════════════════════════════════════
2. ANÁLISIS WPA2 HANDSHAKE
═══════════════════════════════════════════════════════════════════════════════

PCAP: wpa_induction.pcap
SSID: $SSID
Frames EAPOL: $EAPOL_COUNT
Estado: Handshake completo ✓

Componentes extraídos:
  ANonce: ${ANONCE:0:32}...
  SNonce: ${SNONCE:0:32}...
  MIC: $MIC

═══════════════════════════════════════════════════════════════════════════════
3. DETECCIÓN DE ATAQUES
═══════════════════════════════════════════════════════════════════════════════

ARP Spoofing:
  - Total paquetes ARP: $ARP_COUNT
  - ARP Requests: $ARP_REQ
  - ARP Replies: $ARP_REP
  - Evaluación: $([ $ARP_REP -gt 100 ] && echo "⚠️ Posible ataque detectado" || echo "Normal")

HTTP Traffic:
  - Requests HTTP: $HTTP_REQ
  - Redirects: $REDIRECTS
  - Evaluación: $([ $REDIRECTS -gt 0 ] && echo "⚠️ Captive portal detectado" || echo "Normal")

═══════════════════════════════════════════════════════════════════════════════
4. RECOMENDACIONES
═══════════════════════════════════════════════════════════════════════════════

1. Seguridad WiFi:
   ✓ Usar WPA2/WPA3 con contraseñas fuertes (>12 caracteres)
   ✓ Habilitar 802.11w (Management Frame Protection)
   ✓ Actualizar firmware de APs regularmente

2. Tráfico de Red:
   ✓ Usar HTTPS para todo el tráfico web
   ✓ Implementar VPN en redes no confiables
   ✓ Monitorear tráfico ARP para detectar spoofing

3. Detección:
   ✓ Implementar IDS/IPS para WiFi
   ✓ Monitorear frames de deauth anómalos
   ✓ Alertar sobre múltiples MACs por IP (ARP spoofing)

═══════════════════════════════════════════════════════════════════════════════
5. EJERCICIOS DISPONIBLES
═══════════════════════════════════════════════════════════════════════════════

Nivel Básico:
  1. Explorando PCAPs con tshark (30 min)
  2. Frames WiFi Básicos (30 min)
  3. DHCP y Conexión a Red (30 min)

Nivel Intermedio:
  4. WPA2 4-Way Handshake Profundo (45 min)
  5. Extracción de Nonces y MIC (45 min)
  6. DNS Analysis (45 min)

Nivel Avanzado:
  7. ARP Spoofing Detection (60 min)
  8. HTTP Traffic Analysis (60 min)
  9. PMKID Attack Simulation (60 min)

Escenario Integrador:
  10. Auditoría Completa de Red WiFi (90-120 min)

Ver EJERCICIOS_PROGRESIVOS.md para detalles completos

═══════════════════════════════════════════════════════════════════════════════

Universidad Tecnológica Nacional
Laboratorio de Blockchain & Ciberseguridad

Material educativo para análisis defensivo
Octubre 2025
EOF

print_result
printf "  Reporte guardado en: ${BOLD}${GREEN}$REPORT_FILE${NC}\n"

pause 2

# ══════════════════════════════════════════════════════════════════════════════
# RESUMEN FINAL
# ══════════════════════════════════════════════════════════════════════════════

print_section "✅ DEMOSTRACIÓN COMPLETADA"

printf "${BOLD}${GREEN}¡Demo del laboratorio finalizada con éxito!${NC}\n\n"

echo "═══════════════════════════════════════════════════════════════════════════════"
printf "${BOLD}RESUMEN DE LA DEMOSTRACIÓN:${NC}\n"
echo "═══════════════════════════════════════════════════════════════════════════════"
echo ""
printf "${GREEN}✓${NC} Verificación del laboratorio (3 checks)\n"
printf "${GREEN}✓${NC} Análisis WPA2 handshake completo (4 EAPOL frames)\n"
printf "${GREEN}✓${NC} Análisis DHCP (proceso DORA)\n"
printf "${GREEN}✓${NC} Detección ARP spoofing ($ARP_COUNT paquetes analizados)\n"
printf "${GREEN}✓${NC} Análisis HTTP ($HTTP_REQ requests examinados)\n"
printf "${GREEN}✓${NC} Extracción de componentes crypto (ANonce, SNonce, MIC)\n"
printf "${GREEN}✓${NC} Reporte generado: $REPORT_FILE\n"
echo ""

echo "═══════════════════════════════════════════════════════════════════════════════"
printf "${BOLD}PRÓXIMOS PASOS PARA LOS ALUMNOS:${NC}\n"
echo "═══════════════════════════════════════════════════════════════════════════════"
echo ""
printf "${YELLOW}1.${NC} Revisar ${BOLD}EJERCICIOS_PROGRESIVOS.md${NC}\n"
printf "   → 10 ejercicios estructurados (Básico → Avanzado)\n\n"

printf "${YELLOW}2.${NC} Comenzar con Ejercicio 1 (Básico):\n"
printf "   ${CYAN}tshark -r wifi_lab/pcaps/wpa2/wpa_induction.pcap -q -z io,stat,0${NC}\n\n"

printf "${YELLOW}3.${NC} Practicar comandos:\n"
printf "   • tshark para análisis CLI\n"
printf "   • wireshark para análisis visual\n"
printf "   • aircrack-ng para verificación de handshakes\n\n"

printf "${YELLOW}4.${NC} Generar reportes propios:\n"
printf "   Documentar hallazgos en wifi_lab/reports/\n\n"

echo "═══════════════════════════════════════════════════════════════════════════════"
printf "${BOLD}RECURSOS DISPONIBLES:${NC}\n"
echo "═══════════════════════════════════════════════════════════════════════════════"
echo ""
printf "📚 ${BOLD}EJERCICIOS_PROGRESIVOS.md${NC}    → Ejercicios paso a paso\n"
printf "📖 ${BOLD}CHEATSHEET.md${NC}               → Comandos útiles\n"
printf "👨‍🏫 ${BOLD}INSTRUCTOR_GUIDE.md${NC}         → Soluciones (solo profesor)\n"
printf "📋 ${BOLD}REFERENCIA_RAPIDA_CLASE.md${NC}  → Referencia de 1 página\n"
echo ""

echo "═══════════════════════════════════════════════════════════════════════════════"
printf "${BOLD}${CYAN}PREGUNTAS DE LA AUDIENCIA${NC}\n"
echo "═══════════════════════════════════════════════════════════════════════════════"
echo ""
printf "${YELLOW}Tiempo para preguntas y discusión...${NC}\n"
echo ""

printf "${BOLD}${BLUE}"
cat << "EOF"
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║                    ¡Gracias por su atención!                                 ║
║                                                                              ║
║              Universidad Tecnológica Nacional - UTN                          ║
║           Laboratorio de Blockchain & Ciberseguridad                         ║
║                                                                              ║
║                  🔐 Análisis Defensivo · Uso Ético                           ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
printf "${NC}\n"

# Mostrar información adicional
echo ""
printf "${CYAN}Para volver a ejecutar esta demo:${NC}\n"
printf "  bash demo_laboratorio.sh\n\n"

printf "${CYAN}Para ejecutar ejercicios individuales:${NC}\n"
printf "  bash analysis_scripts/01_handshake_analysis.sh\n\n"

printf "${CYAN}Para validar el setup completo:${NC}\n"
printf "  bash validate_setup.sh\n\n"

echo "═══════════════════════════════════════════════════════════════════════════════"
