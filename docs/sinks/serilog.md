# Sink Serilog

- Transport: `HTTP POST` JSON.
- Usage: `Register-LoggerSink -Type Serilog` ou `Initialize-LoggerSerilog`.

Parametres
- `-Url <https://endpoint>` (obligatoire)
- `-APIKey <string>` (optionnel, envoye dans `X-API-Key`)
- `-Headers <hashtable>` (optionnel, fusionne avec les headers internes)
- `-OnError Warn|Continue|Throw` (defaut: `Warn`)

Payload envoye
- `Timestamp`
- `Level`
- `MessageTemplate`
- `RenderedMessage`
- `Properties`
  - `Component`
  - `SourceContext`
  - `IndentLevel`
  - `Host`
  - `ProcessId`
  - `OriginalSeverity`
  - `Outcome` (uniquement quand `Severity = Success`)

Mapping de niveau
- `Info -> Information`
- `Success -> Information`
- `Warning -> Warning`
- `Error -> Error`
- `Debug -> Debug`
- `Verbose -> Verbose`

Limites du MVP
- Le module ne capture pas encore d'`Exception` native.
- Le module ne transporte pas encore de `MessageTemplate` enrichi distinct du message rendu.
- Le module n'expose pas encore de proprietes structurees libres, ni `TraceId` / `SpanId`.

Exemple minimal
```powershell
Initialize-LoggerSerilog -Url 'https://example.local/api/serilog' -APIKey 'abc' -Headers @{ 'X-Env' = 'prod' } -OnError Warn
```

Exemples d'usage

Initialisation rapide avec le raccourci public
```powershell
Import-Module ITFabrik.Logger -Force

Initialize-LoggerSerilog `
    -Url 'https://logs.contoso.local/ingest/serilog' `
    -OnError Warn
```

Utilisation avec ITFabrik.Stepper
```powershell
Import-Module ITFabrik.Logger -Force
Import-Module ITFabrik.Stepper -Force

Initialize-LoggerSerilog `
    -Url 'https://logs.contoso.local/ingest/serilog' `
    -Headers @{ 'X-Application' = 'Provisioning' } `
    -OnError Warn

Write-Log -Message 'Debut du traitement' -Severity Info
Write-Log -Message 'Creation du package terminee' -Severity Success
Write-Log -Message 'Le package precedent est obsolete' -Severity Warning
```

Configuration explicite avec `Register-LoggerSink`
```powershell
Import-Module ITFabrik.Logger -Force

Initialize-LoggerService -Reset

Register-LoggerSink `
    -Type Serilog `
    -Url 'https://logs.contoso.local/ingest/serilog' `
    -APIKey 'abc123' `
    -Headers @{
        'X-Environment' = 'Production'
        'X-Service'     = 'Billing'
    } `
    -OnError Throw
```

Combiner plusieurs sinks
```powershell
Import-Module ITFabrik.Logger -Force
Import-Module ITFabrik.Stepper -Force

Initialize-LoggerService -Reset
Register-LoggerSink -Type Console
Register-LoggerSink -Type File -Path "$env:TEMP\\app.log" -OnError Warn
Register-LoggerSink -Type Serilog -Url 'https://logs.contoso.local/ingest/serilog' -OnError Continue

Write-Log -Message 'Message visible en console, fichier et endpoint Serilog' -Severity Info
```

Choisir la politique d'erreur
```powershell
# Warn: affiche un warning si l'endpoint est indisponible
Initialize-LoggerSerilog -Url 'https://logs.contoso.local/ingest/serilog' -OnError Warn

# Continue: ignore silencieusement l'erreur du sink
Initialize-LoggerSerilog -Url 'https://logs.contoso.local/ingest/serilog' -OnError Continue

# Throw: propage l'erreur au code appelant
Initialize-LoggerSerilog -Url 'https://logs.contoso.local/ingest/serilog' -OnError Throw
```

Exemple de payload attendu
```json
{
  "Timestamp": "2026-03-06T10:30:00.0000000+01:00",
  "Level": "Information",
  "MessageTemplate": "Creation du package terminee",
  "RenderedMessage": "Creation du package terminee",
  "Properties": {
    "Component": "ITFabrik.Stepper",
    "SourceContext": "ITFabrik.Stepper",
    "IndentLevel": 0,
    "Host": "BUILD01",
    "ProcessId": 2480,
    "OriginalSeverity": "Success",
    "Outcome": "Success"
  }
}
```

Conseils pratiques
- Utiliser `Initialize-LoggerSerilog` pour les cas simples et `Register-LoggerSink -Type Serilog` quand plusieurs sinks doivent etre combines.
- Utiliser `OnError Warn` en environnement interactif pour garder de la visibilite sur les echecs reseau.
- Utiliser `OnError Throw` dans les scripts critiques si la livraison du log fait partie du contrat d'execution.
- Ajouter des headers metier (`X-Environment`, `X-Service`, `X-Application`) quand l'endpoint de collecte les exploite.
