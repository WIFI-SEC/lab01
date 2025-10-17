#!/bin/bash

======================================================

Script: setup_wifi_lab.sh

Descripción: Prepara un laboratorio WiFi con PCAPs públicos

Autor: UTN - Laboratorio Blockchain & Ciberseguridad

======================================================

set -e

Crear estructura de carpetas

mkdir -p wifi_lab/{pcaps,outputs,screenshots,scripts}

cd wifi_lab

echo “[+] Descargando PCAPs públicos…”

PCAPs seleccionados (repositorios públicos)

wget -O pcaps/wpa2_handshake.pcapng https://raw.githubusercontent.com/vanhoefm/wifi-example-captures/master/wpa2_personal.pcapng
wget -O pcaps/pmkid_capture.pcapng https://raw.githubusercontent.com/vanhoefm/wifi-example-captures/master/wpa2_pmkid.pcapng
wget -O pcaps/captive_portal.pcapng https://gitlab.com/wireshark/wireshark/-/raw/master/test/captures/http.cap
wget -O pcaps/wpa3_sae_example.pcapng https://raw.githubusercontent.com/vanhoefm/wifi-example-captures/master/wpa3_sae.pcapng

echo “[+] Calculando hashes SHA256 para los PCAPs descargados…”
sha256sum pcaps/*.pcapng > manifest.sha256

echo “[+] Estructura creada correctamente:”
tree -L 2

echo “[+] Laboratorio WiFi preparado con éxito.”

