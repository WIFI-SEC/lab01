#!/usr/bin/env bash

# ======================================================
# Ejercicio 3: Detección de Ataques de Deautenticación
# ======================================================
# Compatibilidad: Linux, macOS, Windows (WSL2 / Git Bash)
PCAP_DIR="./wifi_lab/pcaps/attacks"
OUTPUT_DIR="./wifi_lab/outputs"

echo "=========================================="
echo "  Ejercicio 3: Deauthentication Attacks"
echo "=========================================="
echo ""

if ! command -v tshark &> /dev/null; then
    echo "[!] Error: tshark no está instalado."
    exit 1
fi

# Buscar PCAP de deauth
PCAP_FILE=$(find "$PCAP_DIR" -name "*deauth*" | head -1)

# Si no existe, intentar en misc
if [ ! -f "$PCAP_FILE" ]; then
    PCAP_FILE=$(find "../wifi_lab/pcaps" -name "*.pcap*" -exec grep -l "deauth" {} \; 2>/dev/null | head -1)
fi

if [ ! -f "$PCAP_FILE" ]; then
    echo "[!] No se encontró PCAP de deauth, usando cualquier PCAP WiFi disponible..."
    PCAP_FILE=$(find "../wifi_lab/pcaps" -name "*.pcap*" | head -1)
fi

echo "Archivo: $PCAP_FILE"
echo ""

# ==========================================
# TEORÍA
# ==========================================
cat << 'THEORY'
--- TEORÍA: Deauthentication Frames ---

Frame Type: Management (0x0c)
Subtype: Deauthentication (0x0c)

USOS LEGÍTIMOS:
- Cliente desconectándose del AP
- AP desconectando cliente por timeout
- Cambio de parámetros de seguridad

USOS MALICIOSOS:
- Forzar reconexión para capturar handshake
- DoS (Denial of Service) contra WiFi
- Evil Twin attacks (forzar a AP falso)

CARACTERÍSTICAS DE ATAQUE:
✗ Múltiples deauth en corto tiempo
✗ Broadcast deauth (FF:FF:FF:FF:FF:FF)
✗ Reason codes sospechosos
✗ Deauth desde MAC no asociada al AP

THEORY
echo ""

# ==========================================
# TAREA 1: Identificar frames de deauth
# ==========================================
echo "--- TAREA 1: Identificar Deauthentication Frames ---"
echo ""

DEAUTH_COUNT=$(tshark -r "$PCAP_FILE" -Y "wlan.fc.type_subtype == 0x0c" 2>/dev/null | wc -l)
echo "Total de frames de deauthentication: $DEAUTH_COUNT"

if [ "$DEAUTH_COUNT" -gt 0 ]; then
    echo ""
    echo "Detalles de los frames:"
    tshark -r "$PCAP_FILE" -Y "wlan.fc.type_subtype == 0x0c" -T fields \
        -e frame.number \
        -e frame.time_relative \
        -e wlan.sa \
        -e wlan.da \
        -e wlan.fixed.reason_code 2>/dev/null | \
        awk 'BEGIN{print "Frame | Tiempo(s) | Origen | Destino | Reason Code"}
             {printf "%s | %s | %s | %s | %s\n", $1, $2, $3, $4, $5}' | column -t -s'|'
else
    echo "[!] No se encontraron frames de deauth en este PCAP"
    echo "    (Esto es normal, no todos los PCAPs contienen ataques)"
fi

echo ""

# ==========================================
# TAREA 2: Analizar reason codes
# ==========================================
echo "--- TAREA 2: Reason Codes ---"
echo ""

cat << 'REASON_CODES'
Reason Codes comunes en WiFi 802.11:

Código | Significado                        | Sospechoso?
-------|------------------------------------|-----------
1      | Unspecified                        | ⚠️  (genérico)
2      | Previous auth no longer valid      | ✓  (legítimo)
3      | Deauth - leaving BSS               | ✓  (normal)
4      | Disassoc - inactivity              | ✓  (timeout)
5      | Disassoc - too many stations       | ⚠️  (puede ser DoS)
6      | Class 2 frame from nonauth STA     | ✗  (sospechoso)
7      | Class 3 frame from nonassoc STA    | ✗  (sospechoso)
8      | Disassoc - STA leaving             | ✓  (legítimo)

REASON_CODES

if [ "$DEAUTH_COUNT" -gt 0 ]; then
    echo ""
    echo "Distribution de reason codes en el PCAP:"
    tshark -r "$PCAP_FILE" -Y "wlan.fc.type_subtype == 0x0c" -T fields \
        -e wlan.fixed.reason_code 2>/dev/null | sort | uniq -c | \
        awk '{printf "  Reason %s: %s ocurrencias\n", $2, $1}'
fi

echo ""

# ==========================================
# TAREA 3: Detección de patrones de ataque
# ==========================================
echo "--- TAREA 3: Análisis de Patrones de Ataque ---"
echo ""

if [ "$DEAUTH_COUNT" -gt 0 ]; then
    # Deauth broadcast (indicador fuerte de ataque)
    BROADCAST_DEAUTH=$(tshark -r "$PCAP_FILE" \
        -Y "wlan.fc.type_subtype == 0x0c && wlan.da == ff:ff:ff:ff:ff:ff" 2>/dev/null | wc -l)

    echo "Deauth frames broadcast (FF:FF:FF:FF:FF:FF): $BROADCAST_DEAUTH"

    if [ "$BROADCAST_DEAUTH" -gt 0 ]; then
        echo "⚠️  ALERTA: Deauth broadcast detectado - posible ataque"
    fi

    echo ""

    # Ratio de deauth/tiempo
    TOTAL_TIME=$(tshark -r "$PCAP_FILE" -T fields -e frame.time_relative 2>/dev/null | tail -1)
    if [ -n "$TOTAL_TIME" ] && [ "$(echo "$TOTAL_TIME > 0" | bc -l 2>/dev/null || echo 0)" -eq 1 ]; then
        DEAUTH_RATE=$(echo "scale=2; $DEAUTH_COUNT / $TOTAL_TIME" | bc -l)
        echo "Ratio de deauth: $DEAUTH_RATE frames/segundo"

        if [ "$(echo "$DEAUTH_RATE > 10" | bc -l 2>/dev/null || echo 0)" -eq 1 ]; then
            echo "⚠️  ALERTA: Ratio anormalmente alto - posible flood attack"
        fi
    fi

    echo ""

    # Análisis de origen
    echo "Top 5 MACs enviando deauth:"
    tshark -r "$PCAP_FILE" -Y "wlan.fc.type_subtype == 0x0c" -T fields \
        -e wlan.sa 2>/dev/null | sort | uniq -c | sort -rn | head -5 | \
        awk '{printf "  %s frames desde %s\n", $1, $2}'

else
    echo "[i] No hay frames de deauth para analizar patrones"
fi

echo ""

# ==========================================
# TAREA 4: Generar reglas de detección
# ==========================================
echo "--- TAREA 4: Reglas de Detección (IDS) ---"
echo ""

OUTPUT_RULES="$OUTPUT_DIR/deauth_detection_rules.txt"

cat > "$OUTPUT_RULES" << 'IDS_RULES'
# Reglas de Detección para Ataques WiFi Deauthentication
# Compatible con: Suricata, Snort (adaptar sintaxis según IDS)

# Regla 1: Detectar múltiples deauth en ventana de tiempo
alert wifi any any -> any any (msg:"WiFi Deauth Flood Detected"; \
    content:"|c0 00|"; offset:0; depth:2; \
    threshold: type threshold, track by_src, count 10, seconds 5; \
    classtype:denial-of-service; sid:1000001; rev:1;)

# Regla 2: Detectar deauth broadcast
alert wifi any any -> ff:ff:ff:ff:ff:ff any (msg:"WiFi Broadcast Deauth Attack"; \
    content:"|c0 00|"; offset:0; depth:2; \
    classtype:attempted-dos; sid:1000002; rev:1;)

# Regla 3: Detectar reason code sospechoso (6 o 7)
alert wifi any any -> any any (msg:"WiFi Deauth with Suspicious Reason Code"; \
    content:"|c0 00|"; offset:0; depth:2; \
    content:"|06 00|"; distance:0; \
    classtype:suspicious-traffic; sid:1000003; rev:1;)

# Regla 4: Detectar deauth seguido de association (evil twin)
alert wifi any any -> any any (msg:"Possible Evil Twin - Deauth + Assoc Pattern"; \
    content:"|c0 00|"; offset:0; depth:2; \
    flowbits:set,deauth.seen; flowbits:noalert; \
    sid:1000004; rev:1;)

alert wifi any any -> any any (msg:"Evil Twin Association After Deauth"; \
    content:"|00 00|"; offset:0; depth:2; \
    flowbits:isset,deauth.seen; \
    classtype:attempted-admin; sid:1000005; rev:1;)

IDS_RULES

echo "[✓] Reglas de detección guardadas en: $OUTPUT_RULES"
echo ""

cat "$OUTPUT_RULES"

echo ""

# ==========================================
# TAREA 5: Mitigación
# ==========================================
echo "--- TAREA 5: Técnicas de Mitigación ---"
echo ""

cat << 'MITIGATION'
MITIGACIÓN Y DEFENSA:

1. 802.11w (Management Frame Protection - MFP)
   ✓ Protege frames de management con cifrado
   ✓ Obligatorio en WPA3, opcional en WPA2
   ✓ Verificar soporte en AP y clientes

2. WIDS/WIPS (Wireless IDS/IPS)
   ✓ Aircrack-ng suite
   ✓ Kismet IDS
   ✓ Suricata con soporte WiFi
   ✓ Soluciones comerciales (Cisco ISE, Aruba ClearPass)

3. Monitoreo continuo
   ✓ Honeypot WiFi para detectar deauth floods
   ✓ Alertas en dashboards (Grafana + InfluxDB)
   ✓ Logs centralizados (ELK stack)

4. Configuración de AP
   ✓ Habilitar Protected Management Frames (PMF)
   ✓ Rate limiting de management frames
   ✓ Client isolation
   ✓ Firmware actualizado

5. Respuesta a incidentes
   ✓ Identificar fuente del ataque (MAC spoofing es común)
   ✓ Triangulación con múltiples sensores
   ✓ Bloqueo temporal de rangos sospechosos
   ✓ Escalación a seguridad física si es necesario

MITIGATION

# ==========================================
# PREGUNTAS PARA LOS ALUMNOS
# ==========================================
cat << 'EOF'

========================================
PREGUNTAS PARA RESPONDER:
========================================

1. ¿Cómo distingues un deauth legítimo de uno malicioso?
   Indicadores: _______

2. ¿Qué es 802.11w y cómo previene deauth attacks?
   Respuesta: _______

3. ¿Por qué un atacante usa deauth antes de capturar handshakes?
   Razón: _______

4. ¿Qué comando tshark usarías para filtrar solo deauth frames?
   Comando: _______

5. Nombra 3 herramientas que pueden realizar deauth attacks (conocerlas ayuda a defenderse):
   - _______
   - _______
   - _______

EJERCICIO PRÁCTICO:

1. Analiza el PCAP y determina:
   - ¿Hay evidencia de ataque de deauth?
   - ¿Qué MACs están involucradas?
   - ¿Cuál es el timeline del ataque?

2. Diseña una estrategia de defensa para una red corporativa
   que ha sufrido ataques de deauth repetidos.

EOF

echo ""
echo "[✓] Ejercicio 3 completado."
echo ""
echo "Comandos adicionales para investigar:"
echo "  wireshark $PCAP_FILE -Y 'wlan.fc.type_subtype == 0x0c'"
echo "  tshark -r $PCAP_FILE -Y 'wlan.fc.type == 0' -T fields -e frame.time -e wlan.sa -e wlan.da"
echo ""
