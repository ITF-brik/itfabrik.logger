# Sink Web

- Transport: `HTTP POST` JSON via `Invoke-RestMethod`.
- Usage: `Register-LoggerSink -Type Web`.

Parametres
- `-Url <https://endpoint>` (obligatoire)
- `-APIKey <string>` (optionnel, envoye dans `X-API-Key`)
- `-Headers <hashtable>` (optionnel, fusionne avec les headers internes)
- `-OnError Warn|Continue|Throw` (defaut: `Warn`)

Charge utile JSON (extrait)
- `timestamp` (ISO 8601)
- `component`
- `message`
- `severity`
- `indent`
- `host`
- `processId`

Exemple
```powershell
Initialize-LoggerService -Reset
Register-LoggerSink -Type Web -Url 'https://example.local/api/logs' -APIKey 'abc' -Headers @{ 'X-Env' = 'prod' } -OnError Warn
```

