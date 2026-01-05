# Another yt-dlp Cookies Exporter

> **Lingue disponibili**: [English](COOKIES_EXPORTER_README.md) | [Italiano (corrente)](COOKIES_EXPORTER_README.it.md)

Questo script esporta i cookie da Chrome/Chromium o Firefox in un file in formato Netscape utilizzabile con yt-dlp.

## Caratteristiche

- **Supporto multi-browser**: Chrome, Chromium e Firefox
- **Supporto multi-distribuzione**: NixOS, Debian, Fedora e Arch Linux
- **Nessuna dipendenza esterna**: Usa solo il modulo sqlite3 integrato in Python
- **Supporto profili**: Esporta da profili browser specifici
- **Filtro domini**: Esporta solo i cookie necessari per l'autenticazione

## Requisiti

### Tutte le distribuzioni (eccetto NixOS)
- **Python 3**: Richiesto per l'estrazione dei cookie
- **sqlite3**: Solitamente incluso con Python

Installazione:
```bash
# Debian/Ubuntu/Linux Mint
sudo apt install python3

# Fedora/RHEL/CentOS
sudo dnf install python3

# Arch Linux/Manjaro
sudo pacman -S python
```

### NixOS
**Gestione automatica delle dipendenze**: Se Python 3 o sqlite3 mancano, lo script avvia automaticamente una `nix-shell` temporanea con i pacchetti richiesti. Non sono necessarie installazioni permanenti o modifiche a configuration.nix!

## Utilizzo

### Utilizzo Base

Esporta i cookie dal profilo Chrome predefinito:
```bash
./another_yt-dlp_cookies_exporter.sh
```

### Specificare File di Output

```bash
./another_yt-dlp_cookies_exporter.sh cookies.txt
```

### Selezionare Browser

Usa Chrome (predefinito):
```bash
BROWSER="chrome" ./another_yt-dlp_cookies_exporter.sh
```

Usa Firefox:
```bash
BROWSER="firefox" ./another_yt-dlp_cookies_exporter.sh
```

### Selezionare Profilo Browser

Per Chrome/Chromium:
```bash
CHROME_PROFILE="Profile 1" ./another_yt-dlp_cookies_exporter.sh cookies.txt
```

Profili Chrome comuni:
- `Default` (profilo predefinito)
- `Profile 1`
- `Profile 2`

Per trovare i tuoi profili Chrome:
```bash
ls ~/.config/google-chrome/
# oppure per Chromium
ls ~/.config/chromium/
```

Per Firefox:
```bash
FIREFOX_PROFILE="xxxxxxxx.default" ./another_yt-dlp_cookies_exporter.sh cookies.txt
```

Per trovare il tuo profilo Firefox:
```bash
ls ~/.mozilla/firefox/
```

### Tramite lo Script Wrapper Principale

Il modo più semplice è chiamarlo dallo script wrapper principale:

```bash
# Esporta i cookie in modo interattivo
./another_yt-dlp_wrapper.sh --export-cookies
```

Poi usa i cookie esportati:
```bash
./another_yt-dlp_wrapper.sh -n -u <URL> --cookies-file cookies.txt
```

## Variabili d'Ambiente

- `BROWSER`: Browser da cui esportare (`chrome`, `chromium`, `firefox`) - predefinito: `chrome`
- `CHROME_PROFILE`: Nome del profilo Chrome - predefinito: `Default`
- `FIREFOX_PROFILE`: Nome o pattern del profilo Firefox - predefinito: rilevamento automatico

## Come Funziona

1. Localizza il database dei cookie del browser (formato SQLite)
2. Crea una copia temporanea per evitare problemi di locking
3. Usa il modulo sqlite3 integrato di Python per leggere i cookie
4. Filtra i cookie per domini specifici (es. youtube.com, google.com)
5. Esporta in formato Netscape compatibile con yt-dlp
6. Imposta permessi restrittivi (600) sul file di output

## Posizioni Browser Supportate

### Chrome/Chromium
- `~/.config/google-chrome/<profilo>/Cookies`
- `~/.config/chromium/<profilo>/Cookies`
- `~/.var/app/com.google.Chrome/config/google-chrome/<profilo>/Cookies` (Flatpak)
- `~/.var/app/org.chromium.Chromium/config/chromium/<profilo>/Cookies` (Flatpak)

### Firefox
- `~/.mozilla/firefox/<profilo>/cookies.sqlite`
- `~/.var/app/org.mozilla.firefox/.mozilla/firefox/<profilo>/cookies.sqlite` (Flatpak)

## Note Importanti

1. **Chiudi il browser** prima di eseguire questo script. Un browser aperto blocca il database dei cookie.

2. **I cookie contengono dati sensibili**. Mantieni il file esportato sicuro:
   - Non condividere il file dei cookie
   - Non committarlo in sistemi di controllo versione
   - Eliminalo dopo l'uso
   - I permessi del file sono automaticamente impostati a 600 (lettura/scrittura solo per il proprietario)

3. **Filtro domini**: Lo script esporta solo i cookie per domini specificati (youtube.com, google.com, accounts.google.com per impostazione predefinita).

4. **Autenticazione**: Usa i cookie esportati per accedere a video privati, contenuti riservati ai membri o per bypassare restrizioni di età.

## Utilizzo Cookie Esportati

### Con yt-dlp direttamente
```bash
yt-dlp --cookies cookies.txt <URL>
```

### Con lo script wrapper
```bash
./another_yt-dlp_wrapper.sh -n -u <URL> --cookies-file cookies.txt
```

## Risoluzione Problemi

### "Chiudi il browser prima di eseguire"
Il database dei cookie è bloccato mentre il browser è aperto. Chiudi tutte le finestre del browser e riprova.

### "Database cookie non trovato"
- Verifica il nome del profilo browser con i comandi `ls` mostrati sopra
- Controlla di aver usato il browser e effettuato l'accesso ai siti web
- Assicurati che il browser abbia creato il database dei cookie

### "HTTP Error 429: Too Many Requests"
Questo errore è gestito automaticamente nello script wrapper principale con l'opzione `--extractor-args`. Il wrapper ora usa client player alternativi per evitare limiti di velocità.

### Errori di permessi
- Assicurati di avere accesso in lettura alla directory di configurazione del browser
- I file dei cookie sono tipicamente leggibili dall'utente che esegue il browser

## Esempio di Flusso di Lavoro

1. Accedi al tuo account nel browser

2. Esporta i cookie:
```bash
./another_yt-dlp_cookies_exporter.sh cookies.txt
```

3. Usa i cookie per scaricare contenuti:
```bash
./another_yt-dlp_wrapper.sh -n -u "https://example.com/watch?v=..." --cookies-file cookies.txt
```

4. Elimina il file dei cookie quando hai finito:
```bash
rm cookies.txt
```

## Nota sulla Sicurezza

Il file dei cookie esportato contiene i tuoi dati di autenticazione. Sempre:
- Mantienilo sicuro e privato
- Non condividerlo con altri
- Non committarlo in sistemi di controllo versione
- Eliminalo dopo l'uso
- Tieni presente che i permessi del file sono impostati automaticamente a 600

## Licenza

Questo script fa parte della collezione [another_bucket_of_tools](https://github.com/palumbou/another_bucket_of_tools) e segue la stessa licenza.
