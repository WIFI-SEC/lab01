#!/bin/bash

# ======================================================
# Ejercicio 1: Análisis de 4-Way Handshake WPA2
# ======================================================

PCAP_DIR="./wifi_lab/pcaps/wpa2"
OUTPUT_DIR="./wifi_lab/outputs"

echo "=========================================="
echo "  Ejercicio 1: WPA2 4-Way Handshake"
echo "=========================================="
echo ""

# Verificar que tshark esté instalado
if ! command -v tshark &> /dev/null; then
    echo "[!] Error: tshark no está instalado."
    echo "    Instalar con: brew install wireshark (macOS) o apt install tshark (Linux)"
    exit 1
fi

echo "[+] Analizando handshake WPA2..."
echo ""

# Encontrar PCAPs de WPA2
PCAP_FILE=$(find "$PCAP_DIR" -type f \( -name "*handshake*" -o -name "*wpa*" -o -name "*.pcap" \) 2>/dev/null | head -1)

if [ ! -f "$PCAP_FILE" ]; then
    echo "[!] No se encontró archivo PCAP de handshake"
    exit 1
fi

echo "Archivo: $PCAP_FILE"
echo ""

# ==========================================
# TAREA 1: Identificar EAPOL frames
# ==========================================
echo "--- TAREA 1: Contar EAPOL frames ---"
echo ""

EAPOL_COUNT=$(tshark -r "$PCAP_FILE" -Y "eapol" 2>/dev/null | wc -l)
echo "Total de frames EAPOL encontrados: $EAPOL_COUNT"

echo ""
echo "Desglose de EAPOL messages:"
tshark -r "$PCAP_FILE" -Y "eapol" -T fields \
    -e frame.number \
    -e wlan.sa \
    -e wlan.da \
    -e eapol.keydes.key_info 2>/dev/null | \
    awk '{printf "Frame %s: %s -> %s (Key Info: 0x%s)\n", $1, $2, $3, $4}'

echo ""

# ==========================================
# TAREA 2: Extraer información del handshake
# ==========================================
echo "--- TAREA 2: Información del Handshake ---"
echo ""

echo "SSID de la red:"
tshark -r "$PCAP_FILE" -Y "wlan.fc.type_subtype == 0x08" -T fields -e wlan.ssid 2>/dev/null | sort -u

echo ""
echo "BSSID (MAC del AP):"
tshark -r "$PCAP_FILE" -Y "wlan.fc.type_subtype == 0x08" -T fields -e wlan.bssid 2>/dev/null | sort -u

echo ""
echo "Estaciones (clientes) conectadas:"
tshark -r "$PCAP_FILE" -Y "wlan.fc.type == 2" -T fields -e wlan.sa 2>/dev/null | sort -u

echo ""

# ==========================================
# TAREA 3: Exportar para hashcat/aircrack-ng
# ==========================================
echo "--- TAREA 3: Exportar handshake para cracking ---"
echo ""

OUTPUT_HC="$OUTPUT_DIR/handshake_hashcat.hccapx"
OUTPUT_AC="$OUTPUT_DIR/handshake_aircrack.cap"

# Convertir a formato hashcat (requiere cap2hccapx o hcxpcapngtool)
if command -v hcxpcapngtool &> /dev/null; then
    hcxpcapngtool -o "$OUTPUT_HC" "$PCAP_FILE" 2>/dev/null
    echo "[✓] Handshake exportado para hashcat: $OUTPUT_HC"
else
    echo "[!] hcxpcapngtool no instalado (opcional)"
fi

# Copiar para aircrack-ng
cp "$PCAP_FILE" "$OUTPUT_AC"
echo "[✓] PCAP copiado para aircrack-ng: $OUTPUT_AC"

echo ""
echo "--- Comandos para practicar (DEFENSIVO) ---"
echo ""
echo "1. Ver handshake completo en Wireshark:"
echo "   wireshark $PCAP_FILE -Y 'eapol'"
echo ""
echo "2. Verificar integridad del handshake:"
echo "   aircrack-ng $OUTPUT_AC"
echo ""
echo "3. Analizar nonces y detectar ataques de reutilización:"
echo "   tshark -r $PCAP_FILE -Y 'eapol' -T fields -e eapol.keydes.nonce"
echo ""

# ==========================================
# PREGUNTAS PARA LOS ALUMNOS
# ==========================================
cat << 'EOF'

========================================
PREGUNTAS PARA RESPONDER:
========================================

1. ¿Cuántos mensajes EAPOL componen un 4-way handshake completo?
   Respuesta esperada: _______

2. ¿Qué información se intercambia en cada mensaje?
   - Mensaje 1: _______
   - Mensaje 2: _______
   - Mensaje 3: _______
   - Mensaje 4: _______

3. ¿Qué campo permite identificar ataques KRACK (reutilización de nonces)?
   Respuesta: _______

4. ¿Cómo se puede detectar un ataque de deautenticación previo al handshake?
   Comando: tshark -r [PCAP] -Y "wlan.fc.type_subtype == 0x0c"

5. ¿Qué ventajas tiene PMKID attack sobre capturar el handshake completo?
   Respuesta: _______

EOF

echo ""
echo "[✓] Ejercicio 1 completado. Revisar outputs en: $OUTPUT_DIR"
echo ""
