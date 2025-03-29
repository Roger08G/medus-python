#!/bin/bash

# Verificar si se ejecuta como root
if [ "$EUID" -ne 0 ]; then
  echo "[ERROR] Por favor, ejecuta este script como root."
  exit 1
fi

echo "[INFO] Actualizando repositorios..."
apt-get update -y -qq > /dev/null 2>&1
echo "[OK] Repositorios actualizados."

echo "[INFO] Instalando dependencias del sistema..."
apt-get install -y -qq python3 python3-pip curl wget git unzip > /dev/null 2>&1
echo "[OK] Dependencias del sistema instaladas."

echo "[INFO] Instalando Go..."
if ! command -v go &> /dev/null; then
  apt-get install -y -qq golang > /dev/null 2>&1
  echo "[OK] Go instalado."
else
  echo "[INFO] Go ya está instalado."
fi

echo "[INFO] Instalando dependencias de Python..."
sudo pip3 install -q colorama beautifulsoup4 httpx requests sublist3r --break-system-packages > /dev/null 2>&1
sudo pip3 install httpx aiohttp --break-system-packages > /dev/null 2>&1
echo "[OK] Dependencias de Python instaladas."

# Configurar GOPATH global
if [ -z "$GOPATH" ]; then
  export GOPATH="/opt/go"
  mkdir -p /opt/go/bin
  echo "[INFO] GOPATH configurado a /opt/go"
fi
export PATH="$PATH:$(go env GOPATH)/bin"
echo "[INFO] Se ha añadido $(go env GOPATH)/bin al PATH."

# Asegurar que /usr/local/bin esté en el PATH
export PATH="$PATH:/usr/local/bin"
echo "[INFO] Se ha añadido /usr/local/bin al PATH."

# Instalar subfinder
if ! command -v subfinder &> /dev/null; then
  echo "[INFO] Instalando subfinder..."
  go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest > /dev/null 2>&1
  cp "$(go env GOPATH)"/bin/subfinder /usr/local/bin/
  echo "[OK] subfinder instalado."
else
  echo "[INFO] subfinder ya está instalado."
fi

# Instalar Dirsearch
if ! command -v dirsearch &> /devnull; then
  echo "[INFO] Instalando Dirsearch..."
  sudo apt install dirsearch > /dev/null 2>&1
  if command -v dirsearch &> /dev/null; then
    echo "[OK] Dirsearch instalado."
  else
    echo "[ERROR] Dirsearch no se encuentra en el PATH después de la instalación."
  fi
else
  echo "[INFO] Dirsearch ya está instalado."
fi

# Instalar amass
if ! command -v amass &> /dev/null; then
  echo "[INFO] Instalando amass..."
  sudo apt install snapd  & sudo snap install amass > /dev/null 2>&1
  if command -v amass &> /dev/null; then
    echo "[OK] amass instalado."
  else
    echo "[ERROR] amass no se encuentra en el PATH después de la instalación."
  fi
else
  echo "[INFO] amass ya está instalado."
fi

# Instalar assetfinder
if ! command -v assetfinder &> /dev/null; then
  echo "[INFO] Instalando assetfinder..."
  go install -v github.com/tomnomnom/assetfinder@latest > /dev/null 2>&1
  cp "$(go env GOPATH)"/bin/assetfinder /usr/local/bin/
  echo "[OK] assetfinder instalado."
else
  echo "[INFO] assetfinder ya está instalado."
fi

# Instalar shuffledns
if ! command -v shuffledns &> /dev/null; then
  echo "[INFO] Instalando shuffledns..."
  go install -v github.com/projectdiscovery/shuffledns/cmd/shuffledns@latest > /dev/null 2>&1
  cp "$(go env GOPATH)"/bin/shuffledns /usr/local/bin/
  echo "[OK] shuffledns instalado."
else
  echo "[INFO] shuffledns ya está instalado."
fi

# Instalar findomain
if ! command -v findomain &> /dev/null; then
  echo "[INFO] Instalando findomain..."
  wget -q https://github.com/Findomain/Findomain/releases/download/8.2.1/findomain-linux -O /usr/local/bin/findomain
  chmod +x /usr/local/bin/findomain
  echo "[OK] findomain instalado."
else
  echo "[INFO] findomain ya está instalado."
fi

# Instalar dnsenum
if ! command -v dnsenum &> /dev/null; then
  echo "[INFO] Instalando dnsenum..."
  apt-get install -y -qq dnsenum > /dev/null 2>&1
  echo "[OK] dnsenum instalado."
else
  echo "[INFO] dnsenum ya está instalado."
fi

# Instalar dnsrecon
if ! command -v dnsrecon &> /dev/null; then
  echo "[INFO] Instalando dnsrecon..."
  apt-get install -y -qq dnsrecon > /dev/null 2>&1
  echo "[OK] dnsrecon instalado."
else
  echo "[INFO] dnsrecon ya está instalado."
fi

# Instalar sublist3r
if ! command -v sublist3r &> /dev/null; then
  echo "[INFO] Instalando sublist3r..."
  sudo pip3 install -q sublist3r --break-system-packages
  # Verificar si el comando sublist3r se instaló en /usr/local/bin, sino copiarlo desde ~/.local/bin
  if ! command -v sublist3r &> /dev/null; then
    if [ -f "$HOME/.local/bin/sublist3r" ]; then
      cp "$HOME/.local/bin/sublist3r" /usr/local/bin/
      echo "[OK] sublist3r copiado a /usr/local/bin."
    else
      echo "[ERROR] No se pudo encontrar sublist3r en el PATH."
    fi
  else
    echo "[OK] sublist3r instalado."
  fi
else
  echo "[INFO] sublist3r ya está instalado."
fi

chmod +x finder.py
chmod +x Sublisting.sh

echo "[INFO] Todas las dependencias se han instalado correctamente."