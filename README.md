# PRG0031 - Claude Code Config Sync

Sincronizzazione configurazioni Claude Code tra postazioni Mac.

## Sicurezza Credenziali

**IMPORTANTE**: Le credenziali sono gestite in modo sicuro **ESTERNAMENTE** al progetto.

- Le credenziali reali sono in: `~/.config/setek/prg0031-credentials.json`
- Questo file **NON** viene pushato su git
- Deve essere copiato **manualmente** su ogni nuova postazione

Vedi sezione [Gestione Credenziali](#gestione-credenziali) per dettagli.

## Struttura

```
PRG0031_CLAUDEAI_PROFILO_EB/
├── credentials.example.json    # Template credenziali (SOLO ESEMPIO)
├── claude-config/              # Configurazioni sincronizzate
│   ├── profiles/              # Profili sicurezza (PRF01-PRF08)
│   ├── commands/              # Slash commands
│   ├── hooks/                 # Scripts hook
│   └── settings.json          # Impostazioni Claude
├── scripts/
│   ├── lib/
│   │   └── credentials-loader.sh  # Libreria caricamento credenziali
│   ├── setup-credentials.sh   # Setup interattivo credenziali
│   ├── install.sh             # Setup nuovo Mac
│   ├── sync-push.sh           # Local → Repository
│   ├── sync-pull.sh           # Repository → Local
│   ├── backup.sh              # Backup completo
│   ├── restore.sh             # Restore con menu selezione
│   └── export-chats.py        # Export chat in Markdown
├── Addestramento_con_Documenti_di_Progetto/
│   ├── templates/             # Template profili vuoti
│   ├── esempi/                # Profili esempio (PRF999)
│   ├── scripts/               # Script creazione profili
│   └── README.md              # Guida addestramento
├── backups/                   # Backup locali (gitignored)
└── README.md
```

## Quick Start

### Setup Nuovo Mac

```bash
# 1. Clona il repository
cd ~
git clone https://github.com/SETEKIT/PRG0031_CLAUDEAI_PROFILO_EB.git

# 2. Configura credenziali (file ESTERNO al progetto)
cd PRG0031_CLAUDEAI_PROFILO_EB
./scripts/setup-credentials.sh
# OPPURE copia manualmente:
# cp /path/to/backup/prg0031-credentials.json ~/.config/setek/

# 3. Installa configurazioni
./scripts/install.sh

# 4. Riavvia Claude Code
```

### Sincronizzazione Giornaliera

**Dal Mac principale (dopo modifiche):**
```bash
cd ~/PRG0031_CLAUDEAI_PROFILO_EB
./scripts/sync-push.sh
git add -A && git commit -m "sync: $(date '+%Y-%m-%d')" && git push
```

**Su altri Mac:**
```bash
cd ~/PRG0031_CLAUDEAI_PROFILO_EB
git pull
./scripts/sync-pull.sh
```

## Scripts

| Script | Descrizione |
|--------|-------------|
| `setup-credentials.sh` | Setup interattivo credenziali esterne |
| `install.sh` | Prima installazione su nuovo Mac |
| `sync-push.sh` | Copia config locali → repository |
| `sync-pull.sh` | Copia config repository → locali |
| `backup.sh` | Crea backup completo (usa `--icloud` per sync su iCloud Drive) |
| `restore.sh` | Restore con menu (locale + iCloud, usa `--local` o `--icloud`) |
| `export-chats.py` | Esporta chat in formato Markdown |
| `lib/credentials-loader.sh` | Libreria per caricare credenziali |

## Profili Disponibili

| Codice | Nome | Uso |
|--------|------|-----|
| PRF01 | Penetration Testing | Test di sicurezza autorizzati |
| PRF02 | Red Team | Simulazione attacchi |
| PRF03 | Threat Intelligence | Analisi minacce |
| PRF04 | Incident Response | Gestione incidenti |
| PRF05 | Blue Team | Difesa e monitoraggio |
| PRF06 | Compliance Audit | Audit conformità |
| PRF07 | Secure Development | Sviluppo sicuro |
| PRF08 | General | Uso generale |

## Slash Commands

### Comandi Base

| Comando | Descrizione |
|---------|-------------|
| `/profili` | Lista profili disponibili |
| `/profilo PRF01` | Carica profilo specifico |
| `/security-check` | Quick security check |
| `/piano` | Analisi convenienza piano Claude |
| `/stats` | Statistiche utilizzo Claude AI |
| `/stk-link-utili-add` | Aggiungi link a Google Sheet SETEK |

### Report Generator

| Comando | Descrizione |
|---------|-------------|
| `/report-stk-general-v1` | Genera report tecnico SETEK con tracking Google Sheets |

**Uso:**
```bash
/report-stk-general-v1 documento.md
/report-stk-general-v1 documento.md "Nome Progetto"
```

**Funzionalità:**
- Genera report MD + HTML con 6 sezioni navigabili
- Tracking accessi via Google Sheets (AISETEK)
- Sezioni: Overview, Scores, Red Flags, Elementi Genuini, Detection, Fix Prioritari
- Output: `REPORT_[NOME]_[DATA].md` e `.html`

## Configurazioni Sincronizzate

- `~/.claude/profiles/` - Profili di sicurezza
- `~/.claude/commands/` - Comandi slash personalizzati
- `~/.claude/hooks/` - Hook di automazione
- `~/.claude/settings.json` - Impostazioni

## Export Chat

```bash
# Lista sessioni disponibili
./scripts/export-chats.py --list

# Esporta tutte le sessioni
./scripts/export-chats.py --all -o ./exports

# Esporta sessione specifica
./scripts/export-chats.py --session <session-id>
```

## Creare Profili Personalizzati

Puoi creare profili custom addestrati con i documenti dei tuoi progetti.

### Quick Start Addestramento

```bash
cd Addestramento_con_Documenti_di_Progetto

# 1. Crea nuovo profilo con wizard
./scripts/crea-profilo.sh

# 2. Importa documenti dal progetto
./scripts/importa-documenti.sh PRF100 /path/to/progetto/docs --standards

# 3. Valida il profilo
./scripts/valida-profilo.sh esempi/PRF100-mio-profilo.md

# 4. Installa
cp esempi/PRF100-mio-profilo.md ~/.claude/profiles/
```

### Script Addestramento

| Script | Descrizione |
|--------|-------------|
| `crea-profilo.sh` | Wizard interattivo creazione profilo |
| `importa-documenti.sh` | Importa docs di progetto nel profilo |
| `valida-profilo.sh` | Verifica correttezza profilo |

### Profilo Esempio

Vedi `Addestramento_con_Documenti_di_Progetto/esempi/PRF999-addestramento-esempio.md` per un esempio completo di profilo addestrato con documenti di progetto.

## Gestione Credenziali

Le credenziali sensibili (API keys, token, password) sono gestite **esternamente** al progetto per sicurezza.

### Percorso File Credenziali

```
~/.config/setek/prg0031-credentials.json   # File reale (NON in git)
./credentials.example.json                  # Template esempio (in git)
```

### Prima Configurazione

```bash
# 1. Esegui lo script di setup
./scripts/setup-credentials.sh

# 2. Modifica le credenziali
nano ~/.config/setek/prg0031-credentials.json

# 3. Verifica la configurazione
./scripts/setup-credentials.sh   # Opzione 1
```

### Usare Credenziali negli Script

```bash
# Nel tuo script, includi il loader
source scripts/lib/credentials-loader.sh

# Carica tutte le credenziali come variabili ambiente
load_credentials

# Usa le variabili
echo $ANTHROPIC_API_KEY
echo $GITHUB_TOKEN

# Oppure leggi una singola credenziale
API_KEY=$(get_credential "anthropic.api_key")

# Verifica che una credenziale sia configurata
require_credential "anthropic.api_key" "Anthropic API Key" || exit 1
```

### Struttura File Credenziali

```json
{
  "anthropic": {
    "api_key": "sk-ant-api03-..."
  },
  "github": {
    "token": "ghp_...",
    "username": "your-username"
  },
  "google_sheets": {
    "credentials_file": "/path/to/service-account.json",
    "spreadsheet_id": "..."
  },
  "database": {
    "host": "localhost",
    "port": 5432,
    "username": "...",
    "password": "..."
  }
}
```

### Sicurezza

- Il file credenziali ha permessi `600` (solo proprietario)
- La directory `~/.config/setek/` ha permessi `700`
- Il file **NON** viene mai pushato su git
- Su nuove postazioni, copiare manualmente il file credenziali

## Note

- Dopo sync-pull, riavviare Claude Code per applicare le modifiche
- I backup vengono salvati in `backups/` con timestamp
- Il file `.sync-metadata.json` traccia l'ultimo push
- Profili max ~4000 parole per migliori performance
- **Credenziali**: sempre esterne in `~/.config/setek/`

---
Autore: Eliseo Bosco
