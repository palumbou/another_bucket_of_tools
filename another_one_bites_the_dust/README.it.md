# Another One Bites the Dust

> **Lingue disponibili**: [English](README.md) | [Italiano (corrente)](README.it.md)

Un'utility completa per la pulizia del sistema che identifica e rimuove automaticamente file vecchi e non necessari per liberare spazio su disco.

> **⚠️ ATTENZIONE**: Questo script elimina permanentemente file dal tuo sistema. Esegui sempre prima in modalità dry-run per esaminare cosa verrà eliminato. Gli autori non sono responsabili per eventuali perdite di dati che potrebbero verificarsi utilizzando questo strumento. Usalo a tuo rischio e pericolo.

> **⚠️ NOTA**: Sono necessari privilegi di amministratore (sudo) per pulire le cache dei gestori di pacchetti. Quando si puliscono directory di sistema come /var/cache o le cache dei gestori di pacchetti, eseguire lo script con sudo.

## Caratteristiche

- **Pulizia multi-target**: scansiona e pulisce varie directory di sistema inclusi cache, log, file temporanei, cestino e cache dei gestori di pacchetti
- **Rimozione intelligente dei backup**: identifica e rimuove vecchi file di backup in base a soglie di età configurabili
- **Modalità di prova**: anteprima di ciò che verrebbe eliminato prima di apportare modifiche
- **Modalità interattiva**: conferma ogni operazione di pulizia prima dell'esecuzione
- **Registrazione dettagliata**: tutte le operazioni vengono registrate per verifica e riferimento
- **Supporto per gestori di pacchetti**: pulizia specializzata per i gestori di pacchetti APT, DNF, Pacman e Nix
- **Pulizia cache browser**: supporto per la pulizia della cache dei browser Firefox e Chrome
- **Pulizia Docker**: rimuove container, immagini, reti e volumi Docker inutilizzati per recuperare spazio su disco
- **Soglie di età configurabili**: imposta diverse soglie di età per ogni tipo di file
- **Sorprese nascoste**: contiene un Easter egg nascosto per le menti curiose. Riuscirai a trovarlo?

## Installazione

1. Clona questo repository:
   ```bash
   git clone https://github.com/palumbou/another_bucket_of_tools.git
   ```

2. Rendi lo script eseguibile:
   ```bash
   chmod u+x another_bucket_of_tools/another_one_bites_the_dust/another_one_bites_the_dust.sh
   ```

3. Esegui lo script:
   ```bash
   cd another_bucket_of_tools/another_one_bites_the_dust
   ./another_one_bites_the_dust.sh
   ```

## Utilizzo

```bash
./another_one_bites_the_dust.sh [opzioni]
```

### Opzioni

- `-d, --dry-run`: mostra cosa verrebbe eliminato senza effettivamente eliminare nulla
- `-v, --verbose`: mostra informazioni dettagliate durante l'esecuzione
- `-n, --non-interactive`: esegui senza chiedere conferma (usa con cautela)
- `-t, --target DIR`: imposta la directory di destinazione (predefinita: $HOME)
- `-l, --log FILE`: imposta la posizione del file di log
- `-h, --help`: visualizza il messaggio di aiuto ed esci

### Esempi

```bash
# Prova con output dettagliato
./another_one_bites_the_dust.sh --dry-run --verbose

# Pulisci una directory specifica in modo non interattivo
./another_one_bites_the_dust.sh --target /home/username --non-interactive

# Mostra informazioni di aiuto
./another_one_bites_the_dust.sh --help
```

## Configurazione

Lo script legge la configurazione da `env.conf` nella stessa directory. Puoi modificare questo file per personalizzare:

- Soglie di età per diversi tipi di file
- Directory aggiuntive da pulire
- Modelli di file da escludere

Esempio di configurazione:

```bash
# Età in giorni per diversi tipi di file
CACHE_AGE=30
LOG_AGE=30
TEMP_AGE=7
TRASH_AGE=30
BACKUP_AGE=90

# Directory aggiuntive da pulire (separate da spazi)
# Formato: percorso:età_in_giorni
ADDITIONAL_DIRS="/home/user/progetti/temp:14 /var/tmp/builds:7"

# Modelli di file da escludere (separati da spazi)
EXCLUDE_PATTERNS=".mozilla .config/google-chrome"
```

## Licenza

Questo progetto è rilasciato sotto la licenza Creative Commons Attribution-NonCommercial 4.0 International - vedi il file [LICENSE](../LICENSE) nella directory principale per i dettagli.

---

Questo script fa parte della collezione [another_bucket_of_tools](https://github.com/palumbou/another_bucket_of_tools).