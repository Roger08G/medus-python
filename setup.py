#!/usr/bin/env python3
import sys
import os
import argparse
import subprocess
import time
from datetime import datetime
from colorama import Fore, Style, init

init(autoreset=True)

LOG_FILE = "logs/setup.log"
LOGS_ENABLED = False

def log_message(message, level="INFO"):
    if not LOGS_ENABLED:
        return
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    level_upper = level.upper()
    color = Fore.CYAN if level_upper == "INFO" else Fore.RED if level_upper == "ERROR" else Fore.YELLOW if level_upper == "WARNING" else Fore.WHITE
    log_entry = f"[{timestamp}] [{level_upper}] {message}"
    try:
        with open(LOG_FILE, "a", encoding="utf-8") as f:
            f.write(log_entry + "\n")
    except Exception as e:
        print(Fore.RED + f"Error escribiendo en el log: {e}" + Style.RESET_ALL)
    print(f"{color}{log_entry}{Style.RESET_ALL}")

def banner():
    banner_text = rf"""
{Fore.CYAN}{Style.BRIGHT}

███╗░░░███╗███████╗██████╗░██╗░░░██╗░██████╗░░░░░░██████╗░██╗░░░██╗████████╗██╗░░██╗░█████╗░███╗░░██╗
████╗░████║██╔════╝██╔══██╗██║░░░██║██╔════╝░░░░░░██╔══██╗╚██╗░██╔╝╚══██╔══╝██║░░██║██╔══██╗████╗░██║
██╔████╔██║█████╗░░██║░░██║██║░░░██║╚█████╗░█████╗██████╔╝░╚████╔╝░░░░██║░░░███████║██║░░██║██╔██╗██║
██║╚██╔╝██║██╔══╝░░██║░░██║██║░░░██║░╚═══██╗╚════╝██╔═══╝░░░╚██╔╝░░░░░██║░░░██╔══██║██║░░██║██║╚████║
██║░╚═╝░██║███████╗██████╔╝╚██████╔╝██████╔╝░░░░░░██║░░░░░░░░██║░░░░░░██║░░░██║░░██║╚█████╔╝██║░╚███║
╚═╝░░░░░╚═╝╚══════╝╚═════╝░░╚═════╝░╚═════╝░░░░░░░╚═╝░░░░░░░░╚═╝░░░░░░╚═╝░░░╚═╝░░╚═╝░╚════╝░╚═╝░░╚══╝
  
Subdomain Enumeration Only
{Fore.CYAN}
=================================================================================
    """
    print(banner_text)

def run_module(module_cmd, description):
    print(Fore.YELLOW + f"[{description}] ⏳ Iniciando..." + Style.RESET_ALL)
    log_message(f"Iniciando módulo: {description}", level="INFO")
    start = time.time()
    try:
        subprocess.run(module_cmd, check=True)
        elapsed = time.time() - start
        print(Fore.GREEN + f"[{description}] Completado en {round(elapsed, 2)}s." + Style.RESET_ALL)
        log_message(f"Módulo completado: {description} en {round(elapsed, 2)}s", level="INFO")
    except subprocess.CalledProcessError as e:
        print(Fore.RED + f"[{description}] Error: {e}" + Style.RESET_ALL)
        log_message(f"Error en módulo: {description} - {e}", level="ERROR")

def process_domain(domain):
    # Se invoca el script de shell Sublisting.sh para la enumeración de subdominios
    run_module(["bash", "Sublisting.sh", domain], "SUBDOMAIN ENUMERATION")

def main():
    global LOGS_ENABLED
    banner()
    parser = argparse.ArgumentParser(description="Herramienta de Enumeración de Subdominios")
    parser.add_argument("-o", required=True, help="Archivo de entrada con dominios (se permiten comodines)")
    parser.add_argument("-l", "--logs", action="store_true", help="Habilitar registro de logs detallados")
    args = parser.parse_args()
    
    LOGS_ENABLED = args.logs
    if LOGS_ENABLED:
        print(Fore.MAGENTA + "[LOGS] Registro de logs habilitado." + Style.RESET_ALL)
        os.makedirs("logs", exist_ok=True)
        with open(LOG_FILE, "w", encoding="utf-8") as f:
            f.write(f"Setup started at {datetime.now()}\n")
    else:
        print(Fore.MAGENTA + "[LOGS] Registro de logs deshabilitado." + Style.RESET_ALL)
    
    os.makedirs("output", exist_ok=True)
    
    if not os.path.exists(args.o):
        print(Fore.RED + f"[ERROR] El archivo {args.o} no existe." + Style.RESET_ALL)
        return
    
    with open(args.o, "r", encoding="utf-8") as infile:
        domains = [line.strip() for line in infile if line.strip()]
    
    for domain in domains:
        print(Fore.YELLOW + f"[PROCESS] Procesando dominio: {domain}" + Style.RESET_ALL)
        process_domain(domain)
        print(Fore.YELLOW + f"[PROCESS] Finalizado el procesamiento de: {domain}" + Style.RESET_ALL)
    
    print(Fore.GREEN + "[SETUP COMPLETADO] Todos los dominios han sido procesados." + Style.RESET_ALL)
    log_message("Setup completado con éxito.", level="INFO")

if __name__ == "__main__":
    main()
