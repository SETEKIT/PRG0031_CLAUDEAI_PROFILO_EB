---
description: Genera un report tecnico SETEK con tracking Google Sheets
argument-hint: <file.md> [nome-progetto]
allowed-tools: Read, Write, Bash, Edit
---

# Report Generator - SETEK General v1.0

Genera un report tecnico professionale: **$ARGUMENTS**

## Template e Script

- **Template:** `/Users/eliseobosco/AI-WORKSPACE/task/20251219-Sicurezza-AI/TEMPLATE_REPORT_STK_v1.0_GENERAL.md`
- **Script:** `/Users/eliseobosco/AI-WORKSPACE/task/20251219-Sicurezza-AI/report-stk-general_v1.0.sh`

## Istruzioni

1. **Leggi il file sorgente** (primo argomento) per analizzare il contenuto

2. **Genera i metadati automatici**:
   ```bash
   TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
   HOSTNAME=$(hostname)
   MD5=$(md5 -q <file.md>)
   ```

3. **Crea il report MD** compilando le sezioni del template:
   - Timestamp e Postazione: generati automaticamente
   - Contenuti: analisi del documento sorgente
   - Output: `REPORT_[NOME]_[DATA].md`

4. **Genera HTML** con tracker integrato:
   - 6 sezioni navigabili (Overview, Scores, Red Flags, Elementi Genuini, Detection, Fix)
   - Tracker URL per LogAccessReport
   - Output: `REPORT_[NOME]_[DATA].html`

5. **Apri il report** nel browser per test tracking

## Struttura Report (6 Sezioni)

1. **Overview** - Executive Summary con score cards
2. **Scores** - Valutazioni dettagliate
3. **Red Flags** - Criticita identificate
4. **Elementi Genuini** - Punti di forza
5. **Detection** - Breakdown analisi AI/Umano
6. **Fix Prioritari** - Azioni correttive

## Google Sheets Integration

- **Sheet:** AISETEK (`1h5m-csH8h_iFXG9ZqhVTje6PKa9hFTnOW0737Z2CZ80`)
- **Tab AI-Report:** Registrazione report generati
- **Tab LogAccessReport:** Tracking accessi HTML

### Tracker URL

```javascript
const TRACKER_URL = 'https://script.google.com/macros/s/AKfycbztgMY1ALhFsJAIbVcygPN8d4nosuL-jyMwcUSmGwDNfnkwaJ3cOm613-RGyiKW17o/exec';
```

## Esempio Uso

```
/report-stk-general-v1 documento.md
/report-stk-general-v1 documento.md "Nome Progetto"
```
