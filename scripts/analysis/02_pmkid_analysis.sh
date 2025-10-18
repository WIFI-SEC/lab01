#!/usr/bin/env bash

# ======================================================
# Ejercicio 2: Análisis de PMKID Attack
# ======================================================
# Compatibilidad: Linux, macOS, Windows (WSL2 / Git Bash)
PCAP_DIR="./wifi_lab/pcaps/wpa2"
OUTPUT_DIR="./wifi_lab/outputs"

# Función auxiliar para formatear tablas (compatible sin 'column')
format_table() {
    if command -v column >/dev/null 2>&1; then
        column -t -s'|'
    else
        cat  # Si no hay column, mostrar tal cual
    fi
}

echo "=========================================="
echo "  Ejercicio 2: PMKID Attack Analysis"
echo "=========================================="
echo ""

# Verificar tshark
if ! command -v tshark >/dev/null 2>&1; then
    echo "[!] Error: tshark no está instalado."
    exit 1
fi

# Buscar PCAP de PMKID
PCAP_FILE=$(find "$PCAP_DIR" -name "*pmkid*" | head -1)

if [ ! -f "$PCAP_FILE" ]; then
    echo "[!] No se encontró archivo PCAP de PMKID"
    exit 1
fi

echo "Archivo: $PCAP_FILE"
echo ""

# ==========================================
# TEORÍA: ¿Qué es PMKID?
# ==========================================
cat << 'THEORY'
--- TEORÍA: PMKID Attack ---

PMKID = Pairwise Master Key Identifier

El PMKID se encuentra en el primer mensaje del 4-way handshake (EAPOL frame 1)
y también en algunos Robust Security Network (RSN) frames.

Fórmula: PMKID = HMAC-SHA1-128(PMK, "PMK Name" || MAC_AP || MAC_STA)

VENTAJA: No requiere capturar cliente conectándose, solo frame del AP.
DESVENTAJA: No todos los APs son vulnerables (depende de la implementación).

Descubierto por: Jens "atom" Steube (Hashcat) en 2018

THEORY
echo ""

# ==========================================
# TAREA 1: Identificar PMKID en el PCAP
# ==========================================
echo "--- TAREA 1: Buscar PMKID ---"
echo ""

echo "Frames con RSN Information Element:"
tshark -r "$PCAP_FILE" -Y "wlan.rsn.pmkid" -T fields \
    -e frame.number \
    -e wlan.sa \
    -e wlan.da \
    -e wlan.rsn.pmkid 2>/dev/null | \
    awk '{if($4) printf "Frame %s: AP=%s Client=%s PMKID=%s\n", $1, $2, $3, $4}'

PMKID_COUNT=$(tshark -r "$PCAP_FILE" -Y "wlan.rsn.pmkid" 2>/dev/null | wc -l)
echo ""
echo "Total de frames con PMKID: $PMKID_COUNT"
echo ""

# ==========================================
# TAREA 2: Extraer información del AP
# ==========================================
echo "--- TAREA 2: Información del Access Point ---"
echo ""

echo "SSID:"
tshark -r "$PCAP_FILE" -Y "wlan.ssid" -T fields -e wlan.ssid 2>/dev/null | grep -v "^$" | sort -u

echo ""
echo "BSSID (MAC del AP):"
AP_MAC=$(tshark -r "$PCAP_FILE" -Y "wlan.fc.type_subtype == 0x08" -T fields -e wlan.bssid 2>/dev/null | head -1)
echo "$AP_MAC"

echo ""
echo "Canal WiFi:"
tshark -r "$PCAP_FILE" -Y "wlan.fc.type_subtype == 0x08" -T fields -e wlan_radio.channel 2>/dev/null | sort -u

echo ""
echo "Tipo de cifrado:"
tshark -r "$PCAP_FILE" -Y "wlan.rsn.capabilities" -T fields -e wlan.rsn.pcs.type -e wlan.rsn.akms.type 2>/dev/null | head -1

echo ""

# ==========================================
# TAREA 3: Exportar PMKID para hashcat
# ==========================================
echo "--- TAREA 3: Exportar PMKID para análisis ---"
echo ""

OUTPUT_FILE="$OUTPUT_DIR/pmkid_hashes.txt"

# Método 1: Usar hcxpcapngtool (recomendado)
if command -v hcxpcapngtool >/dev/null 2>&1; then
    hcxpcapngtool -o "$OUTPUT_FILE" "$PCAP_FILE" 2>/dev/null

    if [ -f "$OUTPUT_FILE" ]; then
        echo "[✓] PMKIDs exportados a: $OUTPUT_FILE"
        echo ""
        echo "Contenido:"
        cat "$OUTPUT_FILE"
    fi
else
    echo "[!] hcxpcapngtool no instalado"
    echo "    Instalar: brew install hcxtools (macOS) o apt install hcxtools (Linux)"
fi

echo ""

# Método 2: Extracción manual con tshark
echo "Extracción manual de campos necesarios para PMKID:"
echo ""

tshark -r "$PCAP_FILE" -Y "wlan.rsn.pmkid" -T fields \
    -e wlan.rsn.pmkid \
    -e wlan.bssid \
    -e wlan.sa \
    -e wlan.ssid 2>/dev/null | \
    awk '{if($1) printf "PMKID=%s AP_MAC=%s CLIENT_MAC=%s SSID=%s\n", $1, $2, $3, $4}' | head -5

echo ""

# ==========================================
# TAREA 4: Análisis defensivo
# ==========================================
echo "--- TAREA 4: Detección y Mitigación ---"
echo ""

cat << 'DEFENSIVE'
DETECCIÓN de PMKID attacks en tu red:

1. Monitorear association requests anómalos:
   - Múltiples association requests desde la misma MAC
   - Requests sin posterior autenticación completa

2. Buscar patrones de reconocimiento:
   - Escaneos rápidos de múltiples SSIDs
   - Probes dirigidos a tu SSID específico

3. Alertas en IDS/IPS:
   - Suricata/Snort rules para detectar captures pasivos sospechosos

MITIGACIÓN:

✓ Usar WPA3 (no vulnerable a PMKID attack)
✓ Contraseñas robustas (>12 caracteres, alfanuméricos + símbolos)
✓ Actualizar firmware del AP (algunos vendors parchearon esto)
✓ Implementar 802.1X (WPA2-Enterprise) en lugar de PSK
✓ Monitoreo continuo con WIDS (Wireless Intrusion Detection System)

DEFENSIVE

# ==========================================
# TAREA 5: Comparación con handshake
# ==========================================
echo ""
echo "--- TAREA 5: PMKID vs 4-Way Handshake ---"
echo ""

cat << 'COMPARISON' | format_table
Aspecto|PMKID|4-Way Handshake
Requiere cliente|NO|SÍ
Frames necesarios|1|4
Ataques DoS previos|NO|SÍ (deauth)
Detectabilidad|BAJA|MEDIA
Compatibilidad APs|Parcial|Total
Velocidad|Rápida|Media
COMPARISON

echo ""

# ==========================================
# PREGUNTAS PARA LOS ALUMNOS
# ==========================================
cat << 'EOF'

========================================
PREGUNTAS PARA RESPONDER:
========================================

1. ¿Qué información necesitas para crackear un PMKID?
   - PMKID hash: _______
   - MAC del AP: _______
   - MAC del cliente: _______
   - SSID: _______

2. ¿Por qué PMKID es menos detectable que capturar handshakes?
   Respuesta: _______

3. ¿Qué comando usarías para extraer PMKIDs con hcxpcapngtool?
   Comando: _______

4. ¿Cómo verificarías si tu AP es vulnerable a PMKID attack?
   Respuesta: _______

5. ¿Qué diferencia hay entre PMK, PMKID y PTK?
   - PMK: _______
   - PMKID: _______
   - PTK: _______

EJERCICIO PRÁCTICO:

Usando el PCAP, identifica:
- ¿Cuántos PMKIDs únicos hay?
- ¿Corresponden a un solo AP o múltiples?
- ¿Qué clientes están intentando conectarse?

EOF

echo ""
echo "[✓] Ejercicio 2 completado."
echo ""
echo "Para practicar cracking (solo con contraseñas de prueba):"
echo "  hashcat -m 16800 $OUTPUT_FILE wordlist.txt"
echo ""
