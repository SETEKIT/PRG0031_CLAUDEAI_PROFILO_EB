#!/bin/bash
# =============================================================================
# CLAUDE CODE - Restore con Menu Selezione Backup
# Autore: Eliseo Bosco
# Progetto: PRG0031_CLAUDEAI_PROFILO_EB
#
# Uso:
#   ./restore.sh              # Menu interattivo (locale + iCloud)
#   ./restore.sh --local      # Solo backup locali
#   ./restore.sh --icloud     # Solo backup iCloud
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BACKUP_BASE="$PROJECT_DIR/backups"
ICLOUD_BACKUP_DIR="$HOME/Library/Mobile Documents/com~apple~CloudDocs/SETEK/backups-claude"
CLAUDE_HOME="$HOME/.claude"

# Colori
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

# Opzioni
SOURCE_FILTER="all"
if [[ "$1" == "--local" ]]; then
    SOURCE_FILTER="local"
elif [[ "$1" == "--icloud" ]]; then
    SOURCE_FILTER="icloud"
fi

echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║         CLAUDE CODE - Restore Backup                         ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Funzione per estrarre info dal manifest
get_backup_info() {
    local backup_path="$1"
    local source="$2"

    if [ -f "$backup_path/manifest.json" ]; then
        python3 -c "
import json
with open('$backup_path/manifest.json') as f:
    data = json.load(f)
    date = data.get('backup_date', 'N/A')[:16].replace('T', ' ')
    host = data.get('hostname', 'N/A')[:12]
    profiles = data.get('contents', {}).get('profiles', 0)
    commands = data.get('contents', {}).get('commands', 0)
    print(f'{date}  {host:<12}  {profiles:<4}  {commands:<4}')
" 2>/dev/null || echo "N/A"
    else
        backup_name=$(basename "$backup_path")
        date_part=$(echo "$backup_name" | sed 's/backup-//' | sed 's/_/ /')
        echo "$date_part"
    fi
}

# Raccogli backup da entrambe le sorgenti
declare -a ALL_BACKUPS
declare -a BACKUP_SOURCES

# Backup locali
if [[ "$SOURCE_FILTER" == "all" ]] || [[ "$SOURCE_FILTER" == "local" ]]; then
    if [ -d "$BACKUP_BASE" ]; then
        while IFS= read -r backup; do
            ALL_BACKUPS+=("$backup")
            BACKUP_SOURCES+=("LOCAL")
        done < <(ls -1d "$BACKUP_BASE"/backup-* 2>/dev/null | sort -r)
    fi
fi

# Backup iCloud
if [[ "$SOURCE_FILTER" == "all" ]] || [[ "$SOURCE_FILTER" == "icloud" ]]; then
    if [ -d "$ICLOUD_BACKUP_DIR" ]; then
        while IFS= read -r backup; do
            ALL_BACKUPS+=("$backup")
            BACKUP_SOURCES+=("iCLOUD")
        done < <(ls -1d "$ICLOUD_BACKUP_DIR"/backup-* 2>/dev/null | sort -r)
    fi
fi

# Verifica backup disponibili
if [ ${#ALL_BACKUPS[@]} -eq 0 ]; then
    echo -e "${RED}Nessun backup disponibile.${NC}"
    echo ""
    echo "Percorsi verificati:"
    echo "  Locale:  $BACKUP_BASE"
    echo "  iCloud:  $ICLOUD_BACKUP_DIR"
    echo ""
    echo "Esegui prima: ./scripts/backup.sh --icloud"
    exit 1
fi

# Menu selezione sorgente
echo -e "${CYAN}Sorgente backup:${NC}"
echo ""
LOCAL_COUNT=$(ls -1d "$BACKUP_BASE"/backup-* 2>/dev/null | wc -l | tr -d ' ')
ICLOUD_COUNT=$(ls -1d "$ICLOUD_BACKUP_DIR"/backup-* 2>/dev/null | wc -l | tr -d ' ')

echo -e "  ${BOLD}L)${NC} Backup Locali      (${LOCAL_COUNT} disponibili)"
echo -e "  ${BOLD}I)${NC} Backup iCloud      (${ICLOUD_COUNT} disponibili)"
echo -e "  ${BOLD}T)${NC} Tutti i backup     (${#ALL_BACKUPS[@]} totali)"
echo -e "  ${BOLD}0)${NC} Annulla"
echo ""

read -p "Seleziona sorgente [L/I/T/0]: " source_choice

case "${source_choice^^}" in
    L)
        SOURCE_FILTER="local"
        ALL_BACKUPS=()
        BACKUP_SOURCES=()
        while IFS= read -r backup; do
            ALL_BACKUPS+=("$backup")
            BACKUP_SOURCES+=("LOCAL")
        done < <(ls -1d "$BACKUP_BASE"/backup-* 2>/dev/null | sort -r)
        ;;
    I)
        SOURCE_FILTER="icloud"
        ALL_BACKUPS=()
        BACKUP_SOURCES=()
        while IFS= read -r backup; do
            ALL_BACKUPS+=("$backup")
            BACKUP_SOURCES+=("iCLOUD")
        done < <(ls -1d "$ICLOUD_BACKUP_DIR"/backup-* 2>/dev/null | sort -r)
        ;;
    T)
        SOURCE_FILTER="all"
        ;;
    0)
        echo "Operazione annullata."
        exit 0
        ;;
    *)
        echo -e "${RED}Selezione non valida.${NC}"
        exit 1
        ;;
esac

if [ ${#ALL_BACKUPS[@]} -eq 0 ]; then
    echo -e "${RED}Nessun backup disponibile per la sorgente selezionata.${NC}"
    exit 1
fi

# Mostra menu di selezione backup
echo ""
echo -e "${CYAN}Backup disponibili:${NC}"
echo ""
echo -e "${BOLD}  #   Sorgente   Data              Host          Prof  Cmd${NC}"
echo "  ────────────────────────────────────────────────────────────────"

i=1
for idx in "${!ALL_BACKUPS[@]}"; do
    backup="${ALL_BACKUPS[$idx]}"
    source="${BACKUP_SOURCES[$idx]}"

    info=$(get_backup_info "$backup" "$source")

    # Colore per sorgente
    if [[ "$source" == "iCLOUD" ]]; then
        source_color="${BLUE}iCloud${NC}"
    else
        source_color="${GREEN}Local ${NC}"
    fi

    printf "  ${BOLD}%2d)${NC} %b   %s\n" "$i" "$source_color" "$info"
    ((i++))
done

echo ""
echo -e "  ${BOLD} 0)${NC} Annulla"
echo ""

# Chiedi selezione
while true; do
    read -p "Seleziona backup da ripristinare [0-${#ALL_BACKUPS[@]}]: " choice

    if [[ "$choice" =~ ^[0-9]+$ ]]; then
        if [ "$choice" -eq 0 ]; then
            echo "Operazione annullata."
            exit 0
        elif [ "$choice" -ge 1 ] && [ "$choice" -le ${#ALL_BACKUPS[@]} ]; then
            SELECTED_BACKUP="${ALL_BACKUPS[$((choice-1))]}"
            SELECTED_SOURCE="${BACKUP_SOURCES[$((choice-1))]}"
            break
        fi
    fi
    echo -e "${RED}Selezione non valida. Riprova.${NC}"
done

echo ""
BACKUP_NAME=$(basename "$SELECTED_BACKUP")
echo -e "${CYAN}Backup selezionato:${NC} $BACKUP_NAME"
echo -e "${CYAN}Sorgente:${NC} $SELECTED_SOURCE"

# Mostra dettagli backup
if [ -f "$SELECTED_BACKUP/manifest.json" ]; then
    echo ""
    echo -e "${CYAN}Dettagli:${NC}"
    python3 -c "
import json
with open('$SELECTED_BACKUP/manifest.json') as f:
    data = json.load(f)
    print(f\"  Data:     {data.get('backup_date', 'N/A')}\")
    print(f\"  Host:     {data.get('hostname', 'N/A')}\")
    print(f\"  User:     {data.get('user', 'N/A')}\")
    contents = data.get('contents', {})
    print(f\"  Profiles: {contents.get('profiles', 0)}\")
    print(f\"  Commands: {contents.get('commands', 0)}\")
    print(f\"  Hooks:    {contents.get('hooks', 0)}\")
    print(f\"  Settings: {'Si' if contents.get('settings') else 'No'}\")
    print(f\"  History:  {'Si' if contents.get('history') else 'No'}\")
" 2>/dev/null || true
fi

echo ""
echo -e "${YELLOW}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${YELLOW}║  ATTENZIONE: Questa operazione sovrascrivera' le             ║${NC}"
echo -e "${YELLOW}║  configurazioni attuali in ~/.claude                         ║${NC}"
echo -e "${YELLOW}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
read -p "Procedere con il restore? (s/N): " confirm
if [[ ! "$confirm" =~ ^[sS]$ ]]; then
    echo "Operazione annullata."
    exit 0
fi

echo ""
echo -e "${CYAN}Restore in corso...${NC}"

# Crea directory Claude se non esiste
mkdir -p "$CLAUDE_HOME"

# Restore profiles
if [ -d "$SELECTED_BACKUP/profiles" ]; then
    echo "  [1/5] Ripristinando profiles..."
    mkdir -p "$CLAUDE_HOME/profiles"
    rm -rf "$CLAUDE_HOME/profiles/"*
    cp -r "$SELECTED_BACKUP/profiles/"* "$CLAUDE_HOME/profiles/" 2>/dev/null || true
fi

# Restore commands
if [ -d "$SELECTED_BACKUP/commands" ]; then
    echo "  [2/5] Ripristinando commands..."
    mkdir -p "$CLAUDE_HOME/commands"
    rm -rf "$CLAUDE_HOME/commands/"*
    cp -r "$SELECTED_BACKUP/commands/"* "$CLAUDE_HOME/commands/" 2>/dev/null || true
fi

# Restore hooks
if [ -d "$SELECTED_BACKUP/hooks" ]; then
    echo "  [3/5] Ripristinando hooks..."
    mkdir -p "$CLAUDE_HOME/hooks"
    rm -rf "$CLAUDE_HOME/hooks/"*
    cp -r "$SELECTED_BACKUP/hooks/"* "$CLAUDE_HOME/hooks/" 2>/dev/null || true
    chmod +x "$CLAUDE_HOME/hooks/"*.sh 2>/dev/null || true
fi

# Restore settings
if [ -f "$SELECTED_BACKUP/settings.json" ]; then
    echo "  [4/5] Ripristinando settings.json..."
    cp "$SELECTED_BACKUP/settings.json" "$CLAUDE_HOME/"
fi

# Restore history (opzionale)
if [ -f "$SELECTED_BACKUP/history.jsonl" ]; then
    echo "  [5/5] Ripristinando history.jsonl..."
    cp "$SELECTED_BACKUP/history.jsonl" "$CLAUDE_HOME/"
fi

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                   RESTORE COMPLETATO!                        ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}Riepilogo configurazioni ripristinate:${NC}"
echo "  Profiles: $(ls -1 "$CLAUDE_HOME/profiles" 2>/dev/null | wc -l | tr -d ' ')"
echo "  Commands: $(ls -1 "$CLAUDE_HOME/commands" 2>/dev/null | wc -l | tr -d ' ')"
echo "  Hooks:    $(ls -1 "$CLAUDE_HOME/hooks" 2>/dev/null | wc -l | tr -d ' ')"
echo ""
echo -e "${YELLOW}Riavvia Claude Code per applicare le modifiche.${NC}"
