---
description: Aggiungi un link utile al Google Sheet Link-Utili-SETEK
allowed-tools: Bash, Read
---

# Aggiungi Link Utile

Aggiungi un nuovo link al foglio Google "Link-Utili-SETEK-Eliseo-Bosco".

## Informazioni Foglio

- **Spreadsheet ID**: 1dDOIfVo2ETk6Rfb92EN2cPnEoi0PfGUQT2VfVwHsptg
- **Foglio**: ToDoList
- **Colonne**: Categoria | Link | Descrizione | Note

## Categorie Esistenti

| Categoria | Descrizione |
|-----------|-------------|
| AI | Intelligenza Artificiale |
| SICUREZZA | Security, attacchi, protezione |
| ECOMMERCE | Magento, Prestashop, vendite online |
| GOOGLE.PRIVACY | Privacy e impostazioni Google |
| BACKUP | Backup e disaster recovery |
| BACKUP.EXEC | Symantec Backup Exec |
| WINDOWS SERVER | Windows Server, Exchange |
| NETWORK.MONITORING | Monitoring rete (Zabbix, OpenNMS) |
| PROXMOX | Virtualizzazione Proxmox |
| VMWARE | VMware |
| AWS | Amazon Web Services |
| CISCO | Cisco networking |
| SOPHOS | Sophos UTM/XG |
| MAC | macOS |
| WEB | Sviluppo web |
| HELP DESK | Supporto tecnico |
| MODELLI GOOGLE | Google Apps Script |

## Istruzioni

1. Chiedi all'utente i dati del link (se non forniti):
   - **Categoria**: una delle esistenti o nuova
   - **Link**: URL completo
   - **Descrizione**: breve descrizione
   - **Note**: (opzionale) chi l'ha suggerito, contesto, etc.

2. Conferma i dati con l'utente prima di inserire

3. Esegui lo script per aggiungere il link:
   ```bash
   python3 ~/.claude/scripts/add-link-utile.py "CATEGORIA" "URL" "Descrizione" "Note"
   ```

4. Conferma l'inserimento mostrando:
   - Riga inserita
   - Link al foglio: https://docs.google.com/spreadsheets/d/1dDOIfVo2ETk6Rfb92EN2cPnEoi0PfGUQT2VfVwHsptg/

## Requisiti

- Credenziali Google configurate con scope spreadsheets
- Se errore 403, eseguire:
  ```bash
  gcloud auth application-default login --scopes="https://www.googleapis.com/auth/cloud-platform,https://www.googleapis.com/auth/spreadsheets"
  ```
