#!/bin/bash





# Utilitzem $USER per detectar automàticament qui executa el script
LOG_DIR="/home/alex/Desktop/Automatitzaci-de-tasques-i-guions-de-Shell/practica-automatitzacio/serveis/log"
LOG_FILE="$LOG_DIR/backup.log"

# 10 MB en bytes 
MAX_SIZE=10485760 

# Comprovar si el log existeix
if [ -f "$LOG_FILE" ]; then
    SIZE=$(du -b "$LOG_FILE" | cut -f1)
    
    if [ "$SIZE" -gt "$MAX_SIZE" ]; then
        echo "Rotant log: $LOG_FILE (Mida: $SIZE bytes)"
        
        # Rotació múltiple per no perdre informació immediatament
        [ -f "${LOG_FILE}.2.old" ] && mv "${LOG_FILE}.2.old" "${LOG_FILE}.3.old"
        [ -f "${LOG_FILE}.1.old" ] && mv "${LOG_FILE}.1.old" "${LOG_FILE}.2.old"
        mv "$LOG_FILE" "${LOG_FILE}.1.old"
        
        # Crear el nou fitxer buit i mantenir permisos
        touch "$LOG_FILE"
        chmod 644 "$LOG_FILE"
        
        # Notificació al sistema (Activitat 5)
        logger -t log_manager "Incident resolt: El log de backup superava els 10MB i s'ha rotat correctament."
    fi
fi