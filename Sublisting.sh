#!/bin/bash

if [ -z "$1" ]; then
  echo "[ERROR] Uso: $0 <dominio>" >&2
  exit 1
fi

DOMAIN="$1"
echo "[INFO] Procesando el dominio: $DOMAIN" >&2

# Ejecutar subfinder
echo "[INFO] Ejecutando subfinder..." >&2
subfinder -all -d "$DOMAIN" -o domain1.txt --recursive >/dev/null 2>&1
echo "[OK] subfinder completado." >&2

# Ejecutar amass (con timeout de 30 minutos)
echo "[INFO] Ejecutando amass (límite: 30 minutos)..." >&2
timeout 30m amass enum -d "$DOMAIN" > results.txt 2>/dev/null
echo "[OK] amass completado." >&2

# Filtrar resultados de amass
echo "[INFO] Filtrando resultados de amass..." >&2
grep -oP "\b([a-zA-Z0-9.-]+\.$DOMAIN)\b" results.txt > domain2.txt
echo "[OK] Filtrado de amass completado." >&2

# Ejecutar assetfinder
echo "[INFO] Ejecutando assetfinder..." >&2
assetfinder "$DOMAIN" > domain10.txt 2>/dev/null
echo "[OK] assetfinder completado." >&2

# Ejecutar sublist3r
echo "[INFO] Ejecutando sublist3r..." >&2
sublist3r -d "$DOMAIN" > results_sub.txt 2>/dev/null
echo "[OK] sublist3r completado." >&2

# Filtrar resultados de sublist3r
echo "[INFO] Filtrando resultados de sublist3r..." >&2
grep -oP "\b([a-zA-Z0-9.-]+\.$DOMAIN)\b" results_sub.txt > domain3.txt
sed 's/^...//' domain3.txt > domain4.txt
echo "[OK] Filtrado de sublist3r completado." >&2

# Ejecutar findomain
echo "[INFO] Ejecutando findomain..." >&2
findomain -t "$DOMAIN" -u domain7.txt 2>/dev/null
echo "[OK] findomain completado." >&2

# Ejecutar shuffledns
echo "[INFO] Ejecutando shuffledns..." >&2
shuffledns -d "$DOMAIN" -list /usr/share/wordlists/dns/subdomains-top1million-5000.txt -o domain8.txt 2>/dev/null
echo "[OK] shuffledns completado." >&2

# Ejecutar dnsenum
echo "[INFO] Ejecutando dnsenum..." >&2
if command -v dnsenum >/dev/null 2>&1; then
    dnsenum "$DOMAIN" > dnsenum.txt 2>/dev/null
    echo "[OK] dnsenum completado." >&2
else
    echo "[WARNING] dnsenum no está instalado, saltando." >&2
fi

# Ejecutar dnsrecon
echo "[INFO] Ejecutando dnsrecon..." >&2
if command -v dnsrecon >/dev/null 2>&1; then
    dnsrecon -d "$DOMAIN" > dnsrecon.txt 2>/dev/null
    echo "[OK] dnsrecon completado." >&2
else
    echo "[WARNING] dnsrecon no está instalado, saltando." >&2
fi

# Ejecutar crt.sh
echo "[INFO] Ejecutando crt.sh..." >&2
curl -s "https://crt.sh/?q=%25.$DOMAIN&output=csv" | cut -d, -f5 | sort -u > domain5.txt
cat domain5.txt | sed 's/"//g' | sed 's/ CN=.*//g' | sed 's/^[ \t]*//;s/[ \t]*$//' | grep "\.$DOMAIN" > domain6.txt
echo "[OK] crt.sh completado." >&2

# Unificar resultados en archivo temporal "domain"
echo "[INFO] Unificando resultados..." >&2
cat domain1.txt domain4.txt domain2.txt domain6.txt domain10.txt domain7.txt domain8.txt \
    dnsenum.txt dnsrecon.txt 2>/dev/null | sort | uniq > domain
echo "[OK] Resultados unificados en 'domain'." >&2

# Llamar a finder.py para validar subdominios y actualizar output/valid_domains.txt
echo "[INFO] Ejecutando finder.py para validar subdominios..." >&2
python3 ./finder.py ./domain
echo "[OK] Ejecución de finder.py completada." >&2

# Eliminar archivos temporales
echo "[INFO] Eliminando archivos temporales..." >&2
rm -f domain1.txt results.txt domain2.txt results_sub.txt domain3.txt domain4.txt domain5.txt domain6.txt \
      domain7.txt domain8.txt dnsenum.txt domain10.txt dnsrecon.txt test.com_ips.txt domain
rm -f *_ips.txt
echo "[OK] Archivos temporales eliminados." >&2

echo "[INFO] Proceso completado." >&2