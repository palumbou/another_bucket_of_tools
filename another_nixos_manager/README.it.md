# Another NixOS Manager

> **Lingue disponibili**: [English](README.md) | [Italiano (corrente)](README.it.md)

Uno script bash completo per la gestione di sistemi NixOS, che gestisce aggiornamenti, ricostruzioni, test, pulizia e upgrade di versioni major.

## Caratteristiche

- **Aggiornamenti di Sistema**: aggiorna i canali e ricostruisce con un solo comando
- **Test Sicuro**: testa le configurazioni prima di renderle permanenti
- **Upgrade di Versione**: aggiorna in modo sicuro alle release major di NixOS con test automatico
- **Pulizia del Sistema**: rimuove le vecchie generazioni e ottimizza il Nix store
- **Supporto Rollback**: rollback facile alle generazioni precedenti
- **Configurazioni Personalizzate**: supporto per percorsi personalizzati dei file di configurazione
- **Modalità Interattiva e Non-interattiva**: adatto sia per uso manuale che per automazione
- **Modalità Dry Run**: anteprima delle azioni senza eseguirle
- **Validazione**: controlla la sintassi della configurazione prima della ricostruzione

## Requisiti

- **NixOS**: questo script è progettato specificamente per NixOS
- **Privilegi root**: la maggior parte delle operazioni richiede sudo/root
- **Strumenti standard NixOS**: nixos-rebuild, nix-channel, nix-collect-garbage (inclusi in NixOS)

## Installazione

1. Scarica lo script:
   ```bash
   cd /path/to/your/scripts
   git clone https://github.com/palumbou/another_bucket_of_tools.git
   cd another_bucket_of_tools/another_nixos_manager
   ```

2. Rendilo eseguibile:
   ```bash
   chmod +x another_nixos_manager.sh
   ```

3. (Opzionale) Crea un link simbolico per un accesso facile:
   ```bash
   sudo ln -s $(pwd)/another_nixos_manager.sh /usr/local/bin/nixos-manager
   ```

## Utilizzo

### Comandi Base

```bash
# Mostra l'aiuto e i comandi disponibili
./another_nixos_manager.sh --help

# Mostra informazioni di sistema
./another_nixos_manager.sh info

# Aggiorna il sistema (aggiorna canali + ricostruisce)
sudo ./another_nixos_manager.sh update

# Testa la configurazione prima di applicarla
sudo ./another_nixos_manager.sh test

# Pulisci vecchie generazioni (default: più vecchie di 7 giorni)
sudo ./another_nixos_manager.sh clean

# Pulisci generazioni più vecchie di 30 giorni
sudo ./another_nixos_manager.sh clean 30

# Pulizia aggressiva di tutte le vecchie generazioni
sudo ./another_nixos_manager.sh clean-all

# Elenca tutte le generazioni di sistema
sudo ./another_nixos_manager.sh list

# Rollback alla generazione precedente
sudo ./another_nixos_manager.sh rollback

# Valida la sintassi della configurazione
sudo ./another_nixos_manager.sh validate
```

### Utilizzo di Configurazioni Personalizzate

```bash
# Usa un file di configurazione personalizzato
sudo ./another_nixos_manager.sh -c /percorso/a/configurazione.nix update

# Testa configurazione personalizzata
sudo ./another_nixos_manager.sh -c /percorso/a/configurazione.nix test
```

### Azioni di Rebuild

Il comando `rebuild` supporta diverse azioni:

```bash
# Switch: costruisci e attiva, rendila predefinita per il boot
sudo ./another_nixos_manager.sh rebuild switch

# Boot: costruisci e rendi predefinita per il boot, ma non attivare ora
sudo ./another_nixos_manager.sh rebuild boot

# Test: costruisci e attiva, ma non rendere predefinita per il boot
sudo ./another_nixos_manager.sh rebuild test

# Build: solo costruisci, non attivare né cambiare il boot predefinito
sudo ./another_nixos_manager.sh rebuild build
```

### Upgrade Versioni Major

Aggiorna a una nuova versione major di NixOS con test automatico:

```bash
# Upgrade da 24.05 a 24.11
sudo ./another_nixos_manager.sh upgrade 24.11

# Upgrade con configurazione personalizzata
sudo ./another_nixos_manager.sh -c /percorso/a/config.nix upgrade 25.05
```

Il processo di upgrade:
1. Fa il backup della generazione corrente (per il rollback)
2. Aggiorna il canale alla nuova versione
3. Valida la tua configurazione con la nuova versione
4. Testa la nuova configurazione
5. Chiede conferma prima di renderla permanente
6. Effettua automaticamente il rollback se qualche passaggio fallisce

### Opzioni Avanzate

```bash
# Dry run: vedi cosa verrebbe fatto senza farlo
sudo ./another_nixos_manager.sh --dry-run update

# Modalità verbose: mostra output dettagliato
sudo ./another_nixos_manager.sh --verbose update

# Modalità non-interattiva: assume sì a tutti i prompt
sudo ./another_nixos_manager.sh --yes update

# Combina opzioni
sudo ./another_nixos_manager.sh -c /percorso/a/config.nix --verbose --yes update
```

## Workflow Comuni

### Manutenzione Regolare del Sistema

```bash
# Routine di manutenzione settimanale
sudo ./another_nixos_manager.sh update     # Aggiorna sistema
sudo ./another_nixos_manager.sh clean      # Pulisci vecchie generazioni
```

### Test delle Modifiche alla Configurazione

```bash
# Dopo aver modificato /etc/nixos/configuration.nix
sudo ./another_nixos_manager.sh validate   # Controlla sintassi
sudo ./another_nixos_manager.sh test       # Testa senza rendere permanente

# Se il test passa e confermi, applica permanentemente:
sudo ./another_nixos_manager.sh rebuild switch
```

### Upgrade a Nuova Release NixOS

```bash
# Controlla versione corrente
./another_nixos_manager.sh info

# Aggiorna a nuova versione (es. 24.11)
sudo ./another_nixos_manager.sh upgrade 24.11

# Se qualcosa va storto, fai rollback
sudo ./another_nixos_manager.sh rollback
```

### Sviluppo Configurazione Personalizzata

```bash
# Lavorando su un file di configurazione personalizzato
sudo ./another_nixos_manager.sh -c ~/nixos-test/configuration.nix validate
sudo ./another_nixos_manager.sh -c ~/nixos-test/configuration.nix test

# Una volta soddisfatto, puoi copiarlo in /etc/nixos/
```

## Riferimento Opzioni

| Opzione | Descrizione |
|---------|-------------|
| `-c, --config PATH` | Usa file di configurazione personalizzato (default: /etc/nixos/configuration.nix) |
| `-n, --dry-run` | Mostra cosa verrebbe fatto senza eseguire |
| `-v, --verbose` | Mostra output dettagliato dai comandi |
| `-y, --yes` | Modalità non-interattiva, assume sì a tutti i prompt |
| `-h, --help` | Mostra messaggio di aiuto |

## Riferimento Comandi

| Comando | Descrizione | Richiede Root |
|---------|-------------|---------------|
| `info` | Mostra informazioni di sistema | No |
| `update` | Aggiorna canali e ricostruisce sistema | Sì |
| `rebuild [action]` | Ricostruisce con azione (switch/boot/test/build) | Sì |
| `test` | Testa configurazione senza renderla predefinita | Sì |
| `clean [giorni]` | Rimuove generazioni più vecchie dei giorni specificati (default: 7) | Sì |
| `clean-all` | Rimuove tutte le vecchie generazioni | Sì |
| `list` | Elenca tutte le generazioni di sistema | Sì |
| `rollback [gen]` | Rollback a generazione precedente o specifica | Sì |
| `upgrade VERSION` | Upgrade a versione major NixOS | Sì |
| `validate` | Valida sintassi configurazione | Sì |

## Caratteristiche di Sicurezza

- **Validazione Configurazione**: Valida sempre la sintassi prima della ricostruzione
- **Modalità Test**: Testa le configurazioni senza renderle permanenti
- **Rollback Automatico**: Gli upgrade major effettuano rollback automatico se i test falliscono
- **Preservazione Generazioni**: Le vecchie generazioni sono mantenute per rollback facile
- **Conferme Interattive**: Richiede conferma prima di operazioni major (può essere disabilitato con `--yes`)
- **Modalità Dry Run**: Anteprima delle modifiche senza applicarle

## Risoluzione Problemi

### La validazione della configurazione fallisce

```bash
# Controlla errori di sintassi nella tua configurazione
sudo ./another_nixos_manager.sh validate

# Usa modalità verbose per vedere messaggi di errore dettagliati
sudo ./another_nixos_manager.sh --verbose validate
```

### Il sistema non si avvia dopo l'aggiornamento

Avvia una generazione precedente dal menu GRUB, poi:

```bash
# Elenca le generazioni disponibili
sudo ./another_nixos_manager.sh list

# Rollback a una generazione specifica
sudo ./another_nixos_manager.sh rollback 123
```

### L'upgrade major è fallito

Lo script tenta automaticamente il rollback. Se necessario, fai rollback manualmente:

```bash
sudo ./another_nixos_manager.sh rollback
```

### Poco spazio disco dopo molti aggiornamenti

```bash
# Pulisci vecchie generazioni aggressivamente
sudo ./another_nixos_manager.sh clean-all

# Questo rimuove tutte le vecchie generazioni e ottimizza lo store
```

## Automazione

### Cron Job per Aggiornamenti Regolari

Aggiungi al crontab di root (`sudo crontab -e`):

```bash
# Aggiorna sistema ogni domenica alle 2 AM
0 2 * * 0 /percorso/a/another_nixos_manager.sh --yes update

# Pulisci vecchie generazioni ogni mese
0 3 1 * * /percorso/a/another_nixos_manager.sh --yes clean
```

### Systemd Timer (Metodo Preferito)

Crea `/etc/nixos/nixos-update.timer`:

```ini
[Unit]
Description=Aggiornamento Settimanale NixOS

[Timer]
OnCalendar=weekly
Persistent=true

[Install]
WantedBy=timers.target
```

Crea `/etc/nixos/nixos-update.service`:

```ini
[Unit]
Description=Aggiornamento Sistema NixOS

[Service]
Type=oneshot
ExecStart=/percorso/a/another_nixos_manager.sh --yes update
```

Abilita in configuration.nix:

```nix
systemd.timers.nixos-update = {
  wantedBy = [ "timers.target" ];
  timerConfig = {
    OnCalendar = "weekly";
    Persistent = true;
  };
};

systemd.services.nixos-update = {
  serviceConfig = {
    Type = "oneshot";
    ExecStart = "/percorso/a/another_nixos_manager.sh --yes update";
  };
};
```

## Licenza

Questo progetto è rilasciato sotto licenza Creative Commons Attribution-NonCommercial 4.0 International - vedi il file [LICENSE](../LICENSE) nella directory principale per i dettagli.

---

Questo script fa parte della collezione [another_bucket_of_tools](https://github.com/palumbou/another_bucket_of_tools).
