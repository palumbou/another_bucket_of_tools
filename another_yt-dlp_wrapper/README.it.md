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

2. **Modalità di Funzionamento Multiple**
   - Modalità interattiva con domande guidate
   - Modalità a riga di comando per scripting e automazione
   - Rilevamento intelligente degli URL per video, canali e playlist

3. **Gestione Efficiente**
   - Salta i video già esistenti per evitare duplicati (non sovrascrive mai i video già scaricati)
   - Crea automaticamente una struttura di directory organizzata
   - Riprende i download interrotti
   - Elaborazione batch con supporto per file di input
   - Sistema di logging completo per debug e tracciamento delle operazioni

## Requisiti

- `bash` - L'ambiente shell per eseguire lo script
- `yt-dlp` - L'utilità di base per il download dei video
- `curl`, `grep`, `sed`, `mkdir` - Utilità standard di Linux

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
1. Inserire un URL multimediale (video, canale o playlist)
2. Specificare una directory di output (o utilizzare la directory corrente)
3. Confermare le tue scelte prima che inizi il download

### Modalità a Riga di Comando

Per un utilizzo automatizzato o per lo scripting:

```bash
./another_yt-dlp_wrapper.sh -n -u "https://youtube.com/watch?v=XXXX" -o ~/Video
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
```

### Programmazione con Cron

Per download automatizzati programmati utilizzando cron, combina le opzioni `-n`, `-s` e `-o`:

```bash
# Esempio di voce cron per scaricare un canale ogni giorno alle 3 del mattino
0 3 * * * /percorso/a/another_yt-dlp_wrapper.sh -n -s -u "https://youtube.com/@NomeCanale" -o /percorso/ai/video/
```

I flag usati per i job cron:
- `-n` (non-interattivo): Necessario per l'esecuzione senza input dell'utente
- `-s` (silenzioso): Sopprime tutto l'output tranne gli errori, ideale per cron
- `-o` (directory di output): Specifica dove salvare i video scaricati

## Esempi

Scarica un singolo video:
```bash
./another_yt-dlp_wrapper.sh -n -u "https://youtube.com/watch?v=XXXX"
```

Scarica tutti i video da un canale:
```bash
./another_yt-dlp_wrapper.sh -n -u "https://youtube.com/c/NomeCanale" -o ~/Video
```

Scarica una playlist:
```bash
./another_yt-dlp_wrapper.sh -n -u "https://youtube.com/playlist?list=XXXX"
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

Puoi personalizzare quali tipi di contenuto scaricare con le seguenti opzioni:
```bash
# Scarica solo i video normali
./another_yt-dlp_wrapper.sh -n -u "https://youtube.com/c/NomeCanale" --only-videos

# Scarica tutto tranne gli shorts
./another_yt-dlp_wrapper.sh -n -u "https://youtube.com/c/NomeCanale" --no-shorts
```

Scarica video con sottotitoli creati manualmente:
```bash
./another_yt-dlp_wrapper.sh -n -u "https://youtube.com/watch?v=XXXX" --subs
```

Scarica video con sottotitoli generati automaticamente:
```bash
./another_yt-dlp_wrapper.sh -n -u "https://youtube.com/watch?v=XXXX" --auto-subs
```

Scarica video con entrambi i tipi di sottotitoli:
```bash
./another_yt-dlp_wrapper.sh -n -u "https://youtube.com/watch?v=XXXX" --subs --auto-subs
```

Scarica video con lingue specifiche per i sottotitoli:
```bash
./another_yt-dlp_wrapper.sh -n -u "https://youtube.com/watch?v=XXXX" --subs --sub-langs en,it
```

Scarica solo video normali (no shorts o dirette):
```bash
./another_yt-dlp_wrapper.sh -n -u "https://youtube.com/c/NomeCanale" --only-videos
```

Scarica solo shorts:
```bash
./another_yt-dlp_wrapper.sh -n -u "https://youtube.com/c/NomeCanale" --only-shorts
```

Scarica video e dirette, ma salta gli shorts:
```bash
./another_yt-dlp_wrapper.sh -n -u "https://youtube.com/c/NomeCanale" --no-shorts
```

Scarica video da una lista di URL in un file:
```bash
./another_yt-dlp_wrapper.sh -n -f canali.txt
```

Abilita il logging completo su file:
```bash
./another_yt-dlp_wrapper.sh -n -u "https://youtube.com/watch?v=XXXX" --log log-download.txt
```

### Utilizzo di un File di Input

Puoi creare un file di testo con URL di YouTube (uno per riga) per scaricare più video, canali o playlist in una singola operazione. Per esempio:

```
# I miei canali preferiti (le righe che iniziano con # vengono ignorate)
https://youtube.com/c/Canale1
https://youtube.com/c/Canale2

# Playlist
https://youtube.com/playlist?list=XXXX
https://youtube.com/playlist?list=YYYY

# Video individuali
https://youtube.com/watch?v=VIDEO1
https://youtube.com/watch?v=VIDEO2
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
