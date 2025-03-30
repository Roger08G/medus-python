# Herramienta de Enumeración de Subdominios

Esta herramienta está diseñada exclusivamente para la enumeración de subdominios a partir de una lista de dominios.

## Instalación

1. Da permisos de ejecución al script de instalación:
   ```r
   chmod +x ./install.sh
   sudo ./install.sh
   ```

2. Ejecuta la herramienta:
    ```r
    python3 setup.py -o <archivo_de_dominios>
    ```

    - Ejecutar la herramienta con registros (logs)
    ```r
    python3 setup.py -o <archivo_de_dominios> -l
    ```
