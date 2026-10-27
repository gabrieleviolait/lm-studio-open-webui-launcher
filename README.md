# Open WebUI Launcher for LM Studio

Kit per avviare **[Open WebUI](https://github.com/open-webui/open-webui)** su **Windows** con [LM Studio](https://lmstudio.ai/) come motore di inferenza locale. Usa Python e [`uv`](https://docs.astral.sh/uv/); non richiede Docker Desktop.

**Creato da [gabrieleviola.it](https://www.gabrieleviola.it/).**

> Questo repository contiene **script di installazione/avvio e documentazione**, non il codice sorgente di Open WebUI. L'interfaccia Open WebUI viene installata dagli strumenti ufficiali e conserva il proprio nome, marchio e condizioni di licenza.

## Cosa fa

- Controlla che LM Studio risponda senza token su `127.0.0.1:1234` e abbia almeno un modello.
- Verifica se la porta `3000` è disponibile e riutilizza un'istanza Open WebUI già in ascolto quando la riconosce.
- Installa `uv` tramite **WinGet** se assente, poi avvia `open-webui@latest` con Python 3.12 e `uvx`.
- Configura la connessione OpenAI-compatible verso LM Studio, senza esporre la porta 1234 sulla rete.
- Memorizza cronologia e dati Open WebUI in `%LOCALAPPDATA%\LMStudio-OpenWebUI-ChatLAN\data`.
- Apre `http://localhost:3000` e mostra l'indirizzo per smartphone sulla stessa LAN.

## Requisiti

- Windows 10/11, PowerShell, **WinGet** e connessione Internet al **primo** avvio per scaricare le dipendenze.
- LM Studio installato, modello `Ready`, server `Running` sulla porta **1234**.
- **Require Authentication OFF** in LM Studio, per questo kit.
- Spazio sufficiente per Python, Open WebUI e le dipendenze (installazione più impegnativa della chat leggera).

## Utilizzo

1. Estrai tutti i file.
2. In LM Studio apri **Developer > Local Server**, carica il modello e avvia il server.
3. Esegui **`AVVIA_OPEN_WEBUI.cmd`** con doppio clic.
4. Il programma apre una seconda finestra PowerShell con log di installazione/avvio: tienila aperta.
5. Dal PC usa `http://localhost:3000`; da uno smartphone collegato alla stessa LAN usa `http://IP_DEL_PC:3000`.

L'installazione iniziale può richiedere download consistenti. Se un altro server usa già la porta `3000`, fermalo prima. Lo script non modifica WSL o Docker Desktop.

## Sicurezza per laboratori

**L'impostazione predefinita del kit è `WEBUI_AUTH=False`:** niente login, solo per LAN domestiche fidate. Chi può raggiungere la porta TCP 3000 può accedere alle conversazioni e usare il sistema. Non aprire la porta sul router verso Internet. La trasmissione su HTTP non è cifrata.

Per una classe con più studenti su **un unico server**, imposta `WEBUI_AUTH='True'` in `Run-OpenWebUI.ps1` **prima del primo avvio**, in modo da usare account individuali. Non considerare il cambio di questa impostazione un modo sicuro per modificare un'installazione già inizializzata.

Se Windows Firewall blocca l'accesso da telefono, autorizza solo TCP 3000, profilo Privato e `LocalSubnet`. LM Studio può restare configurato per ascoltare solo su localhost.

## Dati e manutenzione

- Directory dati mantenuta per compatibilità con il kit precedente: `%LOCALAPPDATA%\LMStudio-OpenWebUI-ChatLAN\data`.
- Non cancellare questa directory se vuoi conservare la cronologia.
- Il parametro `open-webui@latest` installa le nuove versioni disponibili; per laboratori ripetibili può essere utile fissare una versione dopo averla verificata.
- Per fermare Open WebUI, premi `Ctrl+C` nella seconda finestra PowerShell.

## Licenza e attribuzioni

Gli **script e la documentazione di questo repository** sono copyright © 2026 Gabriele Viola, pubblicati con licenza **MIT** (vedi `LICENSE`). Progetto creato da [gabrieleviola.it](https://www.gabrieleviola.it/).

**Open WebUI non è coperto dalla licenza MIT di questi script.** Dalla versione 0.6.6 il progetto applica la propria **Open WebUI License**, con condizioni sulla conservazione del branding. Secondo gli stessi autori non è una licenza open source approvata OSI; il codice è comunque disponibile pubblicamente. Consultare la [licenza upstream](https://github.com/open-webui/open-webui/blob/main/LICENSE) e la [spiegazione ufficiale](https://docs.openwebui.com/license/) per i dettagli. Questa distribuzione non modifica il branding originale.

LM Studio e `uv` sono strumenti esterni non redistribuiti nel pacchetto e restano soggetti alle rispettive licenze. Non esiste affiliazione ufficiale con Open WebUI, LM Studio o Astral.

## Collegamenti

- [Open WebUI Quick Start](https://docs.openwebui.com/getting-started/quick-start/)
- [LM Studio Local Server](https://lmstudio.ai/docs/developer/core/server)
- [uv](https://docs.astral.sh/uv/)
- [Open WebUI License](https://github.com/open-webui/open-webui/blob/main/LICENSE)
