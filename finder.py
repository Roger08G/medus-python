import httpx
from colorama import Fore, Style, init
import re
import sys
import os

init(autoreset=True)

if len(sys.argv) < 2:
    print(f"{Fore.RED}[ERROR] No se proporcionó el archivo de dominios.{Style.RESET_ALL}")
    sys.exit(1)

file_path = sys.argv[1]

with open(file_path, "r") as file:
    domains = file.readlines()

domains = [domain.strip() for domain in domains]

def is_valid_format(domain):
    if not domain or any(c in domain for c in "\n\r\t"):
        return False
    if not re.match(r"^[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,}$", domain):
        return False
    return True

valid_domains = []
invalid_domains = []

client = httpx.Client()

def is_valid_domain(domain):
    url_https = f"https://{domain}"
    url_http = f"http://{domain}"
    try:
        response = client.get(url_https, timeout=5)
        if response.status_code != 200:
            return False
        print(f"{Fore.GREEN}[INFO] {domain} es válido (https){Style.RESET_ALL}")
        valid_domains.append(domain)
    except httpx.RequestError:
        try:
            response = client.get(url_http, timeout=5)
            if response.status_code != 200:
                return False
            print(f"{Fore.GREEN}[INFO] {domain} es válido (http){Style.RESET_ALL}")
            valid_domains.append(domain)
        except httpx.RequestError:
            print(f"{Fore.RED}[ERROR] {domain} no es válido.{Style.RESET_ALL}")
            invalid_domains.append(domain)
            return False
    return True

print(f"{Fore.YELLOW}[INFO] Iniciando la verificación de dominios...{Style.RESET_ALL}")
for domain in domains:
    if not is_valid_format(domain):
        print(f"{Fore.RED}[ERROR] {domain} tiene un formato inválido o caracteres no imprimibles.{Style.RESET_ALL}")
        invalid_domains.append(domain)
        continue
    print(f"{Fore.CYAN}[INFO] Verificando {domain}...{Style.RESET_ALL}")
    is_valid_domain(domain)

os.makedirs("output", exist_ok=True)
output_file = os.path.join("output", "valid_domains.txt")
existing_domains = set()
if os.path.exists(output_file):
    with open(output_file, "r") as f:
        existing_domains = set(line.strip() for line in f if line.strip())

all_valid_domains = existing_domains.union(set(valid_domains))

with open(output_file, "w") as file:
    for domain in sorted(all_valid_domains):
        file.write(domain + "\n")

print(f"{Fore.YELLOW}[INFO] Proceso terminado.{Style.RESET_ALL}")
print(f"{Fore.GREEN}[INFO] Los dominios válidos están en '{output_file}'.{Style.RESET_ALL}")
