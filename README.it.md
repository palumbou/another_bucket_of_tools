# Another Bucket of Tools

> **Lingue disponibili**: [English](README.md) | [Italiano (corrente)](README.it.md)

Una raccolta di script shell sviluppati con l'assistenza dell'IA per ricreare utilità comunemente disponibili ma con miglioramenti personalizzati adattati alle mie specifiche esigenze.

## Introduzione

Internet è pieno di vari script di utilità per diversi scopi, ma spesso mi sono trovato a desiderare funzionalità o modifiche specifiche che non erano disponibili nelle soluzioni esistenti. Invece di accontentarmi di ciò che era disponibile, ho deciso di creare le mie versioni di questi strumenti.

**Another Bucket of Tools** è nato dal mio desiderio di:
1. Imparare a scrivere quanto meglio possibile prompt di interrogazioni per i modelli LLM dell'AI
2. Creare versioni personalizzate di utilità comuni che si adattano meglio al mio flusso di lavoro
3. Migliorare la mia comprensione dello shell scripting e dei sistemi Linux

Ogni script in questo repository è il risultato di specifiche interrogazioni ai modelli linguistici di IA, progettate per aiutarmi ad apprendere come formulare prompt più efficaci quando si interagisce con sistemi basati su LLM. Questi esperimenti di prompt engineering hanno prodotto strumenti pratici ed efficienti, aiutandomi contemporaneamente a capire come comunicare meglio con gli assistenti AI.

## Strumenti Disponibili

Attualmente, questo repository contiene i seguenti strumenti:

### 1. Another Bing Image of the Day Downloader

Uno script che scarica l'immagine giornaliera di Bing con le seguenti caratteristiche:
- Rilevamento automatico della locale basato sull'indirizzo IP
- Supporto per multiple directory di output (una per l'archivio, una per lo sfondo attivo)
- Supporto per 57 diverse locale
- Salvataggio dei metadati insieme all'immagine
- Modalità interattiva e da riga di comando
- Configurazione tramite file di configurazione o argomenti da riga di comando

**Posizione**: [/another_bing_image_of_the_day_downloader](./another_bing_image_of_the_day_downloader)

### 2. Another One Bites the Dust

Un'utilità completa per la pulizia del sistema che:
- Pulisce i file di cache dai browser e dalle directory di sistema
- Rimuove i vecchi file di log
- Elimina i file temporanei in base all'età
- Svuota le directory del cestino
- Pulisce le cache dei gestori di pacchetti (apt, dnf, pacman, nix)
- Rimuove i file di backup
- Pulisce le risorse Docker
- Include una modalità di prova per visualizzare in anteprima le modifiche
- Mostra lo spazio recuperato dopo la pulizia
- Supporta modalità interattiva e non interattiva

**Posizione**: [/another_one_bites_the_dust](./another_one_bites_the_dust)

### 3. Another Home Backup Tool

Un semplice script bash per eseguire il backup dei file essenziali dalla tua directory home:
- Crea un archivio tar compresso della tua directory home
- Si concentra solo sui file e le directory essenziali
- Esclude cache, log e altri file non necessari
- Nomina i backup con il tuo nome utente e la data corrente
- Consente di specificare una destinazione personalizzata per il backup
- Se non viene fornita una destinazione, salva in ~/backup/

**Posizione**: [/another_home_backup_tool](./another_home_backup_tool)

### 4. Another yt-dlp wrapper

Uno script wrapper completo per yt-dlp che gestisce i download di contenuti multimediali da YouTube e altri siti con funzionalità avanzate di organizzazione e automazione:
- Scarica singoli video, interi canali o playlist
- Organizza i contenuti per tipo (video, shorts, dirette) in cartelle separate
- Scarica automaticamente miniature, descrizioni e metadati per tutti i video
- Supporta il download di sottotitoli (manuali e auto-generati) in più lingue
- Supporto autenticazione tramite cookie del browser o file di cookie per contenuti privati/riservati ai membri
- Crea file dettagliati con informazioni del canale e cronologia dei download
- Protezione rate limiting con modalità di velocità configurabili
- Modalità interattiva con configurazione guidata o modalità a riga di comando per l'automazione
- Supporto elaborazione batch con file di lista URL
- Sistema di logging completo
- Download riprendibili e rilevamento duplicati

**Posizione**: [/another_yt-dlp_wrapper](./another_yt-dlp_wrapper)

### 5. Another NixOS Manager

Uno strumento completo di gestione del sistema progettato specificamente per NixOS con le seguenti caratteristiche:
- Aggiornamenti di sistema: Aggiorna i canali e ricostruisce con un solo comando
- Test sicuro: Testa le configurazioni prima di renderle permanenti
- Upgrade versioni major: Aggiorna in sicurezza alle nuove release NixOS con test automatico e rollback
- Pulizia sistema: Rimuove le vecchie generazioni con periodo di ritenzione personalizzabile (default: 7 giorni)
- Gestione generazioni: Elenca ed effettua rollback a generazioni precedenti o specifiche
- Validazione configurazione: Controlla la sintassi prima della ricostruzione
- Modalità operative multiple: Interattiva, non-interattiva, dry-run e verbose
- Supporto configurazioni personalizzate: Usa percorsi personalizzati dei file di configurazione
- Caratteristiche di sicurezza: Rollback automatico in caso di errori, preservazione generazioni, conferme interattive
- Pronto per automazione: Esempi per cron e systemd timer inclusi

**Posizione**: [/another_nixos_manager](./another_nixos_manager)

## Utilizzo

Ogni strumento include il proprio README con istruzioni dettagliate sull'utilizzo, e gli script stessi contengono informazioni di aiuto accessibili tramite il flag `--help`.

## Contribuire

Sentiti libero di fare un fork di questo repository e adattare questi strumenti alle tue esigenze. Se hai miglioramenti che potrebbero essere utili ad altri, le pull request sono benvenute.

## Disclaimer

Questi script sono forniti così come sono, senza alcuna garanzia. Leggi sempre la documentazione dello script e comprendi cosa fa uno script prima di eseguirlo sul tuo sistema. Alcuni script (in particolare l'utilità di pulizia) possono eliminare permanentemente file dal tuo sistema.