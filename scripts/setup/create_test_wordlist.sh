#!/bin/bash

# ======================================================
# Script: create_test_wordlist.sh
# Descripción: Crea una wordlist de prueba para ejercicios de cracking
# ======================================================

OUTPUT_FILE="wifi_lab/wordlist_test.txt"

echo "Creando wordlist de prueba..."

# Crear directorio si no existe
mkdir -p wifi_lab

# Generar wordlist con contraseñas comunes de prueba
cat > "$OUTPUT_FILE" << 'WORDLIST'
password
password123
12345678
qwerty123
admin123
letmein123
welcome123
monkey123
dragon123
master123
trustno1
sunshine123
princess123
football123
Induction
starwars123
induction
!Password1
P@ssw0rd
Passw0rd!
Test1234
Welcome1
wifi2023
wifipass
network123
router123
internet123
connection
wireless123
WORDLIST

# Añadir variaciones comunes
echo "wifinetwork" >> "$OUTPUT_FILE"
echo "mywifipass" >> "$OUTPUT_FILE"
echo "homeinternet" >> "$OUTPUT_FILE"

# Ordenar y eliminar duplicados
sort -u "$OUTPUT_FILE" -o "$OUTPUT_FILE"

LINE_COUNT=$(wc -l < "$OUTPUT_FILE")

echo "[✓] Wordlist creada: $OUTPUT_FILE"
echo "    Total de passwords: $LINE_COUNT"
echo ""
echo "NOTA: Esta wordlist es solo para propósitos educativos."
echo "      Para testing real, usar wordlists más completas como rockyou.txt"
echo ""
echo "Uso:"
echo "  aircrack-ng -w $OUTPUT_FILE wifi_lab/pcaps/wpa2/handshake.cap"
echo "  hashcat -m 22000 hash.hc22000 $OUTPUT_FILE"
echo ""
