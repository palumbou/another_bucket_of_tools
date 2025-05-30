# Another Home Backup Tool

> **Lingue disponibili**: [English](README.md) | [Italiano (corrente)](README.it.md)

Uno script bash semplice per eseguire il backup dei file essenziali dalla tua directory home.

## Caratteristiche

- Crea un archivio tar compresso della tua directory home
- Si concentra solo sui file e le directory essenziali
- Esclude cache, log e altri file non necessari
- Nomina i backup con il tuo nome utente e la data corrente
- Consente di specificare una destinazione personalizzata per il backup
- Se non viene fornita una destinazione, salva in ~/backup/

## Utilizzo

```bash
./another_home_backup_tool.sh [percorso_destinazione]
```

Esempi:
```bash
./another_home_backup_tool.sh                      # Salva in ~/backup/
./another_home_backup_tool.sh /percorso/backup/    # Salva nella directory specificata
```

## Personalizzare il Backup

Puoi personalizzare quali directory e file sono inclusi nel backup modificando l'array `ESSENTIAL_DIRS` nello script. Inoltre, puoi modificare i modelli di esclusione nello script in base alle tue esigenze.

## Requisiti

- Shell Bash
- Comando tar (installato di default sulla maggior parte dei sistemi Linux)

## Licenza

Questo progetto è rilasciato sotto licenza Creative Commons Attribution-NonCommercial 4.0 International - vedi il file [LICENSE](../LICENSE) nella directory principale per i dettagli.

---

Questo script fa parte della collezione [another_bucket_of_tools](https://github.com/palumbou/another_bucket_of_tools).
