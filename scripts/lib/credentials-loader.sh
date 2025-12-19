#!/bin/bash
# =============================================================================
# CLAUDE CODE - Credentials Loader Library
# Autore: Eliseo Bosco
# Progetto: PRG0031_CLAUDEAI_PROFILO_EB
#
# DESCRIZIONE:
# Questo script fornisce funzioni per caricare credenziali da un file JSON
# esterno alla directory del progetto per motivi di sicurezza.
#
# PERCORSO CREDENZIALI:
# ~/.config/setek/prg0031-credentials.json
#
# UTILIZZO:
#   source scripts/lib/credentials-loader.sh
#   load_credentials
#   echo $ANTHROPIC_API_KEY
# =============================================================================

# Percorso del file credenziali (ESTERNO al progetto)
CREDENTIALS_FILE="${CREDENTIALS_FILE:-$HOME/.config/setek/prg0031-credentials.json}"

# Colori per output
_CRED_RED='\033[0;31m'
_CRED_GREEN='\033[0;32m'
_CRED_YELLOW='\033[1;33m'
_CRED_NC='\033[0m'

# Verifica se python3 e' disponibile
_check_python() {
    if ! command -v python3 &> /dev/null; then
        echo -e "${_CRED_RED}ERRORE: python3 non trovato. Necessario per parsare JSON.${_CRED_NC}"
        return 1
    fi
    return 0
}

# Verifica se il file credenziali esiste
check_credentials_file() {
    if [ ! -f "$CREDENTIALS_FILE" ]; then
        echo -e "${_CRED_YELLOW}ATTENZIONE: File credenziali non trovato.${_CRED_NC}"
        echo ""
        echo "Per configurare le credenziali:"
        echo "  1. Crea la directory: mkdir -p ~/.config/setek"
        echo "  2. Copia il template:  cp credentials.example.json ~/.config/setek/prg0031-credentials.json"
        echo "  3. Modifica con le tue credenziali: nano ~/.config/setek/prg0031-credentials.json"
        echo ""
        return 1
    fi
    return 0
}

# Carica una singola credenziale dal file JSON
# Uso: get_credential "anthropic.api_key"
get_credential() {
    local key_path="$1"
    local default_value="${2:-}"

    if [ ! -f "$CREDENTIALS_FILE" ]; then
        echo "$default_value"
        return 1
    fi

    _check_python || return 1

    python3 << PYTHON_EOF
import json
import sys

try:
    with open("$CREDENTIALS_FILE") as f:
        data = json.load(f)

    keys = "$key_path".split(".")
    value = data
    for key in keys:
        value = value.get(key)
        if value is None:
            print("$default_value")
            sys.exit(0)

    print(value if value else "$default_value")
except Exception as e:
    print("$default_value")
    sys.exit(1)
PYTHON_EOF
}

# Carica tutte le credenziali come variabili d'ambiente
load_credentials() {
    if ! check_credentials_file; then
        return 1
    fi

    _check_python || return 1

    # Carica credenziali Anthropic
    export ANTHROPIC_API_KEY=$(get_credential "anthropic.api_key")

    # Carica credenziali GitHub
    export GITHUB_TOKEN=$(get_credential "github.token")
    export GITHUB_USERNAME=$(get_credential "github.username")

    # Carica credenziali Google Sheets
    export GOOGLE_CREDENTIALS_FILE=$(get_credential "google_sheets.credentials_file")
    export GOOGLE_SPREADSHEET_ID=$(get_credential "google_sheets.spreadsheet_id")

    # Carica credenziali database
    export DB_HOST=$(get_credential "database.host" "localhost")
    export DB_PORT=$(get_credential "database.port" "5432")
    export DB_USERNAME=$(get_credential "database.username")
    export DB_PASSWORD=$(get_credential "database.password")
    export DB_DATABASE=$(get_credential "database.database")

    echo -e "${_CRED_GREEN}Credenziali caricate da: $CREDENTIALS_FILE${_CRED_NC}"
    return 0
}

# Verifica che una credenziale sia configurata
require_credential() {
    local key_path="$1"
    local friendly_name="${2:-$key_path}"

    local value=$(get_credential "$key_path")

    if [ -z "$value" ] || [[ "$value" == *"XXXXXX"* ]] || [[ "$value" == *"your-"* ]]; then
        echo -e "${_CRED_RED}ERRORE: Credenziale '$friendly_name' non configurata.${_CRED_NC}"
        echo "Modifica il file: $CREDENTIALS_FILE"
        echo "Imposta il valore per: $key_path"
        return 1
    fi
    return 0
}

# Mostra status credenziali (senza mostrare i valori)
show_credentials_status() {
    echo ""
    echo "Status credenziali ($CREDENTIALS_FILE):"
    echo "=========================================="

    if [ ! -f "$CREDENTIALS_FILE" ]; then
        echo -e "${_CRED_RED}File non trovato${_CRED_NC}"
        return 1
    fi

    python3 << 'PYTHON_EOF'
import json
import os

cred_file = os.path.expanduser("~/.config/setek/prg0031-credentials.json")
try:
    with open(cred_file) as f:
        data = json.load(f)

    def check_value(v):
        if not v or v == "":
            return "  NON CONFIGURATO"
        if "XXXXXX" in str(v) or "your-" in str(v):
            return "  DA CONFIGURARE"
        return "  OK"

    checks = [
        ("Anthropic API Key", data.get("anthropic", {}).get("api_key")),
        ("GitHub Token", data.get("github", {}).get("token")),
        ("Google Credentials", data.get("google_sheets", {}).get("credentials_file")),
        ("Database Password", data.get("database", {}).get("password")),
    ]

    for name, value in checks:
        status = check_value(value)
        color = "\033[0;32m" if "OK" in status else "\033[1;33m"
        reset = "\033[0m"
        print(f"  {name}: {color}{status}{reset}")

except Exception as e:
    print(f"  Errore lettura: {e}")
PYTHON_EOF
    echo ""
}
