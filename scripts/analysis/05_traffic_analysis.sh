#!/usr/bin/env bash

# ======================================================
# Ejercicio 5: Análisis de Tráfico sobre WiFi
# ======================================================
# Compatibilidad: Linux, macOS, Windows (WSL2 / Git Bash)
PCAP_DIR="./wifi_lab/pcaps/misc"
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
echo "  Ejercicio 5: Network Traffic Analysis"
echo "=========================================="
echo ""

if ! command -v tshark &> /dev/null; then
    echo "[!] Error: tshark no está instalado."
    exit 1
fi

# Buscar PCAPs con tráfico de red
HTTP_PCAP=$(find "$PCAP_DIR" -name "*http*" -o -name "*traffic*" | head -1)
DNS_PCAP=$(find "$PCAP_DIR" -name "*dns*" | head -1)

if [ ! -f "$HTTP_PCAP" ]; then
    echo "[!] No se encontró PCAP con tráfico HTTP"
    HTTP_PCAP=$(find "../wifi_lab/pcaps" -name "*.cap" -o -name "*.pcap" | head -1)
fi

echo "Archivos a analizar:"
echo "  HTTP: $HTTP_PCAP"
echo "  DNS: $DNS_PCAP"
echo ""

# ==========================================
# TEORÍA: Seguridad en Captive Portals
# ==========================================
cat << 'THEORY'
--- TEORÍA: Tráfico sobre WiFi y Captive Portals ---

CAPTIVE PORTALS:
- Páginas de autenticación en WiFi público
- Interceptan HTTP para redirigir a login
- Comunes en: aeropuertos, hoteles, cafeterías

RIESGOS DE SEGURIDAD:

1. Tráfico HTTP sin cifrar
   - Credenciales en plaintext
   - Cookies robables
   - Man-in-the-Middle (MitM)

2. DNS spoofing
   - Redireccionamiento malicioso
   - Phishing

3. SSL Stripping
   - Downgrade de HTTPS a HTTP
   - Herramienta: sslstrip, mitmproxy

4. Evil Twin + Captive Portal
   - AP falso imita red legítima
   - Captura credenciales

DEFENSAS:

✓ Usar VPN en redes públicas
✓ HTTPS Everywhere / HSTS
✓ Verificar certificados SSL
✓ DNS sobre HTTPS (DoH)
✓ No ingresar credenciales sensibles en portales

THEORY
echo ""

# ==========================================
# TAREA 1: Análisis de tráfico HTTP
# ==========================================
if [ -f "$HTTP_PCAP" ]; then
    echo "--- TAREA 1: Análisis de Tráfico HTTP ---"
    echo ""
    echo "Archivo: $HTTP_PCAP"
    echo ""

    # Estadísticas generales
    echo "Estadísticas del PCAP:"
    if command -v capinfos &> /dev/null; then
        capinfos "$HTTP_PCAP" 2>/dev/null | grep -E "(File size|Number of packets|Capture duration|Data rate)"
    else
        # Alternativa con tshark si capinfos no está disponible
        PACKET_COUNT=$(tshark -r "$HTTP_PCAP" 2>/dev/null | wc -l | tr -d ' ')
        FILE_SIZE=$(ls -lh "$HTTP_PCAP" 2>/dev/null | awk '{print $5}')
        echo "  File size: $FILE_SIZE"
        echo "  Number of packets: $PACKET_COUNT"
    fi

    echo ""

    # HTTP requests
    HTTP_COUNT=$(tshark -r "$HTTP_PCAP" -Y "http.request" 2>/dev/null | wc -l)
    echo "Total de HTTP requests: $HTTP_COUNT"

    if [ "$HTTP_COUNT" -gt 0 ]; then
        echo ""
        echo "HTTP Requests encontrados:"
        tshark -r "$HTTP_PCAP" -Y "http.request" -T fields \
            -e frame.number \
            -e ip.src \
            -e ip.dst \
            -e http.request.method \
            -e http.host \
            -e http.request.uri 2>/dev/null | \
            awk 'BEGIN{print "Frame | Source IP | Dest IP | Method | Host | URI"}
                 {printf "%s | %s | %s | %s | %s | %s\n", $1, $2, $3, $4, $5, $6}' | \
            format_table | head -20

        echo ""

        # Buscar credenciales en POST data
        echo "Buscando datos sensibles (POST data):"
        POST_COUNT=$(tshark -r "$HTTP_PCAP" -Y "http.request.method == POST" 2>/dev/null | wc -l)
        echo "  POST requests: $POST_COUNT"

        if [ "$POST_COUNT" -gt 0 ]; then
            echo ""
            echo "  ⚠️  Analizando POST data (puede contener credenciales):"
            tshark -r "$HTTP_PCAP" -Y "http.request.method == POST" -T fields \
                -e frame.number \
                -e http.host \
                -e http.request.uri \
                -e http.file_data 2>/dev/null | \
                awk '{print "    Frame "$1": "$2$3" -> "$4}' | head -10

            echo ""
            echo "  [!] NOTA: En un escenario real, aquí podrías ver contraseñas en plaintext"
        fi

        # User-Agents
        echo ""
        echo "User-Agents detectados:"
        tshark -r "$HTTP_PCAP" -Y "http.user_agent" -T fields -e http.user_agent 2>/dev/null | \
            sort -u | head -10 | awk '{print "  - "$0}'

        # Cookies
        echo ""
        echo "Cookies transmitidas:"
        COOKIE_COUNT=$(tshark -r "$HTTP_PCAP" -Y "http.cookie" 2>/dev/null | wc -l)
        echo "  Total de frames con cookies: $COOKIE_COUNT"

        if [ "$COOKIE_COUNT" -gt 0 ]; then
            echo "  ⚠️  Cookies pueden contener tokens de sesión"
        fi
    fi

    echo ""
fi

# ==========================================
# TAREA 2: Análisis de DNS
# ==========================================
if [ -f "$DNS_PCAP" ]; then
    echo "--- TAREA 2: Análisis de DNS ---"
    echo ""
    echo "Archivo: $DNS_PCAP"
    echo ""

    DNS_QUERIES=$(tshark -r "$DNS_PCAP" -Y "dns.flags.response == 0" 2>/dev/null | wc -l)
    DNS_RESPONSES=$(tshark -r "$DNS_PCAP" -Y "dns.flags.response == 1" 2>/dev/null | wc -l)

    echo "DNS Queries: $DNS_QUERIES"
    echo "DNS Responses: $DNS_RESPONSES"

    echo ""
    echo "Top 10 dominios consultados:"
    tshark -r "$DNS_PCAP" -Y "dns.qry.name" -T fields -e dns.qry.name 2>/dev/null | \
        sort | uniq -c | sort -rn | head -10 | \
        awk '{printf "  %3d x %s\n", $1, $2}'

    echo ""
    echo "Tipos de queries DNS:"
    tshark -r "$DNS_PCAP" -Y "dns.flags.response == 0" -T fields -e dns.qry.type 2>/dev/null | \
        sort | uniq -c | sort -rn | \
        awk '{
            type=$2
            if(type==1) type_name="A (IPv4)"
            else if(type==28) type_name="AAAA (IPv6)"
            else if(type==15) type_name="MX (Mail)"
            else if(type==5) type_name="CNAME"
            else if(type==2) type_name="NS (Name Server)"
            else if(type==16) type_name="TXT"
            else type_name="Type "type
            printf "  %3d x %s\n", $1, type_name
        }'

    echo ""

    # Detectar DNS tunneling (queries anormalmente largas)
    echo "Detección de posible DNS tunneling:"
    LONG_QUERIES=$(tshark -r "$DNS_PCAP" -Y "dns.qry.name" -T fields -e dns.qry.name 2>/dev/null | \
        awk 'length($0) > 50 {print}' | wc -l)

    echo "  Queries con >50 caracteres: $LONG_QUERIES"

    if [ "$LONG_QUERIES" -gt 0 ]; then
        echo "  ⚠️  Queries largas pueden indicar DNS tunneling o exfiltración"
        echo ""
        echo "  Ejemplos:"
        tshark -r "$DNS_PCAP" -Y "dns.qry.name" -T fields -e dns.qry.name 2>/dev/null | \
            awk 'length($0) > 50 {print "    - "$0}' | head -5
    fi

    echo ""
fi

# ==========================================
# TAREA 3: Detección de MitM
# ==========================================
echo "--- TAREA 3: Indicadores de Man-in-the-Middle ---"
echo ""

cat << 'MITM_INDICATORS'
Indicadores de ataques MitM en PCAPs:

1. ARP Spoofing
   - Múltiples MACs reclamando la misma IP
   - Comando: tshark -r [PCAP] -Y "arp" -T fields -e arp.src.proto_ipv4 -e arp.src.hw_mac
   - Buscar: Misma IP con diferentes MACs

2. SSL/TLS Anomalías
   - Certificados autofirmados en sitios conocidos
   - Cambios en certificate fingerprints
   - Comando: tshark -r [PCAP] -Y "ssl.handshake.certificate" -T fields -e x509sat.printableString

3. DNS Spoofing
   - Respuestas DNS antes de tiempo (menor TTL)
   - IPs inesperadas para dominios conocidos
   - Múltiples respuestas para mismo query

4. HTTP Downgrade (SSL Stripping)
   - Conexiones HTTP a sitios que deberían ser HTTPS
   - Redirecciones sospechosas (302 a HTTP)
   - HSTS headers ausentes

5. Duplicate IPs
   - Misma IP desde diferentes MACs
   - Conflictos de IP

MITM_INDICATORS

# Análisis práctico si tenemos PCAP adecuado
if [ -f "$HTTP_PCAP" ]; then
    echo ""
    echo "Análisis práctico de MitM en PCAP actual:"
    echo ""

    # Buscar ARP
    ARP_COUNT=$(tshark -r "$HTTP_PCAP" -Y "arp" 2>/dev/null | wc -l)
    if [ "$ARP_COUNT" -gt 0 ]; then
        echo "Frames ARP encontrados: $ARP_COUNT"
        echo "Tabla IP-MAC:"
        tshark -r "$HTTP_PCAP" -Y "arp" -T fields -e arp.src.proto_ipv4 -e arp.src.hw_mac 2>/dev/null | \
            sort -u | awk '{printf "  %s -> %s\n", $1, $2}'
        echo ""
    fi

    # Buscar SSL/TLS
    TLS_COUNT=$(tshark -r "$HTTP_PCAP" -Y "tls.handshake.type == 1" 2>/dev/null | wc -l)
    if [ "$TLS_COUNT" -gt 0 ]; then
        echo "TLS Client Hellos: $TLS_COUNT"
        echo "Destinos HTTPS:"
        tshark -r "$HTTP_PCAP" -Y "tls.handshake.extensions_server_name" -T fields \
            -e tls.handshake.extensions_server_name 2>/dev/null | sort -u | head -10 | awk '{print "  - "$0}'
        echo ""
    fi
fi

echo ""

# ==========================================
# TAREA 4: Exportar datos sensibles
# ==========================================
echo "--- TAREA 4: Exportar Objetos HTTP ---"
echo ""

if [ -f "$HTTP_PCAP" ]; then
    EXPORT_DIR="$OUTPUT_DIR/http_objects"
    mkdir -p "$EXPORT_DIR"

    echo "Exportando objetos HTTP a: $EXPORT_DIR"

    # tshark --export-objects requiere GUI en algunas versiones
    # Alternativa: listar objetos
    echo ""
    echo "Objetos HTTP disponibles en el PCAP:"
    tshark -r "$HTTP_PCAP" -Y "http" -T fields \
        -e http.response.code \
        -e http.content_type \
        -e http.content_length 2>/dev/null | \
        awk 'NF==3 && $1==200 {print "  Status: "$1" Type: "$2" Size: "$3" bytes"}' | head -10

    echo ""
    echo "[i] Para exportar objetos manualmente:"
    echo "    wireshark $HTTP_PCAP -> File -> Export Objects -> HTTP"
fi

echo ""

# ==========================================
# TAREA 5: Generar reporte de seguridad
# ==========================================
echo "--- TAREA 5: Reporte de Seguridad ---"
echo ""

REPORT_FILE="$OUTPUT_DIR/traffic_security_report.txt"

{
    echo "# WiFi Traffic Security Analysis Report"
    echo "# Generado: $(date)"
    echo ""
    echo "## Resumen Ejecutivo"
    echo ""

    if [ -f "$HTTP_PCAP" ]; then
        echo "### HTTP Traffic"
        echo "- Archivo: $HTTP_PCAP"
        echo "- HTTP Requests: $HTTP_COUNT"
        echo "- POST Requests: ${POST_COUNT:-0}"
        echo "- Cookies detectadas: ${COOKIE_COUNT:-0}"
        echo ""
    fi

    if [ -f "$DNS_PCAP" ]; then
        echo "### DNS Traffic"
        echo "- Archivo: $DNS_PCAP"
        echo "- DNS Queries: $DNS_QUERIES"
        echo "- DNS Responses: $DNS_RESPONSES"
        echo "- Queries sospechosas (>50 chars): $LONG_QUERIES"
        echo ""
    fi

    echo "## Hallazgos de Seguridad"
    echo ""
    echo "### Riesgos Identificados"
    echo ""
    if [ "$HTTP_COUNT" -gt 0 ]; then
        echo "- [ALTO] Tráfico HTTP sin cifrar detectado"
        echo "  * Datos pueden ser interceptados"
        echo "  * Recomendación: Usar HTTPS y VPN"
        echo ""
    fi

    if [ "${POST_COUNT:-0}" -gt 0 ]; then
        echo "- [CRÍTICO] POST requests detectados"
        echo "  * Pueden contener credenciales en plaintext"
        echo "  * Recomendación: Auditar formularios y usar HTTPS"
        echo ""
    fi

    if [ "${COOKIE_COUNT:-0}" -gt 0 ]; then
        echo "- [MEDIO] Cookies transmitidas"
        echo "  * Session hijacking posible"
        echo "  * Recomendación: Secure flag + HttpOnly flag"
        echo ""
    fi

    if [ "$LONG_QUERIES" -gt 0 ]; then
        echo "- [MEDIO] Queries DNS anormalmente largas"
        echo "  * Posible DNS tunneling o exfiltración"
        echo "  * Recomendación: Investigar queries y usar DNS filtering"
        echo ""
    fi

    echo "## Recomendaciones"
    echo ""
    echo "1. Implementar HTTPS en todos los servicios"
    echo "2. Usar VPN en redes WiFi públicas"
    echo "3. Habilitar HSTS (HTTP Strict Transport Security)"
    echo "4. Implementar DNS over HTTPS (DoH) o DNS over TLS (DoT)"
    echo "5. Monitorear tráfico con IDS (Suricata/Snort)"
    echo "6. Educación de usuarios sobre riesgos de WiFi público"
    echo ""

} > "$REPORT_FILE"

echo "[✓] Reporte generado: $REPORT_FILE"
echo ""
cat "$REPORT_FILE"

# ==========================================
# PREGUNTAS PARA LOS ALUMNOS
# ==========================================
cat << 'EOF'

========================================
PREGUNTAS PARA RESPONDER:
========================================

1. ¿Qué riesgos tiene usar HTTP en lugar de HTTPS en WiFi público?
   Riesgos: _______

2. ¿Cómo funciona un ataque de SSL Stripping?
   Explicación: _______

3. ¿Qué es DNS tunneling y cómo detectarlo?
   Respuesta: _______

4. Nombra 3 técnicas de MitM en WiFi:
   - _______
   - _______
   - _______

5. ¿Qué headers HTTP ayudan a prevenir ataques?
   - HSTS: _______
   - CSP: _______
   - X-Frame-Options: _______

6. ¿Cómo extraerías cookies de un PCAP para session hijacking?
   Comando: _______

EJERCICIO PRÁCTICO:

Analiza el PCAP de tráfico HTTP y crea un informe de:
1. Sitios web visitados
2. Datos sensibles expuestos
3. Vulnerabilidades detectadas
4. Plan de remediación

EOF

echo ""
echo "[✓] Ejercicio 5 completado."
echo ""
echo "Comandos útiles:"
echo "  wireshark $HTTP_PCAP -Y 'http'"
echo "  tshark -r $HTTP_PCAP -Y 'http.request || http.response' -T fields -e http.host -e http.request.uri"
echo ""
