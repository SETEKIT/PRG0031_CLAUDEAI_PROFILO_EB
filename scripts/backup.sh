#!/bin/bash
# =============================================================================
# CLAUDE CODE - Backup Completo
# Autore: Eliseo Bosco
# Progetto: PRG0031_CLAUDEAI_PROFILO_EB
#
# Uso:
#   ./backup.sh              # Backup locale
#   ./backup.sh --icloud     # Backup locale + copia su iCloud Drive
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BACKUP_BASE="$PROJECT_DIR/backups"
CLAUDE_HOME="$HOME/.claude"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$BACKUP_BASE/backup-$TIMESTAMP"

# iCloud Drive path
ICLOUD_BACKUP_DIR="$HOME/Library/Mobile Documents/com~apple~CloudDocs/SETEK/backups-claude"

# Opzioni
SYNC_ICLOUD=false
if [[ "$1" == "--icloud" ]] || [[ "$1" == "-i" ]]; then
    SYNC_ICLOUD=true
fi

# Colori
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  CLAUDE CODE - Backup Completo        ${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Verifica esistenza config locale
if [ ! -d "$CLAUDE_HOME" ]; then
    echo -e "${RED}ERRORE: Directory ~/.claude non trovata${NC}"
    exit 1
fi

echo -e "${CYAN}Postazione:${NC} $(hostname)"
echo -e "${CYAN}Data:${NC} $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# Crea directory backup
mkdir -p "$BACKUP_DIR"

echo -e "${CYAN}Backup in corso...${NC}"
echo ""

# Backup profiles
if [ -d "$CLAUDE_HOME/profiles" ]; then
    echo "  [1/5] Backup profiles..."
    cp -r "$CLAUDE_HOME/profiles" "$BACKUP_DIR/"
fi

# Backup commands
if [ -d "$CLAUDE_HOME/commands" ]; then
    echo "  [2/5] Backup commands..."
    cp -r "$CLAUDE_HOME/commands" "$BACKUP_DIR/"
fi

# Backup hooks
if [ -d "$CLAUDE_HOME/hooks" ]; then
    echo "  [3/5] Backup hooks..."
    cp -r "$CLAUDE_HOME/hooks" "$BACKUP_DIR/"
fi

# Backup settings
if [ -f "$CLAUDE_HOME/settings.json" ]; then
    echo "  [4/5] Backup settings.json..."
    cp "$CLAUDE_HOME/settings.json" "$BACKUP_DIR/"
fi

# Backup history (opzionale)
if [ -f "$CLAUDE_HOME/history.jsonl" ]; then
    echo "  [5/5] Backup history.jsonl..."
    cp "$CLAUDE_HOME/history.jsonl" "$BACKUP_DIR/"
fi

# Crea manifest
cat > "$BACKUP_DIR/manifest.json" << EOF
{
    "backup_date": "$(date -Iseconds)",
    "hostname": "$(hostname)",
    "user": "$USER",
    "claude_home": "$CLAUDE_HOME",
    "contents": {
        "profiles": $([ -d "$BACKUP_DIR/profiles" ] && echo "$(ls -1 "$BACKUP_DIR/profiles" | wc -l | tr -d ' ')" || echo "0"),
        "commands": $([ -d "$BACKUP_DIR/commands" ] && echo "$(ls -1 "$BACKUP_DIR/commands" | wc -l | tr -d ' ')" || echo "0"),
        "hooks": $([ -d "$BACKUP_DIR/hooks" ] && echo "$(ls -1 "$BACKUP_DIR/hooks" | wc -l | tr -d ' ')" || echo "0"),
        "settings": $([ -f "$BACKUP_DIR/settings.json" ] && echo "true" || echo "false"),
        "history": $([ -f "$BACKUP_DIR/history.jsonl" ] && echo "true" || echo "false")
    }
}
EOF

echo ""
echo -e "${GREEN}Backup completato!${NC}"
echo ""
echo -e "${CYAN}Percorso:${NC} $BACKUP_DIR"
echo ""

# Statistiche
echo -e "${CYAN}Contenuto backup:${NC}"
du -sh "$BACKUP_DIR"/* 2>/dev/null | while read size path; do
    echo "  $size  $(basename "$path")"
done

# Dimensione totale
echo ""
TOTAL_SIZE=$(du -sh "$BACKUP_DIR" | cut -f1)
echo -e "${CYAN}Dimensione totale:${NC} $TOTAL_SIZE"

# Lista backup esistenti
echo ""
echo -e "${CYAN}Backup disponibili:${NC}"
ls -1d "$BACKUP_BASE"/backup-* 2>/dev/null | while read dir; do
    echo "  $(basename "$dir")"
done

# Suggerimento cleanup
BACKUP_COUNT=$(ls -1d "$BACKUP_BASE"/backup-* 2>/dev/null | wc -l | tr -d ' ')
if [ "$BACKUP_COUNT" -gt 5 ]; then
    echo ""
    echo -e "${YELLOW}Hai $BACKUP_COUNT backup. Considera di eliminare quelli vecchi.${NC}"
fi

# Sync su iCloud Drive
if [ "$SYNC_ICLOUD" = true ]; then
    echo ""
    echo -e "${CYAN}Sincronizzazione iCloud Drive...${NC}"

    # Crea directory iCloud se non esiste
    mkdir -p "$ICLOUD_BACKUP_DIR"

    # Copia backup su iCloud
    cp -r "$BACKUP_DIR" "$ICLOUD_BACKUP_DIR/"

    echo -e "${GREEN}Backup copiato su iCloud Drive!${NC}"
    echo -e "${CYAN}Percorso iCloud:${NC} $ICLOUD_BACKUP_DIR/backup-$TIMESTAMP"

    # Lista backup su iCloud
    echo ""
    echo -e "${CYAN}Backup su iCloud Drive:${NC}"
    ls -1d "$ICLOUD_BACKUP_DIR"/backup-* 2>/dev/null | while read dir; do
        echo "  $(basename "$dir")"
    done

    # Cleanup vecchi backup iCloud (mantieni ultimi 5)
    ICLOUD_COUNT=$(ls -1d "$ICLOUD_BACKUP_DIR"/backup-* 2>/dev/null | wc -l | tr -d ' ')
    if [ "$ICLOUD_COUNT" -gt 5 ]; then
        echo ""
        echo -e "${YELLOW}Pulizia backup iCloud vecchi (mantengo ultimi 5)...${NC}"
        ls -1dt "$ICLOUD_BACKUP_DIR"/backup-* | tail -n +6 | xargs rm -rf
        echo -e "${GREEN}Pulizia completata.${NC}"
    fi
else
    echo ""
    echo -e "${YELLOW}Tip: usa --icloud per sincronizzare anche su iCloud Drive${NC}"
fi
