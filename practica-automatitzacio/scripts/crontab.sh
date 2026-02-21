#!/bin/bash
# Colors 
red_color="\e[31m"
green_color="\e[32m"
end_color="\e[0m"
purple_color="\e[35m"
gray_color="\e[0;37m\033[1m"

SCRIPT_PATH=""

echo -e "${gray_color}[+] Introdueix la ${purple_color}ruta absoluta de l'script de backup${end_color}${gray_color} i les opcions necessaries;\n ${purple_color}-o${end_color} ${gray_color}Directori d'origen de les dades\n ${purple_color}-d${end_color} ${gray_color}Directori desti de les dades\n ${purple_color}-l ${gray_color}Ruta absoluta al fitxer de log${end_color}" && read -p "Ruta de l'script: " SCRIPT_PATH

if [[ ! -f "$SCRIPT_PATH" ]]; then
    echo -e "${red_color}[!]Error: L'arxiu no existeix.${end_color}"
    exit 1
fi 

if [[ ! -x "$SCRIPT_PATH" ]]; then
    echo -e "${red_color}[!] Error: L'arxiu no es executable.${end_color}"
    exit 1
fi

CRONTAB_JOB="0 3 * * * $SCRIPT_PATH >> /tmp/backup.log 2>&1"

(crontab -l 2>/dev/null | grep -F "$CRONTAB_JOB") || (crontab -l 2>/dev/null; echo "$CRONTAB_JOB") | crontab -
echo -e "${green_color}[+] Tasca cron creada amb exit .${end_color}"
