# WiFi Security Cheatsheet

Referencia rápida de comandos para análisis de seguridad WiFi.

---

## tshark (Wireshark CLI)

### Filtros Básicos

```bash
# Ver todos los frames WiFi
tshark -r captura.pcap

# Solo EAPOL (4-way handshake)
tshark -r captura.pcap -Y "eapol"

# Deauthentication frames
tshark -r captura.pcap -Y "wlan.fc.type_subtype == 0x0c"

# Authentication frames
tshark -r captura.pcap -Y "wlan.fc.type_subtype == 0x0b"

# Beacon frames
tshark -r captura.pcap -Y "wlan.fc.type_subtype == 0x08"

# HTTP requests
tshark -r captura.pcap -Y "http.request"

# DNS queries
tshark -r captura.pcap -Y "dns.flags.response == 0"
```

### Extracción de Campos

```bash
# Extraer SSIDs
tshark -r captura.pcap -Y "wlan.ssid" -T fields -e wlan.ssid | sort -u

# Extraer BSSIDs (MAC de APs)
tshark -r captura.pcap -Y "wlan.fc.type_subtype == 0x08" -T fields -e wlan.bssid | sort -u

# Extraer clientes (source MACs)
tshark -r captura.pcap -Y "wlan.fc.type == 2" -T fields -e wlan.sa | sort -u

# HTTP hosts visitados
tshark -r captura.pcap -Y "http.request" -T fields -e http.host | sort -u

# DNS queries con timestamps
tshark -r captura.pcap -Y "dns" -T fields -e frame.time -e dns.qry.name
```

### Análisis de EAPOL

```bash
# Ver todos los messages EAPOL con detalles
tshark -r captura.pcap -Y "eapol" -V

# Extraer nonces (para detectar KRACK)
tshark -r captura.pcap -Y "eapol" -T fields -e eapol.keydes.nonce

# Ver key info field
tshark -r captura.pcap -Y "eapol" -T fields -e eapol.keydes.key_info
```

### Estadísticas

```bash
# Conversaciones (endpoints)
tshark -r captura.pcap -q -z conv,wlan

# Distribución de protocolos
tshark -r captura.pcap -q -z io,phs

# Jerarquía de protocolos
tshark -r captura.pcap -q -z io,phs
```

---

## aircrack-ng Suite

### aircrack-ng (Cracking)

```bash
# Verificar handshake válido
aircrack-ng captura.cap

# Crackear con wordlist
aircrack-ng -w wordlist.txt captura.cap

# Especificar BSSID específico
aircrack-ng -b 00:11:22:33:44:55 -w wordlist.txt captura.cap

# Ataque de fuerza bruta (solo testing)
aircrack-ng -a 2 -w wordlist.txt captura.cap
```

### airdecap-ng (Descifrar)

```bash
# Descifrar WPA2 con contraseña conocida
airdecap-ng -e "SSID" -p "password" captura.cap

# Descifrar WEP
airdecap-ng -w 1A:2B:3C:4D:5E captura.cap
```

---

## hcxtools (PMKID y Conversión)

### hcxpcapngtool (Conversión)

```bash
# Extraer PMKIDs y handshakes para hashcat
hcxpcapngtool -o output.22000 captura.pcap

# Solo PMKIDs
hcxpcapngtool -k output_pmkid.16800 captura.pcap

# Solo EAPOL
hcxpcapngtool -E output_eapol.txt captura.pcap
```

### hcxhashtool (Análisis de hashes)

```bash
# Información de hash
hcxhashtool -i hash.22000 --info

# Filtrar por ESSID
hcxhashtool -i hash.22000 --essid="MyNetwork" -o filtered.22000
```

---

## hashcat (Password Recovery)

### Modos WiFi

```bash
# WPA/WPA2 (nuevo formato)
hashcat -m 22000 hash.22000 wordlist.txt

# PMKID (antiguo formato)
hashcat -m 16800 hash.16800 wordlist.txt

# WPA-PBKDF2-PMKID+EAPOL (formato viejo)
hashcat -m 2500 hash.hccapx wordlist.txt
```

### Opciones Útiles

```bash
# Mostrar progreso
hashcat -m 22000 hash.22000 wordlist.txt --status

# Usar GPU específica
hashcat -m 22000 hash.22000 wordlist.txt -d 1

# Benchmark
hashcat -b -m 22000

# Restaurar sesión
hashcat --restore

# Reglas (mutaciones)
hashcat -m 22000 hash.22000 wordlist.txt -r rules/best64.rule
```

---

## Wireshark Display Filters

### WiFi Management Frames

```
# Beacon frames
wlan.fc.type_subtype == 0x08

# Probe request
wlan.fc.type_subtype == 0x04

# Probe response
wlan.fc.type_subtype == 0x05

# Association request
wlan.fc.type_subtype == 0x00

# Association response
wlan.fc.type_subtype == 0x01

# Deauthentication
wlan.fc.type_subtype == 0x0c

# Disassociation
wlan.fc.type_subtype == 0x0a
```

### WiFi Data

```
# Todo el tráfico de datos
wlan.fc.type == 2

# Desde un AP específico
wlan.bssid == 00:11:22:33:44:55

# Desde un cliente específico
wlan.sa == aa:bb:cc:dd:ee:ff

# EAPOL (handshake)
eapol

# Solo mensaje 1 del handshake (aproximado)
eapol && wlan.fc.type_subtype == 0x08
```

### Ataques

```
# Deauth broadcast
wlan.fc.type_subtype == 0x0c && wlan.da == ff:ff:ff:ff:ff:ff

# ARP spoofing detection
arp.duplicate-address-detected

# DNS anomalías
dns.flags.response == 1 && dns.flags.rcode != 0
```

---

## Análisis de Tráfico

### HTTP

```bash
# Extraer HTTP requests
tshark -r captura.pcap -Y "http.request" -T fields \
  -e http.request.method -e http.host -e http.request.uri

# POST data (credenciales potenciales)
tshark -r captura.pcap -Y "http.request.method == POST" -T fields \
  -e http.file_data

# Cookies
tshark -r captura.pcap -Y "http.cookie" -T fields \
  -e http.cookie

# User-Agents
tshark -r captura.pcap -Y "http.user_agent" -T fields \
  -e http.user_agent | sort -u
```

### DNS

```bash
# Top dominios consultados
tshark -r captura.pcap -Y "dns.qry.name" -T fields \
  -e dns.qry.name | sort | uniq -c | sort -rn

# Queries largas (posible tunneling)
tshark -r captura.pcap -Y "dns.qry.name" -T fields \
  -e dns.qry.name | awk 'length($0) > 50'

# NXDOMAIN responses (dominios no existentes)
tshark -r captura.pcap -Y "dns.flags.rcode == 3"
```

### TLS/SSL

```bash
# Client Hellos
tshark -r captura.pcap -Y "tls.handshake.type == 1"

# Server Hellos
tshark -r captura.pcap -Y "tls.handshake.type == 2"

# SNI (Server Name Indication)
tshark -r captura.pcap -Y "tls.handshake.extensions_server_name" -T fields \
  -e tls.handshake.extensions_server_name

# Certificados
tshark -r captura.pcap -Y "tls.handshake.certificate" -T fields \
  -e x509sat.printableString
```

---

## Detección de Ataques

### Deauth Flood

```bash
# Contar deauth en ventanas de tiempo
tshark -r captura.pcap -Y "wlan.fc.type_subtype == 0x0c" -T fields \
  -e frame.time_relative | awk '{print int($1)}' | sort | uniq -c

# Detectar broadcast deauth
tshark -r captura.pcap -Y "wlan.fc.type_subtype == 0x0c && wlan.da == ff:ff:ff:ff:ff:ff"
```

### Evil Twin Detection

```bash
# Buscar SSIDs duplicados con diferentes BSSIDs
tshark -r captura.pcap -Y "wlan.ssid" -T fields \
  -e wlan.ssid -e wlan.bssid | sort | uniq

# Comparar signal strength (RSSI) para mismo SSID
tshark -r captura.pcap -Y "wlan.fc.type_subtype == 0x08" -T fields \
  -e wlan.ssid -e wlan.bssid -e radiotap.dbm_antsignal
```

### KRACK Detection

```bash
# Buscar reutilización de nonces
tshark -r captura.pcap -Y "eapol" -T fields \
  -e wlan.da -e eapol.keydes.nonce | sort | uniq -d
```

---

## Utilidades

### capinfos (Información de PCAP)

```bash
# Info completa
capinfos captura.pcap

# Solo estadísticas básicas
capinfos -T captura.pcap

# Múltiples archivos
capinfos *.pcap
```

### editcap (Edición de PCAP)

```bash
# Extraer rango de paquetes
editcap -r captura.pcap output.pcap 100-200

# Dividir por tiempo (cada 60 segundos)
editcap -i 60 captura.pcap output.pcap

# Cambiar formato
editcap -F pcap captura.pcapng output.pcap
```

### mergecap (Unir PCAPs)

```bash
# Unir múltiples capturas
mergecap -w combined.pcap capture1.pcap capture2.pcap capture3.pcap

# Unir y ordenar por timestamp
mergecap -w combined.pcap -a capture*.pcap
```

---

## Scripts Bash Útiles

### Extraer handshakes de múltiples PCAPs

```bash
#!/bin/bash
for pcap in *.pcap; do
    if tshark -r "$pcap" -Y "eapol" 2>/dev/null | grep -q "EAPOL"; then
        echo "[+] Handshake encontrado en: $pcap"
        cp "$pcap" handshakes/
    fi
done
```

### Buscar SSIDs específicos

```bash
#!/bin/bash
TARGET_SSID="MyNetwork"
for pcap in *.pcap; do
    if tshark -r "$pcap" -Y "wlan.ssid == \"$TARGET_SSID\"" 2>/dev/null | grep -q "$TARGET_SSID"; then
        echo "[+] $TARGET_SSID encontrado en: $pcap"
    fi
done
```

### Detectar deauth masivo

```bash
#!/bin/bash
THRESHOLD=10
for pcap in *.pcap; do
    count=$(tshark -r "$pcap" -Y "wlan.fc.type_subtype == 0x0c" 2>/dev/null | wc -l)
    if [ "$count" -gt "$THRESHOLD" ]; then
        echo "[!] Posible deauth attack en $pcap: $count frames"
    fi
done
```

---

## Recursos Adicionales

### Bases de Datos de Contraseñas

- **rockyou.txt**: `~14M passwords` (más común)
- **SecLists**: https://github.com/danielmiessler/SecLists
- **CrackStation**: https://crackstation.net/crackstation-wordlist-password-cracking-dictionary.htm

### Reglas de Hashcat

```bash
# Ubicación típica
/usr/share/hashcat/rules/

# Reglas populares
- best64.rule
- dive.rule
- rockyou-30000.rule
```

### Sample PCAPs

- Wireshark: https://gitlab.com/wireshark/wireshark/-/wikis/SampleCaptures
- Mathy Vanhoef: https://github.com/vanhoefm/wifi-example-captures
- Netresec: https://www.netresec.com/?page=PcapFiles

---

## Tips y Trucos

### Optimizar análisis de PCAPs grandes

```bash
# Crear índice
tshark -r huge.pcap -q -z io,phs > index.txt

# Filtrar antes de analizar
tshark -r huge.pcap -Y "wlan" -w filtered.pcap
```

### Exportar objetos HTTP

```bash
# CLI (si soportado)
tshark -r captura.pcap --export-objects http,output_dir/

# GUI
# Wireshark → File → Export Objects → HTTP
```

### Verificar integridad de handshake

```bash
# Método 1: aircrack-ng
aircrack-ng captura.cap
# Buscar "1 handshake" en output

# Método 2: tshark
tshark -r captura.pcap -Y "eapol" | wc -l
# Debe ser 4 (o múltiplo de 4)
```

---

**Última actualización**: Octubre 2025

Para más información, consulta las man pages:
- `man tshark`
- `man aircrack-ng`
- `man hashcat`
