#!/bin/bash
# =============================================================================
# CLAUDE CODE - Setup Credenziali
# Autore: Eliseo Bosco
# Progetto: PRG0031_CLAUDEAI_PROFILO_EB
#
# DESCRIZIONE:
# Script interattivo per configurare le credenziali in modo sicuro.
# Le credenziali vengono salvate ESTERNAMENTE alla directory del progetto.
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CREDENTIALS_DIR="$HOME/.config/setek"
CREDENTIALS_FILE="$CREDENTIALS_DIR/prg0031-credentials.json"
TEMPLATE_FILE="$PROJECT_DIR/credentials.example.json"

# Colori
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  CLAUDE CODE - Setup Credenziali      ${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

echo -e "${CYAN}Percorso credenziali:${NC} $CREDENTIALS_FILE"
echo -e "${YELLOW}NOTA: Questo file e' ESTERNO al progetto per sicurezza${NC}"
echo ""

# Verifica se esiste gia'
if [ -f "$CREDENTIALS_FILE" ]; then
    echo -e "${YELLOW}File credenziali esistente trovato.${NC}"
    echo ""
    echo "Opzioni:"
    echo "  1) Visualizza status credenziali"
    echo "  2) Modifica file esistente"
    echo "  3) Ricrea da template (sovrascrive)"
    echo "  4) Esci"
    echo ""
    read -p "Scelta [1-4]: " choice

    case $choice in
        1)
            source "$SCRIPT_DIR/lib/credentials-loader.sh"
            show_credentials_status
            exit 0
            ;;
        2)
            echo ""
            echo "Apertura editor..."
            ${EDITOR:-nano} "$CREDENTIALS_FILE"
            echo -e "${GREEN}File modificato.${NC}"
            exit 0
            ;;
        3)
            echo ""
            read -p "Sei sicuro di voler sovrascrivere? (s/N): " confirm
            if [[ ! "$confirm" =~ ^[sS]$ ]]; then
                echo "Operazione annullata."
                exit 0
            fi
            ;;
        *)
            echo "Operazione annullata."
            exit 0
            ;;
    esac
fi

# Crea directory se non esiste
echo ""
echo -e "${CYAN}Creazione directory...${NC}"
mkdir -p "$CREDENTIALS_DIR"
chmod 700 "$CREDENTIALS_DIR"

# Copia template
echo -e "${CYAN}Copia template...${NC}"
cp "$TEMPLATE_FILE" "$CREDENTIALS_FILE"
chmod 600 "$CREDENTIALS_FILE"

echo ""
echo -e "${GREEN}File credenziali creato!${NC}"
echo ""
echo -e "${CYAN}Percorso:${NC} $CREDENTIALS_FILE"
echo -e "${CYAN}Permessi:${NC} 600 (solo proprietario)"
echo ""

# Chiedi se modificare ora
read -p "Vuoi configurare le credenziali ora? (S/n): " edit_now
if [[ ! "$edit_now" =~ ^[nN]$ ]]; then
    echo ""
    echo -e "${YELLOW}Apertura editor...${NC}"
    echo "Sostituisci i valori XXXXXX con le tue credenziali reali."
    echo ""
    sleep 2
    ${EDITOR:-nano} "$CREDENTIALS_FILE"
fi

echo ""
echo -e "${GREEN}Setup completato!${NC}"
echo ""
echo -e "${CYAN}Prossimi passi:${NC}"
echo "  1. Modifica le credenziali: nano $CREDENTIALS_FILE"
echo "  2. Verifica status:         ./scripts/setup-credentials.sh (opzione 1)"
echo ""
echo -e "${YELLOW}IMPORTANTE:${NC}"
echo "  - Il file credenziali e' ESTERNO al progetto"
echo "  - NON verra' mai pushato su git"
echo "  - Copia manualmente su altre postazioni se necessario"
echo ""
