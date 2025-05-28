#!/bin/bash

# Verifica se o Evolution está em execução
if ! pgrep evolution-source-registry >/dev/null; then
    echo "Evolution Data Server não está rodando"
    echo "Iniciando o serviço..."
    /usr/libexec/evolution-data-server/evolution-source-registry &
    sleep 3
fi

# Tenta acessar os eventos
EVENTS=$(evolution-calendar-factory --list-events "$(date +%Y-%m-%d)T00:00:00" "$(date +%Y-%m-%d)T23:59:59" 2>&1)

if [[ "$EVENTS" == *"No such interface"* ]]; then
    echo "Problema na interface D-Bus. Tentando método alternativo..."
    # Método alternativo usando gdbus
    gdbus call --session --dest org.gnome.evolution.dataserver.Calendar8 \
          --object-path /org/gnome/evolution/dataserver/Calendar/View42 \
          --method org.gnome.evolution.dataserver.Calendar.View.GetEvents \
          "$(date +%Y-%m-%d)T00:00:00" "$(date +%Y-%m-%d)T23:59:59" "" 0 0 | \
          grep -oP 'summary['\''"]\K[^'\''"]*'
else
    echo "$EVENTS" | grep -oP 'summary=\K[^,]*'
fi