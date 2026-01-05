# Another yt-dlp wrapper

> **Lingue disponibili**: [English](README.md) | [Italiano (corrente)](README.it.md)

Uno script bash che utilizza yt-dlp per gestire flussi multimediali da vari siti, organizzando i contenuti in modo efficiente.

> **Nota**: Questo è semplicemente uno script wrapper che esegue i comandi del programma [yt-dlp](https://github.com/yt-dlp/yt-dlp). Questo script non aggiunge alcuna funzionalità di download oltre a quanto già fornito da yt-dlp, ma si concentra sull'organizzazione e l'automazione.

## Caratteristiche

Questo script offre le seguenti funzionalità:

1. **Download di Contenuti Multimediali**
   - Scarica singoli video, interi canali o playlist
   - Scarica automaticamente alla massima qualità disponibile
   - Preserva i titoli originali dei video come nomi dei file
   - Organizza i contenuti per tipo in cartelle separate (video, shorts, dirette)
   - Supporta il download dei sottotitoli sia manuali che generati automaticamente in diverse lingue
   - Scarica automaticamente le miniature (thumbnail) di tutti i video
   - Crea automaticamente file di descrizione con URL del video e descrizione completa
   - Salva i metadati completi in formato JSON per ogni video

2. **Modalità di Funzionamento Multiple**
   - Modalità interattiva con domande guidate e anteprima della configurazione
   - Modalità a riga di comando per scripting e automazione
   - Rilevamento intelligente degli URL per video, canali e playlist
   - Mostra il comando equivalente per facilitare la configurazione dell'automazione

3. **Gestione Efficiente**
   - Salta i video già esistenti per evitare duplicati (non sovrascrive mai i video già scaricati)
   - Crea automaticamente una struttura di directory organizzata
   - Riprende i download interrotti
   - Elaborazione batch con supporto per file di input
   - Sistema di logging completo per debug e tracciamento delle operazioni

4. **File di Informazioni Canale**
   - Crea automaticamente file `channel_info.txt` in ogni directory del canale
   - Registra i metadati del canale (nome, ID, descrizione, numero di follower)
   - Memorizza la configurazione di download e la cronologia con timestamp
   - Traccia tutte le sessioni di download per audit e riferimento

5. **Supporto Autenticazione**
   - Estrai automaticamente i cookie dal tuo browser (Chrome, Firefox, Edge, Safari, ecc.)
   - Usa file di cookie personalizzati per l'autenticazione
   - Accedi a video privati, contenuti riservati ai membri e video con restrizioni di età
   - Guida integrata per la configurazione e l'uso dei cookie
   - Script di export cookie per multiple distribuzioni (NixOS, Debian, Fedora, Arch)
   - Supporta sia installazioni browser standard che Flatpak

6. **Gestione Errori**
   - Gestione automatica dei limiti di velocità YouTube (errori 429)
   - Continua il download dei video anche se il download dei sottotitoli fallisce
   - Logging completo degli errori e reporting

## Requisiti

### Dipendenze Richieste

- `bash` - L'ambiente shell per eseguire lo script
- `yt-dlp` - L'utilità di base per il download dei video
- `date` - Per la generazione di timestamp
- `echo` - Per la visualizzazione dell'output
- `head` - Per limitare le righe di output
- `sed` - Per l'elaborazione di URL e testo
- `tr` - Per la trasformazione di caratteri
- `cut` - Per la manipolazione di stringhe
- `mkdir` - Per la creazione di directory
- `grep` - Per la ricerca di pattern nei file
- `tail` - Per estrarre le ultime righe dai file
- `xargs` - Per rimuovere spazi bianchi
- `dirname` - Per estrarre i percorsi delle directory
- `find` - Per localizzare file negli alberi delle directory

Tutte queste utilità sono tipicamente pre-installate sulla maggior parte delle distribuzioni Linux. L'unica dipendenza esterna che potresti dover installare manualmente è `yt-dlp`.

### Dipendenze Opzionali

- `jq` - Processore JSON per un parsing migliore dei metadati video (altamente raccomandato)
  - Se non installato, lo script userà `grep` e `sed` di base per il parsing JSON

## Installazione

1. Clona questo repository o scarica lo script:
   ```bash
   git clone https://github.com/palumbou/another_bucket_of_tools.git
   cd another_bucket_of_tools/another_yt-dlp_wrapper
   ```

2. Rendi eseguibile lo script:
   ```bash
   chmod +x another_yt-dlp_wrapper.sh
   ```

3. Installa le dipendenze se non sono già presenti:
   ```bash
   # Per yt-dlp (metodo consigliato)
   pip install -U yt-dlp
   
   # Metodi alternativi per yt-dlp:
   # Su Debian/Ubuntu
   sudo apt install yt-dlp
   
   # Su Fedora
   sudo dnf install yt-dlp
   
   # Su Arch Linux
   sudo pacman -Syu yt-dlp
   
   # Su Nix/NixOS
   nix-env -iA nixpkgs.yt-dlp
   
   # Su macOS con brew
   brew install yt-dlp
   ```

## Utilizzo

### Modalità Interattiva

Esegui semplicemente lo script senza argomenti per utilizzare la modalità interattiva:

```bash
./another_yt-dlp_wrapper.sh
```

Ti verrà chiesto di:
1. Scegliere il tipo di input (URL singolo o file di testo con più URL)
2. Inserire un URL multimediale o il percorso di un file di testo con URL (uno per riga)
3. Specificare una directory di output (o usare la directory corrente)
4. Scegliere le preferenze per i sottotitoli (manuali e/o generati automaticamente)
5. Selezionare quali tipi di contenuto scaricare (video, shorts, dirette)
6. Scegliere la modalità di velocità di download (normale, lenta o veloce) per limitare la velocità
7. Rivedere il riepilogo della configurazione con la riga di comando equivalente prima che inizi il download

La modalità interattiva fornisce assistenza guidata e ti mostra il comando non interattivo equivalente che potresti utilizzare per l'automazione o come riferimento futuro.

#### Opzioni di Velocità Download

Lo script offre quattro modalità di velocità di download per bilanciare le prestazioni con i limiti di velocità del servizio:

- **Modalità normale** (predefinita): velocità bilanciata con ritardi di 1-3 secondi tra le richieste
- **Modalità lenta**: più conservativa con ritardi di 5-10 secondi per evitare limiti di velocità (consigliata per download di grandi dimensioni)
- **Modalità molto lenta**: massima protezione con ritardi di 15-30 secondi (consigliata quando si verificano limitazioni di velocità)
- **Modalità veloce**: nessun ritardo tra le richieste (usare con cautela, potrebbe attivare limiti del servizio)

#### Riepilogo Configurazione

Prima di iniziare il download, la modalità interattiva visualizza:
- Tutte le opzioni selezionate
- I tipi di contenuto che verranno scaricati
- La modalità di velocità di download scelta
- **La riga di comando equivalente** che potresti utilizzare per ripetere questa operazione in modo non interattivo

### Modalità a Riga di Comando

Per utilizzo automatizzato o scripting:

```bash
./another_yt-dlp_wrapper.sh -n -u "https://example.com/watch?v=XXXX" -o ~/Video
```

### Opzioni Disponibili

```
Opzioni:
  -h, --help                Mostra questo messaggio di aiuto ed esci
  -o, --output-dir DIR      Imposta la directory di output (predefinita: directory corrente)
  -u, --url URL             URL multimediale (video, canale o playlist)
  -f, --file FILE           File di input con URL (uno per riga)
  -q, --quiet               Mostra meno output
  -s, --silent              Non mostrare output tranne gli errori
  -v, --verbose             Mostra output più dettagliato
  -n, --non-interactive     Esegui in modalità non interattiva (richiede --url o --file)
  --subs                    Scarica sottotitoli creati manualmente
  --auto-subs               Scarica sottotitoli generati automaticamente
  --sub-langs LANGS         Lingue dei sottotitoli da scaricare (separate da virgola, es. 'en,it')
                            Usa 'all' per tutte le lingue disponibili (predefinito)
  --log FILE                Salva tutto l'output in un file di log
  --no-videos               Salta i video regolari
  --no-shorts               Salta gli shorts
  --no-live                 Salta le dirette/registrazioni
  --only-videos             Scarica solo i video regolari
  --only-shorts             Scarica solo gli shorts
  --only-live               Scarica solo le dirette/registrazioni
  --slow                    Abilita la modalità di download lenta (ritardo 5-10 sec) per evitare limiti di velocità
  --very-slow               Abilita la modalità di download molto lenta (ritardo 15-30 sec) per massima protezione
  --fast                    Disabilita i ritardi di limitazione della velocità (potrebbe attivare limiti del servizio)
  --ignore-errors           Continua i download anche se si verificano errori (es. fallimenti sottotitoli)

Opzioni di autenticazione:
  --cookies-from-browser BROWSER
                            Estrai i cookie dal browser (chrome, firefox, edge, safari, ecc.)
  --cookies-file FILE       Usa i cookie da un file in formato Netscape
  --cookie-guide            Mostra una guida dettagliata per l'autenticazione con i cookie
  --export-cookies          Esporta i cookie dal tuo browser in un file (interattivo)

Nota: Le miniature e le descrizioni (con URL) vengono scaricate automaticamente per tutti i video.
```

### Struttura dei File Scaricati

Per ogni video scaricato, lo script crea i seguenti file:
- `titolo_video.mp4` - Il file video in formato MP4
- `titolo_video.jpg` (o `.webp`) - L'immagine miniatura del video
- `titolo_video.description.txt` - Un file di testo contenente l'URL del video e la descrizione completa
- `titolo_video.info.json` - Metadati completi in formato JSON (canale, uploader, durata, visualizzazioni, ecc.)
- `titolo_video.srt` - File dei sottotitoli (se `--subs` o `--auto-subs` è abilitato)

Esempio di contenuto di `titolo_video.description.txt`:
```
URL Video: https://example.com/watch?v=XXXXX

Descrizione:
----------------------------------------
Questa è la descrizione completa del video come appare sulla piattaforma.
Può contenere più righe, link, timestamp e altre informazioni.
```

### Autenticazione

Lo script supporta l'autenticazione tramite cookie, che ti permette di:
- Scaricare video privati o non elencati
- Accedere a contenuti riservati ai membri
- Bypassare restrizioni di età
- Scaricare video da canali a cui sei iscritto

**Modalità Interattiva**: Quando esegui lo script in modo interattivo, ti verrà chiesto se vuoi usare l'autenticazione e potrai scegliere tra:
1. Estrarre cookie direttamente dal browser (usa `--cookies-from-browser`)
2. Usare un file di cookie esistente
3. **Estrarre cookie e usarli automaticamente** (esporta in `./cookies.txt` e lo usa immediatamente)
4. Mostrare la guida dettagliata sui cookie

L'opzione 3 è la più comoda perché combina export e utilizzo in un solo passaggio!

#### Metodo 1: Estrarre Cookie dal Browser (Consigliato)

Il metodo più semplice è estrarre automaticamente i cookie dal tuo browser:

```bash
# Estrai cookie da Chrome
./another_yt-dlp_wrapper.sh -n -u "https://example.com/watch?v=XXXXX" --cookies-from-browser chrome

# Estrai cookie da Firefox
./another_yt-dlp_wrapper.sh -n -u "https://example.com/watch?v=XXXXX" --cookies-from-browser firefox
```

Browser supportati: `chrome`, `chromium`, `firefox`, `edge`, `safari`, `opera`, `brave`, `vivaldi`

**Requisiti**: Devi essere loggato sul sito web di destinazione nel browser specificato.

#### Metodo 2: Esportare Cookie in un File

Per un migliore controllo e compatibilità tra diverse distribuzioni Linux, usa lo script di export cookie incluso:

```bash
# Esporta i cookie in modo interattivo
./another_yt-dlp_wrapper.sh --export-cookies

# Oppure usa lo script di export direttamente
./another_yt-dlp_cookies_exporter.sh cookies.txt

# Per un browser o profilo specifico
BROWSER="firefox" ./another_yt-dlp_cookies_exporter.sh cookies.txt
CHROME_PROFILE="Profile 1" ./another_yt-dlp_cookies_exporter.sh cookies.txt
```

Lo script di export supporta:
- **Multiple distribuzioni**: NixOS, Debian, Fedora, Arch Linux
- **Multipli browser**: Chrome, Chromium, Firefox
- **Selezione profilo**: Esporta da profili browser specifici
- **Gestione automatica delle dipendenze**: Su NixOS, avvia automaticamente una nix-shell temporanea se le dipendenze mancano (non serve installazione permanente)

Poi usa il file esportato:
```bash
./another_yt-dlp_wrapper.sh -n -u "URL" --cookies-file cookies.txt
```

Per istruzioni dettagliate, vedi [COOKIES_EXPORTER_README.it.md](COOKIES_EXPORTER_README.it.md).

#### Metodo 3: Export Cookie Manuale (Alternativo)

In alternativa, puoi usare un'estensione del browser per esportare i cookie:

1. Installa un'estensione del browser per esportare i cookie:
   - **Chrome/Edge**: "Get cookies.txt LOCALLY" o "cookies.txt"
   - **Firefox**: "cookies.txt"

2. Effettua il login sul sito web nel tuo browser

3. Naviga sul sito web di destinazione ed esporta i cookie usando l'estensione

4. Salva il file (es. `cookies.txt`)

5. Usa il file dei cookie:
   ```bash
   ./another_yt-dlp_wrapper.sh -n -u "URL" --cookies-file ~/cookies.txt
   ```

**Nota sulla sicurezza**: Mantieni il tuo file dei cookie al sicuro perché contiene dati di autenticazione!

#### Ottenere Aiuto

Per una guida completa passo-passo sull'autenticazione con i cookie, esegui:
```bash
./another_yt-dlp_wrapper.sh --cookie-guide
```

### Pianificazione con Cron

Per download automatici pianificati usando cron, combina le opzioni `-n`, `-s` e `-o`:

```bash
# Esempio di voce cron per scaricare un canale quotidianamente alle 3 AM
0 3 * * * /percorso/a/another_yt-dlp_wrapper.sh -n -s -u "https://example.com/@NomeCanale" -o /percorso/a/video/
```

I flag usati per i cron job:
- `-n` (non interattivo): richiesto per eseguire senza input dell'utente
- `-s` (silenzioso): sopprime tutto l'output tranne gli errori, ideale per cron
- `-o` (directory di output): specifica dove salvare i video scaricati

## Esempi

Scarica un singolo video:
```bash
./another_yt-dlp_wrapper.sh -n -u "https://example.com/watch?v=XXXX"
```

Scarica tutti i video da un canale:
```bash
./another_yt-dlp_wrapper.sh -n -u "https://example.com/c/NomeCanale" -o ~/Video
```

Scarica una playlist:
```bash
./another_yt-dlp_wrapper.sh -n -u "https://example.com/playlist?list=XXXX"
```

Scarica video con sottotitoli creati manualmente:
```bash
./another_yt-dlp_wrapper.sh -n -u "https://example.com/watch?v=XXXX" --subs
```

Scarica video con sottotitoli generati automaticamente:
```bash
./another_yt-dlp_wrapper.sh -n -u "https://example.com/watch?v=XXXX" --auto-subs
```

Scarica video con entrambi i tipi di sottotitoli:
```bash
./another_yt-dlp_wrapper.sh -n -u "https://example.com/watch?v=XXXX" --subs --auto-subs
```

Scarica video con lingue di sottotitoli specifiche:
```bash
./another_yt-dlp_wrapper.sh -n -u "https://example.com/watch?v=XXXX" --subs --sub-langs en,it
```

Scarica solo video regolari (niente shorts o dirette):
```bash
./another_yt-dlp_wrapper.sh -n -u "https://example.com/c/NomeCanale" --only-videos
```

Scarica solo shorts:
```bash
./another_yt-dlp_wrapper.sh -n -u "https://example.com/c/NomeCanale" --only-shorts
```

Scarica video e dirette, ma salta gli shorts:
```bash
./another_yt-dlp_wrapper.sh -n -u "https://example.com/c/NomeCanale" --no-shorts
```

Scarica video da una lista di URL in un file:
```bash
./another_yt-dlp_wrapper.sh -n -f canali.txt
```

Abilita il logging completo in un file:
```bash
./another_yt-dlp_wrapper.sh -n -u "https://example.com/watch?v=XXXX" --log log-download.txt
```

## Caso d'uso: Archivio Multimediale Locale con Aggiornamenti Automatici

Puoi creare un archivio locale dei tuoi canali preferiti che rimane automaticamente aggiornato:

1. Prima, crea un download iniziale di tutti i tuoi canali/playlist preferiti:
   ```bash
   ./another_yt-dlp_wrapper.sh -n -f i_miei_canali_preferiti.txt -o ~/ArchivioMedia --subs --log ~/logs/media_iniziale.log
   ```

2. Configura un cron job per controllare periodicamente e scaricare nuovi video (questo esempio viene eseguito quotidianamente alle 2 AM):
   ```bash
   # Aggiungi questo al tuo crontab (esegui 'crontab -e' per modificare)
   0 2 * * * /percorso/a/another_yt-dlp_wrapper.sh -n -s -f /percorso/a/i_miei_canali_preferiti.txt -o /percorso/a/ArchivioMedia --log /percorso/a/logs/media_aggiornamento_$(date +\%Y\%m\%d).log
   ```

Questa configurazione:
- Scarica la cronologia completa dei tuoi canali preferiti inizialmente
- Controlla quotidianamente nuovi video e aggiunge solo quelli alla tua collezione
- Organizza tutto per tipo di contenuto (video, shorts e dirette in cartelle separate)
- Mantiene i log di ogni processo di aggiornamento
- Poiché yt-dlp salta i video già scaricati, solo i nuovi contenuti verranno aggiunti

### Organizzazione dei Contenuti

Lo script organizza tutti i contenuti scaricati per tipo:
- I video regolari vanno in `/nome_canale/videos/`
- Gli shorts vanno in `/nome_canale/shorts/`
- Le dirette e le registrazioni vanno in `/nome_canale/lives/`
- Le informazioni del canale sono memorizzate in `/nome_canale/channel_info.txt`

Ogni video è accompagnato da:
- La sua immagine miniatura (`.jpg` o `.webp`)
- Un file di descrizione (`.description.txt`) contenente l'URL del video e la descrizione completa
- Un file di metadati (`.info.json`) con informazioni complete sul video

Puoi personalizzare quali tipi di contenuto scaricare con le seguenti opzioni:
```bash
# Scarica solo video regolari
./another_yt-dlp_wrapper.sh -n -u "https://example.com/c/NomeCanale" --only-videos

# Scarica tutto tranne gli shorts
./another_yt-dlp_wrapper.sh -n -u "https://example.com/c/NomeCanale" --no-shorts
```

### File di Informazioni del Canale

Lo script crea automaticamente un file `channel_info.txt` in ogni directory del canale contenente:

- **Metadati del Canale**: Nome, ID, URL, descrizione e numero di follower
- **Configurazione del Download**: Quali tipi di contenuto sono stati scaricati, impostazioni dei sottotitoli, modalità di limitazione della velocità e il comando esatto utilizzato
- **Cronologia dei Download**: Timestamp di tutte le sessioni di download (formato: YYYY-MM-DD HH:MM:SS)

Esempio di contenuto di `channel_info.txt`:
```
=== INFORMAZIONI CANALE ===
Data Download: 2024-01-15 14:30:22
URL Originale: https://example.com/@NomeCanale

Nome Canale: Canale di Esempio
ID Canale: UC1234567890abcdef
URL Canale: https://example.com/@NomeCanale
Descrizione: Questa è una descrizione di esempio del canale...

=== CONFIGURAZIONE DOWNLOAD ===
Directory Output: /home/utente/video/Canale_di_Esempio
Scarica Video: true
Scarica Shorts: true
Scarica Live: true
Scarica Sottotitoli: Yes
Lingue Sottotitoli: all
Modalità Limitazione Velocità: normal
Comando Usato: ./another_yt-dlp_wrapper.sh -n -u "https://example.com/@NomeCanale" -o ~/Video --subs

=== CRONOLOGIA DOWNLOAD ===
Download Precedenti:
Ultimo Download: 2024-01-15 14:30:22
Ultimo Download: 2024-01-16 09:15:33
```

Queste informazioni sono preziose per:
- **Traccia di Audit**: Traccia quando sono avvenuti i download e cosa è stato configurato
- **Risoluzione Problemi**: Debug di problemi con configurazioni di download specifiche
- **Gestione Archivio**: Comprendere l'ambito e la cronologia della tua collezione multimediale
- **Automazione**: Riferimento alle impostazioni esatte utilizzate per download di successo

### Protezione Limitazione Velocità

Lo script include una protezione completa per la limitazione della velocità per evitare potenziali limiti del servizio e garantire download stabili. Sono disponibili quattro modalità:

- **Modalità normale** (predefinita): protezione bilanciata con ritardi di 1-3 secondi tra le richieste
  - `--sleep-interval 1` (ritardo di 1 secondo tra le richieste)
  - `--max-sleep-interval 3` (massimo 3 secondi se yt-dlp aumenta i ritardi)
  - `--retry-sleep 5` (5 secondi tra i tentativi di ripetizione)
  - `--retries 3` e `--fragment-retries 3`

- **Modalità lenta** (`--slow`): approccio conservativo con ritardi di 5-10 secondi, ideale per download batch di grandi dimensioni
  - `--sleep-interval 5` (ritardo di 5 secondi tra le richieste)
  - `--max-sleep-interval 10` (massimo 10 secondi)
  - `--retry-sleep 10` (10 secondi tra i tentativi di ripetizione)
  - `--retries 5` e `--fragment-retries 5`

- **Modalità molto lenta** (`--very-slow`): massima protezione con ritardi di 15-30 secondi, consigliata quando si verificano limitazioni di velocità
  - `--sleep-interval 15` (ritardo di 15 secondi tra le richieste)
  - `--max-sleep-interval 30` (massimo 30 secondi)
  - `--retry-sleep 20` (20 secondi tra i tentativi di ripetizione)
  - `--retries 10` e `--fragment-retries 10`

- **Modalità veloce** (`--fast`): ritardi minimi per download più veloci, usare con cautela per operazioni di grandi dimensioni
  - `--sleep-interval 0` (nessun ritardo tra le richieste)
  - Nessun ritardo di ripetizione (potrebbe attivare limiti di velocità del servizio)

Esempi:
```bash
# Usa la modalità lenta per download di canali di grandi dimensioni per essere più rispettosi del servizio
./another_yt-dlp_wrapper.sh -n -u "https://example.com/c/CanaleGrande" --slow

# Usa la modalità molto lenta quando si verificano problemi di limitazione di velocità
./another_yt-dlp_wrapper.sh -n -u "https://example.com/c/CanaleGrande" --very-slow

# Usa la modalità veloce per singoli video quando hai bisogno di velocità
./another_yt-dlp_wrapper.sh -n -u "https://example.com/watch?v=XXXX" --fast
```

**Raccomandazione**: usa la modalità normale predefinita per la maggior parte delle operazioni, passa a `--slow` per download batch di grandi dimensioni o a `--very-slow` se incontri limitazioni del servizio.

## Esempi Aggiuntivi

Questa sezione fornisce esempi completi che coprono vari casi d'uso, dal download di base a scenari avanzati come l'archiviazione completa di canali e la sincronizzazione.

### Download Completo di un Canale

Scarica un intero canale con tutti i tipi di contenuto e sottotitoli:
```bash
# Download completo del canale con sottotitoli e logging
./another_yt-dlp_wrapper.sh -n -u "https://example.com/c/NomeCanale" \
  -o ~/ArchivioMedia \
  --subs --auto-subs \
  --sub-langs en,it \
  --slow \
  --log ~/logs/download_canale.log
```

### Sincronizzazione Canale

Sincronizza una directory di canale esistente (scarica solo nuovi contenuti):
```bash
# Sincronizzazione quotidiana - scarica solo nuovi video dall'ultima esecuzione
./another_yt-dlp_wrapper.sh -n -u "https://example.com/c/NomeCanale" \
  -o ~/ArchivioMedia \
  --subs \
  --slow \
  --silent \
  --log ~/logs/sincronizzazione_$(date +%Y%m%d).log
```

### Uso di un File di Input

Puoi creare un file di testo con URL multimediali (uno per riga) per scaricare più video, canali o playlist in una singola operazione. Ad esempio:

```
# I miei canali preferiti (le righe che iniziano con # vengono ignorate)
https://example.com/c/Canale1
https://example.com/c/Canale2

# Playlist
https://example.com/playlist?list=XXXX
https://example.com/playlist?list=YYYY

# Video individuali
https://example.com/watch?v=VIDEO1
https://example.com/watch?v=VIDEO2
```

Poi scarica tutti con:
```bash
./another_yt-dlp_wrapper.sh -n -f i_miei_canali.txt -o ~/Video --subs
```

### Esempio Completo con Tutte le Funzionalità

Scarica da una lista di URL con autenticazione, lingue specifiche dei sottotitoli e massima protezione dai limiti di velocità:
```bash
# Prima, esporta i cookie da Chrome
./another_yt-dlp_cookies_exporter.sh cookies.txt

# Poi scarica con tutti i tipi di contenuto, sottotitoli manuali e automatici in più lingue, usando la modalità molto lenta
./another_yt-dlp_wrapper.sh -n \
  -f ./list_video.txt \
  --cookies-file ./cookies.txt \
  --subs --auto-subs \
  --sub-langs en,it,de \
  --very-slow \
  -o .
```

Questo esempio:
- Legge gli URL da `list_video.txt` nella directory corrente
- Usa l'autenticazione tramite cookie esportati da Chrome
- Scarica tutti i tipi di contenuto (video, shorts, dirette)
- Scarica sia sottotitoli manuali che generati automaticamente in inglese, italiano e tedesco
- Usa la modalità molto lenta (ritardi 15-30 sec) per massima protezione contro i limiti di velocità
- Salva tutto nella directory corrente

## Problemi Noti

### HTTP Error 429: Too Many Requests

YouTube occasionalmente restituisce un errore "429 Too Many Requests" quando si scaricano i sottotitoli. Questo script gestisce automaticamente questo problema:

1. **Workaround automatico**: Lo script usa `--extractor-args "youtube:player_client=android,web"` per evitare la limitazione della velocità (solo quando NON si usa l'autenticazione con cookie, in quanto sono incompatibili)
2. **Ignorare errori**: Usa il flag `--ignore-errors` per continuare a scaricare i video anche se il download dei sottotitoli fallisce
3. **Modalità lenta**: Usa il flag `--slow` per aggiungere ritardi tra i download e ridurre ulteriormente il rischio di limitazione della velocità

**Soluzione da**: [yt-dlp issue #13831](https://github.com/yt-dlp/yt-dlp/issues/13831)

Se incontri ancora limitazioni di velocità:
- Usa la modalità di download `--slow`
- Scarica senza sottotitoli (non usare `--subs` o `--auto-subs`)
- Aspetta un po' di tempo prima di riprovare
- Considera l'uso dell'autenticazione con i cookie

## Licenza

Questo progetto è concesso in licenza sotto Creative Commons Attribution-NonCommercial 4.0 International License - vedi il file [LICENSE](../LICENSE) nella directory principale per i dettagli.

## Ringraziamenti

- Questo script usa [yt-dlp](https://github.com/yt-dlp/yt-dlp), un'eccellente utilità per il download di media.

---

Questo script fa parte della collezione [another_bucket_of_tools](https://github.com/palumbou/another_bucket_of_tools).
