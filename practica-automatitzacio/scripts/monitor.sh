#!/bin/bash

# Colors
color_red="\e[31m"
color_green="\e[32m"
color_yellow="\e[33m"
end_color="\e[0m"


# Configuracio
LOG_FILE="/home/adria/Desktop/practica-automatitzacio/logs/monitor.log"
CPU_THRESHOLD=80
MEMORY_THRESHOLD=80
DISK_THRESHOLD=80

echo -e "${color_yellow}[+] Iniciant monitorització...${end_color}"
# Espai en disc
DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -gt "$DISK_THRESHOLD" ]; then
    echo -e "${color_red}[!] Alerta: L'ús del disc és del ${DISK_USAGE}%${end_color}"
    echo "$(date): Alerta de disc - ${DISK_USAGE}%" >> "$LOG_FILE"
else
    echo -e "${color_green}[+] L'ús del disc és del ${DISK_USAGE}%${end_color}"
fi
# Consum de CPU i memoria
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
MEMORY_USAGE=$(free | grep Mem | awk '{print $3/$2 * 100.0}')

echo -e "${color_yellow}[+] Monitoritzant CPU i memòria...${end_color}" 
echo -e "[+] CPU: ${CPU_USAGE}% | Memòria: ${MEMORY_USAGE}%"

# Registres d'autenticacio
echo -e "${color_yellow}[+] Darrers intents fallits: ${end_color}" >> $LOG_FILE
journalctl -u sshd --since "1 hour ago" | grep "Failed password" >> $LOG_FILE
echo "------------------------------" >> $LOG_FILE
