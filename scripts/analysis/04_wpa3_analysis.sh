#!/usr/bin/env bash

# ======================================================
# Ejercicio 4: Análisis de WPA3 y SAE (Dragonfly)
# ======================================================
# Compatibilidad: Linux, macOS, Windows (WSL2 / Git Bash)
PCAP_DIR="./wifi_lab/pcaps/wpa3"
OUTPUT_DIR="./wifi_lab/outputs"

# Función auxiliar para formatear tablas (compatible sin 'column')
format_table() {
    if command -v column &> /dev/null; then
        column -t -s'|'
    else
        cat  # Si no hay column, mostrar tal cual
    fi
}

echo "=========================================="
echo "  Ejercicio 4: WPA3 SAE Analysis"
echo "=========================================="
echo ""

if ! command -v tshark &> /dev/null; then
    echo "[!] Error: tshark no está instalado."
    exit 1
fi

# Buscar PCAP de WPA3
PCAP_FILE=$(find "$PCAP_DIR" -name "*.pcap*" 2>/dev/null | head -1)

if [ ! -f "$PCAP_FILE" ]; then
    echo "[!] No se encontró PCAP de WPA3"
    echo "    Esto puede deberse a que el repositorio no tiene ejemplos WPA3 disponibles"
    echo "    WPA3 es relativamente nuevo y los PCAPs públicos son escasos"
    exit 1
fi

echo "Archivo: $PCAP_FILE"
echo ""

# ==========================================
# TEORÍA: WPA3 y SAE
# ==========================================
cat << 'THEORY'
--- TEORÍA: WPA3 y SAE (Simultaneous Authentication of Equals) ---

WPA3 fue lanzado en 2018 por Wi-Fi Alliance

MEJORAS SOBRE WPA2:

1. SAE (Dragonfly) en lugar de PSK
   - Resistente a ataques de diccionario offline
   - Forward secrecy
   - Protección contra KRACK

2. Management Frame Protection (802.11w) OBLIGATORIO
   - Protege contra deauth attacks
   - Cifra frames de management

3. Individualized Data Encryption (OWE para redes abiertas)
   - Cifrado incluso sin contraseña

4. 192-bit security suite (WPA3-Enterprise)
   - GCMP-256, HMAC-SHA384, ECDHE/ECDSA

DESAFÍOS:

- Dragonblood vulnerabilities (2019-2020)
  * Timing attacks en SAE
  * Side-channel attacks
  * DoS attacks
  (la mayoría fueron parcheados)

- Compatibilidad: WPA3-Transition mode mezcla WPA2/WPA3
  (vulnerable a downgrade attacks si no se configura bien)

THEORY
echo ""

# ==========================================
# TAREA 1: Identificar frames SAE
# ==========================================
echo "--- TAREA 1: Identificar SAE Authentication ---"
echo ""

echo "Buscando frames de autenticación SAE..."

# SAE usa authentication frames (type 0, subtype 11)
AUTH_COUNT=$(tshark -r "$PCAP_FILE" -Y "wlan.fc.type_subtype == 0x0b" 2>/dev/null | wc -l)
echo "Total de authentication frames: $AUTH_COUNT"

if [ "$AUTH_COUNT" -gt 0 ]; then
    echo ""
    echo "Detalles de authentication frames:"
    tshark -r "$PCAP_FILE" -Y "wlan.fc.type_subtype == 0x0b" -T fields \
        -e frame.number \
        -e wlan.sa \
        -e wlan.da \
        -e wlan.fixed.auth.alg \
        -e wlan.fixed.status_code 2>/dev/null | \
        awk 'BEGIN{print "Frame | Source | Destination | Auth Alg | Status"}
             {printf "%s | %s | %s | %s | %s\n", $1, $2, $3, $4, $5}' | format_table

    echo ""
    echo "Algoritmos de autenticación encontrados:"
    tshark -r "$PCAP_FILE" -Y "wlan.fc.type_subtype == 0x0b" -T fields \
        -e wlan.fixed.auth.alg 2>/dev/null | sort | uniq -c | \
        awk '{
            alg=$2
            if(alg==0) alg_name="Open System"
            else if(alg==1) alg_name="Shared Key (WEP)"
            else if(alg==2) alg_name="Fast BSS Transition"
            else if(alg==3) alg_name="SAE (WPA3)"
            else if(alg==4) alg_name="FT over SAE"
            else alg_name="Unknown ("alg")"
            printf "  %s x %s\n", $1, alg_name
        }'
fi

echo ""

# ==========================================
# TAREA 2: Analizar SAE exchange
# ==========================================
echo "--- TAREA 2: SAE Commit y Confirm Messages ---"
echo ""

cat << 'SAE_EXCHANGE'
SAE Handshake (Dragonfly):

Fase 1: COMMIT
  - Station → AP: SAE Commit (elemento escalar + elemento de grupo)
  - AP → Station: SAE Commit (elemento escalar + elemento de grupo)

  Propósito: Establecer secreto compartido resistente a diccionario offline

Fase 2: CONFIRM
  - Station → AP: SAE Confirm (prueba de conocimiento de PSK)
  - AP → Station: SAE Confirm

  Propósito: Confirmar que ambos lados tienen la misma PMK

Después del SAE, se procede con 4-way handshake normal (pero con PMK derivada de SAE)

SAE_EXCHANGE
echo ""

# Buscar elementos SAE en el PCAP
echo "Buscando elementos SAE Commit/Confirm..."

SAE_FRAMES=$(tshark -r "$PCAP_FILE" -Y "wlan.fixed.auth.alg == 3" 2>/dev/null | wc -l)

if [ "$SAE_FRAMES" -gt 0 ]; then
    echo "✓ Encontrados $SAE_FRAMES frames SAE"
    echo ""
    tshark -r "$PCAP_FILE" -Y "wlan.fixed.auth.alg == 3" -T fields \
        -e frame.number \
        -e frame.time_relative \
        -e wlan.sa \
        -e wlan.da \
        -e wlan.fixed.auth.sae.group 2>/dev/null | \
        awk 'BEGIN{print "Frame | Tiempo | Source | Destination | SAE Group"}
             {printf "%s | %s | %s | %s | %s\n", $1, $2, $3, $4, $5}' | format_table | head -10
else
    echo "[i] No se encontraron frames SAE explícitos en este PCAP"
    echo "    (Algunos PCAPs de ejemplo pueden estar simplificados)"
fi

echo ""

# ==========================================
# TAREA 3: Comparación WPA2 vs WPA3
# ==========================================
echo "--- TAREA 3: Comparación WPA2 vs WPA3 ---"
echo ""

cat << 'COMPARISON' | format_table
Característica|WPA2|WPA3
Autenticación|4-way handshake|SAE + 4-way handshake
PSK vulnerable a|Diccionario offline|Resistente (SAE)
PMKID attack|Vulnerable|No vulnerable
Management frames|Opcional (802.11w)|Obligatorio
Forward secrecy|No|Sí
Reutilización nonce (KRACK)|Vulnerable|Protegido
Complejidad|Media|Alta
Adopción|Universal|Creciente
COMPARISON

echo ""

# ==========================================
# TAREA 4: Análisis de seguridad
# ==========================================
echo "--- TAREA 4: Análisis de Seguridad WPA3 ---"
echo ""

OUTPUT_REPORT="$OUTPUT_DIR/wpa3_security_analysis.txt"

cat > "$OUTPUT_REPORT" << 'SECURITY_ANALYSIS'
# WPA3 Security Analysis Report

## Ventajas de WPA3

### 1. SAE (Dragonfly) Key Exchange
- Resistente a ataques de diccionario offline
- Cada sesión genera claves únicas (forward secrecy)
- No se puede capturar tráfico pasivamente para crackear después

### 2. Management Frame Protection
- Protege contra:
  * Deauthentication attacks
  * Disassociation attacks
  * Rogue AP spoofing (parcialmente)
- Frames de management cifrados y autenticados

### 3. Protección contra KRACK
- Evita reutilización de nonces en PTK
- Implementación más robusta del 4-way handshake

## Vulnerabilidades Conocidas (Dragonblood)

### CVE-2019-9494: Timing attack en SAE
**Impacto**: Filtración de información sobre la contraseña
**Mitigación**: Implementación de tiempo constante (parcheado)

### CVE-2019-9495: Cache-based side-channel
**Impacto**: Recuperación de información de la contraseña vía cache
**Mitigación**: Implementaciones resistentes a side-channel

### CVE-2019-9497: Reflection attack
**Impacto**: AP puede ser engañado para autenticarse consigo mismo
**Mitigación**: Validación de MAC addresses en SAE

### CVE-2019-9498/9499: EAP-pwd timing attacks
**Impacto**: Similar a SAE timing attacks
**Mitigación**: Implementaciones de tiempo constante

## Downgrade Attacks

### WPA3-Transition Mode
- Permite tanto WPA2 como WPA3
- **Riesgo**: Atacante puede forzar downgrade a WPA2
- **Mitigación**: Usar WPA3-only mode cuando sea posible

### Detección de Downgrade
Monitorear:
- Beacons con capabilities cambiantes
- Clientes WPA3 conectándose vía WPA2
- Múltiples association requests con diferentes security modes

## Recomendaciones

### Para Administradores
1. ✓ Habilitar WPA3-only (no transition) si todos los clientes soportan
2. ✓ Mantener firmware actualizado (parches de Dragonblood)
3. ✓ Monitorear logs para downgrade attempts
4. ✓ Usar contraseñas fuertes (aunque SAE es resistente, no es mágico)
5. ✓ Implementar WIDS para detectar anomalías

### Para Auditores de Seguridad
1. ✓ Verificar que 802.11w esté activo
2. ✓ Testear downgrade attacks en transition mode
3. ✓ Revisar implementation del SAE (timing attacks)
4. ✓ Validar configuración de ciphers (GCMP-256 para WPA3-Enterprise)
5. ✓ Pentesting con herramientas actualizadas (Dragonslayer, etc.)

## Herramientas de Testing

- **wpa_supplicant**: Cliente WPA3 open source
- **hostapd**: AP WPA3 para testing
- **Dragonslayer**: Suite de tests para vulnerabilidades Dragonblood
- **dragondrain-cve-2019-9494**: PoC de timing attack
- **dragonforce**: PoC de downgrade attack

## Referencias
- WPA3 Specification: Wi-Fi Alliance (2018)
- Dragonblood: Mathy Vanhoef & Eyal Ronen (2019-2020)
- RFC 7664: Dragonfly Key Exchange

SECURITY_ANALYSIS

echo "[✓] Análisis de seguridad guardado en: $OUTPUT_REPORT"
echo ""

cat "$OUTPUT_REPORT"

echo ""

# ==========================================
# TAREA 5: Comandos útiles para análisis
# ==========================================
echo "--- TAREA 5: Comandos para Análisis WPA3 ---"
echo ""

cat << 'COMMANDS'
Comandos útiles para analizar WPA3:

1. Ver todos los authentication frames:
   tshark -r [PCAP] -Y "wlan.fc.type_subtype == 0x0b"

2. Filtrar solo SAE authentication:
   tshark -r [PCAP] -Y "wlan.fixed.auth.alg == 3"

3. Extraer SAE group ID:
   tshark -r [PCAP] -Y "wlan.fixed.auth.alg == 3" -T fields -e wlan.fixed.auth.sae.group

4. Ver RSN capabilities (verificar PMF):
   tshark -r [PCAP] -Y "wlan.rsn.capabilities" -T fields -e wlan.rsn.capabilities

5. Detectar WPA3-transition mode:
   tshark -r [PCAP] -Y "wlan.tag.number == 48" -T fields -e wlan.rsn.akms.type

6. Timeline de autenticación completa:
   tshark -r [PCAP] -Y "wlan.fc.type == 0 || eapol" -T fields \
       -e frame.number -e frame.time_relative -e wlan.fc.type_subtype

COMMANDS

# ==========================================
# PREGUNTAS PARA LOS ALUMNOS
# ==========================================
cat << 'EOF'

========================================
PREGUNTAS PARA RESPONDER:
========================================

1. ¿Qué problema de WPA2 resuelve SAE (Dragonfly)?
   Respuesta: _______

2. ¿Por qué WPA3 requiere 802.11w obligatoriamente?
   Razón: _______

3. Explica qué es "forward secrecy" en el contexto de WPA3:
   Respuesta: _______

4. ¿Qué son las vulnerabilidades Dragonblood?
   - CVE-2019-9494: _______
   - CVE-2019-9497: _______

5. ¿Cuándo es apropiado usar WPA3-Transition mode?
   Respuesta: _______

6. ¿Qué herramienta usarías para testear downgrade attacks?
   Herramienta: _______

EJERCICIO AVANZADO:

Diseña un plan de migración de WPA2 a WPA3 para una empresa con:
- 500 empleados
- Mix de dispositivos (algunos legacy)
- Múltiples ubicaciones
- Requisitos de compliance (PCI-DSS, HIPAA)

Consideraciones:
- Timeline
- Testing
- Rollback plan
- Training
- Compatibilidad

EOF

echo ""
echo "[✓] Ejercicio 4 completado."
echo ""
echo "Para explorar más:"
echo "  wireshark $PCAP_FILE"
echo "  man wpa_supplicant.conf (ver opciones de WPA3)"
echo ""
