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

4. **File di Informazioni del Canale**
   - Crea automaticamente file `channel_info.txt` in ogni directory del canale
   - Registra i metadati del canale (nome, ID, descrizione, numero di follower)
   - Traccia la configurazione del download e la cronologia con timestamp
   - Mantiene traccia di tutte le sessioni di download per audit e riferimento

5. **Supporto Autenticazione**
   - Estrai automaticamente i cookie dal tuo browser (Chrome, Firefox, Edge, Safari, ecc.)
   - Usa file di cookie personalizzati per l'autenticazione
   - Accedi a video privati, contenuti riservati ai membri e video con restrizioni di età
   - Guida integrata per la configurazione e l'uso dei cookie

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
2. Inserire un URL multimediale (video, canale o playlist) oppure il percorso di un file di testo
3. Specificare una directory di output (o utilizzare la directory corrente)
4. Scegliere le preferenze per i sottotitoli (manuali e/o generati automaticamente)
5. Selezionare quali tipi di contenuto scaricare (video, shorts, dirette)
6. Scegliere la modalità di velocità di download (normale, lenta o veloce) per il rate limiting
7. Rivedere il riepilogo della configurazione con il comando equivalente prima che inizi il download

La modalità interattiva fornisce assistenza guidata e ti mostra il comando non-interattivo equivalente che potresti utilizzare per l'automazione o come riferimento futuro.

#### Opzioni di Velocità Download

Lo script offre tre modalità di velocità di download per bilanciare prestazioni e limiti di rate del servizio:

- **Modalità normale** (predefinita): Velocità bilanciata con ritardi di 1-3 secondi tra le richieste
- **Modalità lenta**: Più conservativa con ritardi di 5-10 secondi per evitare limiti di rate (raccomandato per download di grandi dimensioni)
- **Modalità veloce**: Nessun ritardo tra le richieste (usa con cautela, può attivare i limiti del servizio)

#### Riepilogo della Configurazione

Prima di iniziare il download, la modalità interattiva mostra:
- Tutte le opzioni selezionate
- I tipi di contenuto che verranno scaricati
- La modalità di velocità di download scelta
- **Il comando equivalente** che potresti utilizzare per ripetere questa operazione in modo non-interattivo

### Modalità a Riga di Comando

Per un utilizzo automatizzato o per lo scripting:

```bash
./another_yt-dlp_wrapper.sh -n -u "https://example.com/watch?v=XXXX" -o ~/Video
```

### Opzioni Disponibili

```
Opzioni:
  -h, --help                Mostra questo messaggio di aiuto ed esce
  -o, --output-dir DIR      Imposta la directory di output (predefinita: directory corrente)
  -u, --url URL             URL multimediale (video, canale o playlist)
  -f, --file FILE           File di input con URL (uno per riga)
  -q, --quiet               Mostra meno output
  -s, --silent              Non mostra alcun output tranne gli errori
  -v, --verbose             Mostra output più dettagliato
  -n, --non-interactive     Esegue in modalità non interattiva (richiede --url o --file)
  --subs                    Scarica i sottotitoli creati manualmente
  --auto-subs               Scarica i sottotitoli generati automaticamente
  --sub-langs LANGS         Lingue dei sottotitoli da scaricare (separate da virgola, es. 'en,it')
                            Usa 'all' per tutte le lingue disponibili (predefinito)
  --log FILE                Salva tutto l'output in un file di log
  --no-videos               Salta i video normali
  --no-shorts               Salta gli shorts
  --no-live                 Salta le dirette e registrazioni live
  --only-videos             Scarica solo i video normali
  --only-shorts             Scarica solo gli shorts
  --only-live               Scarica solo le dirette e registrazioni live
  --slow                    Abilita la modalità download lenta (ritardo 5-10 sec) per evitare limiti di rate
  --fast                    Disabilita i ritardi di limitazione (può attivare i limiti del servizio)

Opzioni di autenticazione:
  --cookies-from-browser BROWSER
                            Estrae i cookie dal browser (chrome, firefox, edge, safari, ecc.)
  --cookies-file FILE       Usa i cookie da un file in formato Netscape
  --cookie-guide            Mostra una guida dettagliata per l'autenticazione tramite cookie

Nota: Le miniature e le descrizioni (con URL) sono automaticamente scaricate per tutti i video.
```

### Struttura dei File Scaricati

Per ogni video scaricato, lo script crea i seguenti file:
- `titolo_video.mp4` - Il file video in formato MP4
- `titolo_video.jpg` (o `.webp`) - L'immagine miniatura del video
- `titolo_video.description.txt` - Un file di testo contenente l'URL del video e la descrizione completa
- `titolo_video.info.json` - Metadati completi in formato JSON (canale, uploader, durata, visualizzazioni, ecc.)
- `titolo_video.srt` - File dei sottotitoli (se `--subs` o `--auto-subs` è abilitato)

Esempio del contenuto di `titolo_video.description.txt`:
```
Video URL: https://www.youtube.com/watch?v=XXXXX

Description:
----------------------------------------
Questa è la descrizione completa del video come appare su YouTube.
Può contenere più righe, link, timestamp e altre informazioni.
```

### Autenticazione

Lo script supporta l'autenticazione tramite cookie, che permette di:
- Scaricare video privati o non elencati
- Accedere a contenuti riservati ai membri
- Bypassare le restrizioni di età
- Scaricare video da canali a cui sei iscritto

#### Metodo 1: Estrarre Cookie dal Browser (Raccomandato)

Il metodo più semplice è estrarre automaticamente i cookie dal tuo browser:

```bash
# Estrai i cookie da Chrome
./another_yt-dlp_wrapper.sh -n -u "https://youtube.com/watch?v=XXXXX" --cookies-from-browser chrome

# Estrai i cookie da Firefox
./another_yt-dlp_wrapper.sh -n -u "https://youtube.com/watch?v=XXXXX" --cookies-from-browser firefox
```

Browser supportati: `chrome`, `chromium`, `firefox`, `edge`, `safari`, `opera`, `brave`, `vivaldi`

**Requisiti**: Devi essere loggato su YouTube nel browser specificato.

#### Metodo 2: Usare un File di Cookie

In alternativa, puoi esportare i cookie in un file e usarli:

1. Installa un'estensione del browser per esportare i cookie:
   - **Chrome/Edge**: "Get cookies.txt LOCALLY" o "cookies.txt"
   - **Firefox**: "cookies.txt"

2. Effettua il login su YouTube nel tuo browser

3. Naviga su youtube.com ed esporta i cookie usando l'estensione

4. Salva il file (es. `youtube_cookies.txt`)

5. Usa il file di cookie:
   ```bash
   ./another_yt-dlp_wrapper.sh -n -u "URL" --cookies-file ~/youtube_cookies.txt
   ```

**Nota sulla Sicurezza**: Mantieni il tuo file di cookie al sicuro poiché contiene dati di autenticazione!

#### Ottenere Aiuto

Per una guida completa passo-passo sull'autenticazione tramite cookie, esegui:
```bash
./another_yt-dlp_wrapper.sh --cookie-guide
```

### Programmazione con Cron

Per download automatizzati programmati utilizzando cron, combina le opzioni `-n`, `-s` e `-o`:

```bash
# Esempio di voce cron per scaricare un canale ogni giorno alle 3 del mattino
0 3 * * * /percorso/a/another_yt-dlp_wrapper.sh -n -s -u "https://example.com/@NomeCanale" -o /percorso/ai/video/
```

I flag usati per i job cron:
- `-n` (non-interattivo): necessario per l'esecuzione senza input dell'utente
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

## Caso d'Uso: Archivio Locale di Media con Aggiornamenti Automatici

Puoi creare un archivio locale dei tuoi contenuti multimediali preferiti che si mantiene automaticamente aggiornato:

1. Inizia con un download completo di tutti i tuoi canali/playlist preferiti:
   ```bash
   ./another_yt-dlp_wrapper.sh -n -f miei_canali_preferiti.txt -o ~/ArchivioMedia --subs --log ~/logs/media_iniziale.log
   ```

2. Configura un cron job per controllare periodicamente e scaricare nuovi video (questo esempio viene eseguito ogni giorno alle 2 di notte):
   ```bash
   # Aggiungi questo al tuo crontab (esegui 'crontab -e' per modificare)
   0 2 * * * /percorso/a/another_yt-dlp_wrapper.sh -n -s -f /percorso/a/miei_canali_preferiti.txt -o /percorso/a/ArchivioMedia --log /percorso/a/logs/media_aggiornamento_$(date +\%Y\%m\%d).log
   ```

Questa configurazione:
- Scaricherà inizialmente la storia completa dei tuoi canali preferiti
- Controllerà quotidianamente nuovi video e aggiungerà solo quelli alla tua collezione
- Organizzerà tutto per tipo di contenuto (video, shorts e dirette in cartelle separate)
- Manterrà log di ogni processo di aggiornamento
- Poiché yt-dlp salta i video già scaricati, verrà aggiunto solo nuovo contenuto

### Organizzazione dei Contenuti

Lo script organizza tutti i contenuti scaricati per tipo:
- I video normali vanno in `/nome_canale/videos/`
- Gli shorts vanno in `/nome_canale/shorts/`
- Le dirette e registrazioni live vanno in `/nome_canale/lives/`
- Le informazioni del canale sono salvate in `/nome_canale/channel_info.txt`

Ogni video è accompagnato da:
- La sua immagine miniatura (`.jpg` o `.webp`)
- Un file di descrizione (`.description.txt`) contenente l'URL del video e la descrizione completa
- Un file di metadati (`.info.json`) con le informazioni complete del video

Puoi personalizzare quali tipi di contenuto scaricare con le seguenti opzioni:
```bash
# Scarica solo video normali
./another_yt-dlp_wrapper.sh -n -u "https://example.com/c/NomeCanale" --only-videos

# Scarica tutto tranne gli shorts
./another_yt-dlp_wrapper.sh -n -u "https://example.com/c/NomeCanale" --no-shorts
```

### File di Informazioni del Canale

Lo script crea automaticamente un file `channel_info.txt` in ogni directory del canale contenente:

- **Metadati del Canale**: Nome, ID, URL, descrizione e numero di follower
- **Configurazione Download**: Quali tipi di contenuto sono stati scaricati, impostazioni sottotitoli, modalità di limitazione e il comando esatto utilizzato
- **Cronologia Download**: Timestamp di tutte le sessioni di download (formato: YYYY-MM-DD HH:MM:SS)

Esempio di contenuto `channel_info.txt`:
```
=== INFORMAZIONI CANALE ===
Data Download: 2024-01-15 14:30:22
URL Originale: https://example.com/@NomeCanale

Nome Canale: Canale di Esempio
ID Canale: UC1234567890abcdef
URL Canale: https://example.com/@NomeCanale
Descrizione: Questa è una descrizione di esempio del canale...

=== CONFIGURAZIONE DOWNLOAD ===
Directory Output: /home/user/video/Canale_di_Esempio
Download Video: true
Download Shorts: true
Download Live: true
Download Sottotitoli: Yes
Lingue Sottotitoli: all
Modalità Limitazione: normal
Comando Utilizzato: ./another_yt-dlp_wrapper.sh -n -u "https://example.com/@NomeCanale" -o ~/Video --subs

=== CRONOLOGIA DOWNLOAD ===
Download Precedenti:
Ultimo Download: 2024-01-15 14:30:22
Ultimo Download: 2024-01-16 09:15:33
```

Queste informazioni sono preziose per:
- **Traccia di Audit**: Tracciare quando sono avvenuti i download e cosa è stato configurato
- **Risoluzione Problemi**: Debug di problemi con configurazioni di download specifiche
- **Gestione Archivio**: Comprendere l'ambito e la cronologia della tua collezione multimediale
- **Automazione**: Riferimento alle impostazioni esatte utilizzate per download riusciti
# Scarica solo i video normali
./another_yt-dlp_wrapper.sh -n -u "https://example.com/c/NomeCanale" --only-videos

# Scarica tutto tranne gli shorts
./another_yt-dlp_wrapper.sh -n -u "https://example.com/c/NomeCanale" --no-shorts
```

### File di Informazioni del Canale

Lo script crea automaticamente un file `channel_info.txt` in ogni directory del canale contenente:

- **Metadati del Canale**: Nome, ID, URL, descrizione e numero di follower
- **Configurazione del Download**: Quali tipi di contenuto sono stati scaricati, impostazioni dei sottotitoli e modalità di limitazione del rate
- **Cronologia dei Download**: Timestamp di tutte le sessioni di download (formato: YYYY-MM-DD HH:MM:SS)
- **Informazioni del Sistema**: Versione dello script, versione di yt-dlp, utente e dettagli del sistema

Esempio di contenuto `channel_info.txt`:
```
=== INFORMAZIONI CANALE ===
Data Download: 2024-01-15 14:30:22
URL Originale: https://example.com/@NomeCanale

Nome Canale: Canale di Esempio
ID Canale: UC1234567890abcdef
URL Canale: https://example.com/@NomeCanale
Description: Questa è una descrizione di esempio del canale...

=== DOWNLOAD CONFIGURATION ===
Output Directory: /home/utente/video/Canale_di_Esempio
Download Videos: true
Download Shorts: true
Download Live: true
Download Subtitles: Yes
Subtitle Languages: all
Rate Limiting Mode: normal

=== SCRIPT INFORMATION ===
Script Version: 1.0.0
yt-dlp Version: 2024.01.01
User: nomeutente
System: Linux 6.1.0

=== DOWNLOAD HISTORY ===
Previous Downloads:
Last Download: 2024-01-15 14:30:22
Last Download: 2024-01-16 09:15:33
```

Queste informazioni sono preziose per:
- **Traccia di Audit**: Tenere traccia di quando sono avvenuti i download e cosa è stato configurato
- **Risoluzione dei Problemi**: Debug di problemi con configurazioni di download specifiche
- **Gestione dell'Archivio**: Comprendere la portata e la cronologia della collezione multimediale
- **Automazione**: Riferimento alle impostazioni esatte utilizzate per download di successo

### Protezione da Limitazione del Rate

Lo script include una protezione completa da limitazione del rate per evitare potenziali limiti del servizio e garantire download stabili. Sono disponibili tre modalità:

- **Modalità normale** (predefinita): protezione bilanciata con ritardi di 1-3 secondi tra le richieste
  - `--sleep-interval 1` (pausa di 1 secondo tra le richieste)
  - `--max-sleep-interval 3` (massimo 3 secondi se yt-dlp aumenta i ritardi)
  - `--retry-sleep 5` (5 secondi tra i tentativi di retry)
  - `--retries 3` e `--fragment-retries 3`

- **Modalità lenta** (`--slow`): approccio conservativo con ritardi di 5-10 secondi, ideale per grandi download batch
  - `--sleep-interval 5` (pausa di 5 secondi tra le richieste)
  - `--max-sleep-interval 10` (massimo 10 secondi)
  - `--retry-sleep 10` (10 secondi tra i tentativi di retry)
  - `--retries 5` e `--fragment-retries 5`

- **Modalità veloce** (`--fast`): ritardi minimi per download più veloci, usare con cautela per operazioni grandi
  - `--sleep-interval 0` (nessuna pausa tra le richieste)
  - Nessun ritardo di retry (può attivare i limiti del servizio)

Esempi:
```bash
# Usa la modalità lenta per download di canali grandi per essere più rispettosi verso il servizio
./another_yt-dlp_wrapper.sh -n -u "https://example.com/c/CanaleGrande" --slow

# Usa la modalità veloce per singoli video quando serve velocità
./another_yt-dlp_wrapper.sh -n -u "https://example.com/watch?v=XXXX" --fast
```

**Raccomandazione**: usa la modalità normale predefinita per la maggior parte delle operazioni, passa a `--slow` per grandi download batch o se riscontri limitazioni del servizio.

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
# Sincronizzazione giornaliera - scarica solo nuovi video dall'ultima esecuzione
./another_yt-dlp_wrapper.sh -n -u "https://example.com/c/NomeCanale" \
  -o ~/ArchivioMedia \
  --subs \
  --slow \
  --silent \
  --log ~/logs/sync_$(date +%Y%m%d).log
```

### Esempi di Utilizzo Base

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

Scarica video con lingue specifiche per i sottotitoli:
```bash
./another_yt-dlp_wrapper.sh -n -u "https://example.com/watch?v=XXXX" --subs --sub-langs en,it
```

Scarica solo video normali (no shorts o dirette):
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

Abilita il logging completo su file:
```bash
./another_yt-dlp_wrapper.sh -n -u "https://example.com/watch?v=XXXX" --log log-download.txt
```

### Utilizzo di un File di Input

Puoi creare un file di testo con URL multimediali (uno per riga) per scaricare più video, canali o playlist in una singola operazione. Per esempio:

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
./another_yt-dlp_wrapper.sh -n -f miei_canali.txt -o ~/Video --subs
```

## Licenza

Questo progetto è rilasciato sotto licenza Creative Commons Attribution-NonCommercial 4.0 International - vedi il file [LICENSE](../LICENSE) nella directory principale per i dettagli.

## Riconoscimenti

- Questo script utilizza [yt-dlp](https://github.com/yt-dlp/yt-dlp), un'eccellente utilità per il download multimediale.

---

Questo script fa parte della collezione [another_bucket_of_tools](https://github.com/palumbou/another_bucket_of_tools).
