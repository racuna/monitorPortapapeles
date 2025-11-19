#!/bin/bash

# Monitor de Portapapeles para Linux
# Funciona con X11 y Wayland, múltiples entornos de escritorio

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # Sin color

# Detectar sistema de notificaciones disponible
detectar_notificaciones() {
    if command -v notify-send &> /dev/null; then
        echo "notify-send"
    elif command -v kdialog &> /dev/null; then
        echo "kdialog"
    elif command -v zenity &> /dev/null; then
        echo "zenity"
    else
        echo "terminal"
    fi
}

# Detectar herramienta de portapapeles disponible
detectar_portapapeles() {
    # Preferencia: xclip > xsel > wl-paste (Wayland)
    if command -v xclip &> /dev/null; then
        echo "xclip"
    elif command -v xsel &> /dev/null; then
        echo "xsel"
    elif command -v wl-paste &> /dev/null; then
        echo "wl-paste"
    else
        echo "none"
    fi
}

# Función para mostrar notificaciones
mostrar_notificacion() {
    local titulo="$1"
    local mensaje="$2"
    
    case "$NOTIF_CMD" in
        "notify-send")
            notify-send -i edit-copy "$titulo" "$mensaje" -t 3000
            ;;
        "kdialog")
            kdialog --title "$titulo" --passivepopup "$mensaje" 3
            ;;
        "zenity")
            zenity --notification --text="$titulo: $mensaje" --timeout=3
            ;;
        "terminal")
            echo -e "${GREEN}[$(date '+%H:%M:%S')]${NC} $titulo: $mensaje"
            ;;
    esac
}

# Función para obtener contenido del portapapeles
obtener_portapapeles() {
    case "$CLIP_CMD" in
        "xclip")
            xclip -selection clipboard -o 2>/dev/null
            ;;
        "xsel")
            xsel --clipboard --output 2>/dev/null
            ;;
        "wl-paste")
            wl-paste --no-newline 2>/dev/null
            ;;
        *)
            echo ""
            ;;
    esac
}

# Función para calcular hash SHA256
calcular_hash() {
    if [ -z "$1" ]; then
        echo ""
    else
        echo -n "$1" | sha256sum | awk '{print $1}'
    fi
}

# Inicialización
NOTIF_CMD=$(detectar_notificaciones)
CLIP_CMD=$(detectar_portapapeles)

echo -e "${GREEN}=== Monitor de Portapapeles para Linux ===${NC}"
echo -e "Sistema de notificaciones: ${YELLOW}$NOTIF_CMD${NC}"
echo -e "Herramienta de portapapeles: ${YELLOW}$CLIP_CMD${NC}"
echo ""

if [ "$CLIP_CMD" = "none" ]; then
    echo -e "${YELLOW}ERROR: No se encontró ninguna herramienta de portapapeles.${NC}"
    echo "Instala una de las siguientes:"
    echo "  - Para X11: sudo apt install xclip  (o xsel)"
    echo "  - Para Wayland: sudo apt install wl-clipboard"
    exit 1
fi

# Verificar permisos y notificar inicio
mostrar_notificacion "Monitor de Portapapeles" "Iniciado correctamente. Monitoreando cambios..."

hash_anterior=""
contador=0

# Loop principal
while true; do
    contenido_actual=$(obtener_portapapeles)
    hash_actual=$(calcular_hash "$contenido_actual")
    
    # Detectar cambio real en el portapapeles
    if [ -n "$hash_actual" ] && [ "$hash_actual" != "$hash_anterior" ]; then
        # Crear preview del contenido
        preview="$contenido_actual"
        if [ ${#preview} -gt 50 ]; then
            preview="${preview:0:50}..."
        fi
        
        # Reemplazar saltos de línea con espacios para la notificación
        preview=$(echo "$preview" | tr '\n' ' ')
        
        contador=$((contador + 1))
        mostrar_notificacion "Portapapeles Actualizado (#$contador)" "Copiado: $preview"
        
        # Guardar nuevo hash
        hash_anterior="$hash_actual"
        
        # Pequeña pausa para evitar duplicados (apps que actualizan múltiples veces)
        sleep 0.3
    fi
    
    # Intervalo de verificación
    sleep 0.2
done