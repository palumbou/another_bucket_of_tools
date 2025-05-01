# Another Bing Image Of The Day

> **Lingue disponibili**: [English](README.md) | [Italiano (corrente)](README.it.md)

Uno script bash che scarica l'immagine quotidiana di sfondo di Bing e i relativi metadati in base alla località selezionata.

## Caratteristiche

Questo script offre le seguenti funzionalità:

1. **Download dell'Immagine del Giorno di Bing**
   - Scarica l'attuale Immagine del Giorno di Bing per la località selezionata.
   - Salva l'immagine con un prefisso del nome file basato sulla data nella directory di output specificata.
   - Gestione degli errori migliorata per download più affidabili.

2. **Salvataggio dei Metadati dell'Immagine**
   - Crea un file di testo con i metadati accanto a ciascuna immagine, contenente:
     - Titolo dell'immagine
     - Informazioni sul copyright
     - Descrizione dell'immagine
     - Date di inizio e fine
     - Altri metadati da Bing
   - Supporta l'analisi JSON con jq (se installato) per un'estrazione dei metadati più affidabile.

3. **Selezione della Località**
   - Scegli da un elenco completo di opzioni di località (più di 57 diverse località).
   - Rilevamento automatico della località basato sull'indirizzo IP con servizi alternativi di fallback.
   - Il sistema ricorda la preferenza della località tra le diverse esecuzioni.

4. **Directory di Output Configurabili**
   - Specifica una directory di output primaria per immagini e metadati.
   - Opzionalmente specifica una directory secondaria "wallpaper" per gli sfondi del desktop.
   - Menu di configurazione per impostare facilmente le directory.

5. **Supporto alla Linea di Comando**
   - Esecuzione interattiva con un'interfaccia a menu migliorata.
   - Utilizzo di parametri da linea di comando per automazione e scripting.
   - Opzione di modalità silenziosa per un funzionamento completamente silenzioso negli script.

6. **Configurazione Persistente**
   - Salva le preferenze nel file di configurazione `env.conf`.
   - Sovrascrivi le impostazioni salvate tramite parametri da linea di comando quando necessario.

## Installazione

1. Scarica lo script:
   ```bash
   git clone https://github.com/palumbou/another_bucket_of_tools.git
   cd another_bucket_of_tools/another_bing_image_of_the_day_downloader
   ```

2. Rendi lo script eseguibile:
   ```bash
   chmod u+x another_bing_image_of_the_day_downloader.sh
   ```

3. Esegui lo script:
   ```bash
   ./another_bing_image_of_the_day_downloader.sh
   ```

## Utilizzo

### Modalità Interattiva

Esegui semplicemente lo script senza parametri:

```bash
./another_bing_image_of_the_day_downloader.sh
```

Questo visualizzerà il menu principale con le opzioni per:
1. Scaricare l'immagine di oggi
2. Cambiare la località
3. Configurazione (imposta directory di output)
4. Uscire

### Opzioni da Linea di Comando

Lo script supporta le seguenti opzioni da linea di comando:

```
Utilizzo: ./another_bing_image_of_the_day_downloader.sh [opzioni]

Opzioni:
  -o, --output PATH       Specifica la directory di output per immagini e file di info
  -w, --wallpaper PATH    Specifica una seconda directory per salvare l'immagine come sfondo
  -l, --locale LOCALE     Specifica la località da utilizzare (es., en-US, it-IT, ecc.)
  -q, --quiet             Modalità silenziosa, output minimo
  -s, --silent            Modalità completamente silenziosa, nessun output (implica --quiet)
  -h, --help              Visualizza questo messaggio di aiuto ed esci

Esempi:
  ./another_bing_image_of_the_day_downloader.sh --output ~/Pictures/BingImages
  ./another_bing_image_of_the_day_downloader.sh --wallpaper ~/Pictures/Wallpapers
  ./another_bing_image_of_the_day_downloader.sh --locale it-IT
  ./another_bing_image_of_the_day_downloader.sh --silent
  ./another_bing_image_of_the_day_downloader.sh -o ~/Pictures/BingImages -w ~/Pictures/Wallpapers -l en-GB
```

### File di Configurazione

Lo script utilizza un file `env.conf` per memorizzare la configurazione persistente:

```bash
LOCALE=en-US
LOCALE_AUTO=false  # Impostare a true se si utilizza la località rilevata automaticamente
# Decommenta e imposta questi valori per specificare le directory predefinite 
# OUTPUT_DIR=/percorso/verso/le/tue/immagini
# WALLPAPER_DIR=/percorso/verso/il/tuo/sfondo
```

Puoi modificare questo file manualmente o lasciare che lo script lo aggiorni quando cambi le impostazioni attraverso il menu interattivo.

## Integrazione con lo Sfondo

Quando si utilizza l'opzione della directory per gli sfondi (-w o WALLPAPER_DIR in env.conf), lo script:

1. Copia l'immagine scaricata nella directory specificata come `bing_wallpaper.jpg`
2. Crea un file `bing_wallpaper.txt` contenente solo il titolo dell'immagine

Questo rende facile l'integrazione con ambienti desktop o script che impostano lo sfondo giornaliero.

## Esempi di Casi d'Uso

### Utilizzo con Hyprland

Puoi facilmente configurare Hyprland per scaricare e utilizzare l'immagine del giorno di Bing come sfondo aggiungendo al tuo `hyprland.conf`:

```
# Scarica l'immagine del giorno di Bing come sfondo all'avvio
exec-once = /percorso/a/another_bing_image_of_the_day_downloader.sh -q -w ~/.config/hypr/wallpapers
```

Poi nel tuo file `hyprpaper.conf`, aggiungi semplicemente:

```
preload = ~/.config/hypr/wallpapers/bing_wallpaper.jpg
wallpaper = eDP-1,~/.config/hypr/wallpapers/bing_wallpaper.jpg
```

### Utilizzo con Hyprlock

Per Hyprlock, puoi semplicemente fare riferimento allo stesso file di immagine direttamente nel tuo `hyprlock.conf`:

```
background {
    # ...altre configurazioni...
    path = ~/.config/hypr/wallpapers/bing_wallpaper.jpg
}
```

In questo modo, sia Hyprland che Hyprlock utilizzeranno lo stesso file immagine che viene aggiornato ogni volta che avvii una sessione di Hyprland.

## Supporto per le Località

Lo script supporta più di 57 diverse località, tra cui:

- Inglese (varie regioni)
- Lingue europee (tedesco, francese, spagnolo, italiano, ecc.)
- Lingue asiatiche (giapponese, cinese, coreano, ecc.)
- E molte altre

Usa l'opzione "auto" per rilevare automaticamente la tua località in base al tuo indirizzo IP.

## Requisiti

- Shell Bash
- curl
- jq (opzionale, per analisi JSON avanzata)
- Connessione Internet
- Utilità Unix di base (grep, sed, ecc.)

## Licenza

Questo progetto è rilasciato sotto la licenza Creative Commons Attribution-NonCommercial 4.0 International - vedi il file [LICENSE](../LICENSE) nella directory principale per i dettagli.

---

Questo script fa parte della collezione [another_bucket_of_tools](https://github.com/palumbou/another_bucket_of_tools).