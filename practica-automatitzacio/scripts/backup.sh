#!/bin/bash

#Colors 
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
yellowColour="\e[0;33m\033[1m"

#CNTRL+C
function ctrl_c(){
  echo -e "\n\n${redColour}[!] Sortint...${endColour}"
  exit 1
}

trap ctrl_c INT

PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
LOCKFILE="/tmp/backup_script.lock"

# Comprovar si ja hi ha una instància en execució
if [ -e "$LOCKFILE" ]; then
    echo -e "${redColour}[!] Ja hi ha una instància del script en execució. Sortint...${endColour}"
    exit 1
else
    touch "$LOCKFILE"
fi

# Menu d'ajuda
function show_help() {
    echo -e "${yellowColour}Us: $0 [OPCIONS]${endColour}"
    echo "Parametres:"
    echo "  -o: Directori d'origen de les dades."
    echo "  -d: Directori de destí de la còpia."
    echo "  -l: Camí complet al fitxer de log."
    echo "  -n: Mode --dry-run (simula l'operació sense fer canvis)."
    echo "  -h: Mostra ajuda."
    exit 0
}

# Validar els paràmetres d'entrada

DRY_RUN=""

while getopts "o:d:l:nh" opt; do
    case $opt in
        o) ORIGEN="$OPTARG" ;;
        d) DESTI="$OPTARG" ;;
        l) LOG="$OPTARG" ;;
        n) DRY_RUN="--dry-run" ;;
        h) show_help ;;
        *) echo -e "${redColour}Opció no vàlida: -$OPTARG${endColour}" | show_help;;
    esac
done

# Validacio de prerequisits 
if [[ -z "$ORIGEN" || -z "$DESTI" || -z "$LOG" ]]; then
    echo -e "${redColour}Error 1: Cal especificar el origen, destí i el fitxer de log.${endColour}"
    rm -rf "$LOCKFILE"
    show_help
fi

if [[ ! -d "$ORIGEN" ]]; then 
    echo -e "${redColour}Error 2: El directori d'origne no existeix.${endColour}"
    rm -rf "$LOCKFILE"
    exit 1
fi

if [[ ! -d "$DESTI" ]]; then 
    echo -e "${redColour}Error 3: El directori de destí no existeix.${endColour}"
    rm -rf "$LOCKFILE"
    exit 1
fi

# Realitzar la copia de seguretat
echo -e "${greenColour}[+] Iniciant copia de seguretat...${endColour}"
echo "$(date '+%Y-%m-%d %H:%M:%S') [+] Iniciant copia de seguretat incremental d'$ORIGEN a $DESTI" >> "$LOG"

# Utilitzar rsync per fer la còpia de seguretat incremental
rsync -avz $DRY_RUN --delete "$ORIGEN/" "$DESTI/" >> "$LOG" 2>&1

estatus=$?

if [ $estatus -eq 0 ]; then 
    # Notificació d'èxit al log del sistema
    logger -t backup_script -p user.info "Copia de seguretat d'$ORIGEN a $DESTI completada amb èxit."


    if [[ -z "$DRY_RUN" ]]; then
        # Aplicar restricions al desti
        chmod 700 "$DESTI"
        
        # Generar el hash SHA256
        echo -e "${yellowColour}[+] Generant hashes d'integritat...${endColour}"
        echo "$(date '+%Y-%m-%d %H:%M:%S') [+] Generant hash SHA256 del contingut del directori de destí." >> "$LOG"
        
        find "$DESTI" -type f -not -name "*.sha256" -exec sha256sum {} + >"$DESTI/backup_hashes.sha256"
        
        # Protegir el fitxer de hash
        chmod 400 "$DESTI/backup_hashes.sha256"
    fi
    echo "$(date '+%Y-%m-%d %H:%M:%S') [+] Còpia de seguretat i verificació completades amb èxit." >> "$LOG"
else
    echo -e "${redColour}[!] Error en la còpia de seguretat. Notificant incident...${endColour}"
    logger -t backup_script -p user.err "Error en la còpia de seguretat d'$ORIGEN a $DESTI amb el codi $estatus. Revisar el $LOG per més detalls."
    cp "$LOG" "${LOG}.$(date +%Y%m%d_%H%M).evidence"
    rm -rf "$LOCKFILE"
    exit $estatus
fi

echo -e "${greenColour}[+] Procés finalitzat correctament.${endColour}"
rm -rf "$LOCKFILE"
exit 0 


