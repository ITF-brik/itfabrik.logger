# ITFabrik.Logger

[![CI - Tests](https://img.shields.io/github/actions/workflow/status/ITF-brik/itfabrik.logger/ci.yml?branch=main&label=CI%20-%20Tests)](https://github.com/ITF-brik/itfabrik.logger/actions/workflows/ci.yml)
[![CI - Coverage](https://img.shields.io/github/actions/workflow/status/ITF-brik/itfabrik.logger/pester-coverage.yml?branch=main&label=CI%20-%20Coverage)](https://github.com/ITF-brik/itfabrik.logger/actions/workflows/pester-coverage.yml)
[![PS Gallery Version](https://img.shields.io/powershellgallery/v/ITFabrik.Logger.svg?style=flat)](https://www.powershellgallery.com/packages/ITFabrik.Logger)
[![PS Gallery Downloads](https://img.shields.io/powershellgallery/dt/ITFabrik.Logger.svg?style=flat)](https://www.powershellgallery.com/packages/ITFabrik.Logger)
[![Release](https://img.shields.io/github/v/release/ITF-brik/itfabrik.logger?display_name=tag&sort=semver)](https://github.com/ITF-brik/itfabrik.logger/releases)
[![License](https://img.shields.io/badge/License-Apache--2.0-blue.svg)](LICENSE)

Logger est un module PowerShell de journalisation compatible ITFabrik.Stepper via la variable globale legacy `$StepManagerLogger`. Il fournit des sinks Console, Fichier, Web et Serilog avec formats configurables, rotation et encodage, et s’intègre explicitement à ITFabrik.Stepper après initialisation du logger pour un affichage cohérent (icônes, couleurs, indentation).

---

## Installation


- Depuis PowerShell Gallery (recommandé):

```powershell
Install-Module ITFabrik.Logger -Scope CurrentUser -Force
# Puis si nécessaire
Import-Module ITFabrik.Logger -Force
```

- Mise à jour:

```powershell
Update-Module ITFabrik.Logger
```

- Installation manuelle locale:

```powershell
# Depuis le dossier du module
Import-Module .\ITFabrik.Logger.psd1 -Force
```

- Installation manuelle depuis GitHub Release:

```powershell
# Dépôt GitHub de ce module
$tag = (Invoke-RestMethod https://api.github.com/repos/ITF-brik/itfabrik.logger/releases/latest).tag_name
$zip = Join-Path $env:TEMP "ITFabrik.Logger-$tag.zip"
Invoke-WebRequest -Uri "https://github.com/ITF-brik/itfabrik.logger/releases/download/$tag/ITFabrik.Logger-$tag.zip" -OutFile $zip
$dst = Join-Path $HOME "Documents/PowerShell/Modules/ITFabrik.Logger"
if (-not (Test-Path $dst)) { New-Item -ItemType Directory -Path $dst -Force | Out-Null }
Expand-Archive -Path $zip -DestinationPath $dst -Force
Import-Module ITFabrik.Logger -Force
```

---

## Executer les tests en local

- Avec configuration (Pester v5):

```powershell
Import-Module Pester -MinimumVersion 5.5.0 -Force
$cfg = New-PesterConfiguration -Hashtable (Import-PowerShellDataFile 'Tests/PesterConfig.psd1')
Invoke-Pester -Configuration $cfg
```

- Ou simple (sans config):

```powershell
Invoke-Pester -Path Tests
```

- Analyse statique (ScriptAnalyzer):

```powershell
Import-Module PSScriptAnalyzer -MinimumVersion 1.22.0 -Force
$targets = @('ITFabrik.Logger.psm1','Public','Private')
$issues = foreach ($target in $targets) {
  Invoke-ScriptAnalyzer -Path $target -Recurse -Settings 'PSScriptAnalyzerSettings.psd1'
}
$issues | Format-Table -AutoSize
```

## Fonctionnalités

- Intégration ITFabrik.Stepper explicite via `$Global:StepManagerLogger` (nom legacy conservé pour compatibilité) après appel d’une fonction d’initialisation.
- Sink Console: rendu aligné sur l'affichage `Write-Log` d'ITFabrik.Stepper (icônes PowerShell 7+, couleurs, indentation).
- Sink Fichier: formats `Default` et `Cmtrace` (XML-like compatible cmtrace.exe).
- Sink Web: POST JSON HTTP (`Url`, `APIKey`, `Headers`), avec politique d'erreur `OnError`.
- Sink Serilog: POST JSON structure Serilog-like (`Timestamp`, `Level`, `MessageTemplate`, `RenderedMessage`, `Properties`) pour intégration simple avec des endpoints orientés Serilog.
- Compatibilité Stepper parallèle: un `Timestamp` optionnel peut être transmis au dispatcher global pour préserver l'horodatage réel des logs rejoués.
- Rotation de fichiers: `NewFile`, `Size`, `Daily` ou aucune.
- Encodages configurables: `UTF8BOM` (défaut), `UTF8`, `Unicode`, etc.
- Niveaux de sévérité: `Info`, `Success`, `Warning`, `Error`, `Debug`, `Verbose`.
- Multiples sinks actifs en parallèle (console + fichier, etc.).

## Exemples d’utilisation

### Journalisation en console (rapide)

```powershell
Import-Module ITFabrik.Logger -Force
Initialize-LoggerConsole

# Avec ITFabrik.Stepper (recommandé)
Import-Module ITFabrik.Stepper -Force
Write-Log -Message 'Démarrage du traitement' -Severity Info
Write-Log -Message 'Traitement terminé' -Severity Success
```

Exemple d’affichage console attendu (PowerShell 7+, console UTF-8):

```text
[2025-10-24 10:00:00] ?    [Step] Démarrage du traitement
[2025-10-24 10:00:01] V    [Step] Traitement terminé
```

### Journalisation dans un fichier (par défaut)

```powershell
Import-Module ITFabrik.Logger -Force
Initialize-LoggerFile -Path "$env:TEMP\app.log"

Import-Module ITFabrik.Stepper -Force
Write-Log -Message 'Écriture dans le fichier' -Severity Info
```

Ligne générée en format `Default` (exemple):

```text
[2025-10-24 10:31:57] [      Info] [ITFabrik.Stepper]  Écriture dans le fichier
```

### Format CMTrace pour compatibilité cmtrace.exe

```powershell
Import-Module ITFabrik.Logger -Force
Initialize-LoggerService -Reset
Register-LoggerSink -Type File -Path "$env:TEMP\app.cmtrace.log" -FileFormat Cmtrace -Rotation NewFile -Encoding UTF8BOM

Import-Module ITFabrik.Stepper -Force
Write-Log -Message 'Message compatible CMTrace' -Severity Warning
```

Extrait (XML-like) attendu:

```text
<![LOG[Message compatible CMTrace]LOG]!><time="12:00:00.123456" date="10-24-2025" component="ITFabrik.Stepper" context="User" type="2" thread="42" file="">
```

### Deux sinks en parallèle (console + fichier)

```powershell
Import-Module ITFabrik.Logger -Force
Initialize-LoggerService -Reset
Register-LoggerSink -Type Console -Format Default
Register-LoggerSink -Type File -Path "$env:TEMP\app.log" -Rotation Size -MaxSizeMB 1 -MaxRolls 3

Import-Module ITFabrik.Stepper -Force
Write-Log -Message 'Visible console et écrit dans app.log' -Severity Info
```

### Sink Web (HTTP JSON)

```powershell
Import-Module ITFabrik.Logger -Force
Initialize-LoggerService -Reset
Register-LoggerSink -Type Web -Url 'https://example.local/api/logs' -APIKey 'abc' -Headers @{ 'X-Env' = 'prod' } -OnError Warn

Import-Module ITFabrik.Stepper -Force
Write-Log -Message 'Envoi vers endpoint HTTP' -Severity Info
```

### Sink Serilog (HTTP JSON structure)

```powershell
Import-Module ITFabrik.Logger -Force
Initialize-LoggerSerilog -Url 'https://example.local/api/serilog' -APIKey 'abc' -Headers @{ 'X-Env' = 'prod' } -OnError Warn

Import-Module ITFabrik.Stepper -Force
Write-Log -Message 'Processed order 42' -Severity Success
```

Charge utile envoyee (exemple):

```json
{
  "Timestamp": "2026-03-06T10:30:00.0000000+01:00",
  "Level": "Information",
  "MessageTemplate": "Processed order 42",
  "RenderedMessage": "Processed order 42",
  "Properties": {
    "Component": "ITFabrik.Stepper",
    "SourceContext": "ITFabrik.Stepper",
    "IndentLevel": 0,
    "Host": "HOST01",
    "ProcessId": 1234,
    "OriginalSeverity": "Success",
    "Outcome": "Success"
  }
}
```

### Rotation

```powershell
# NewFile: archive au premier write puis écrit dans un nouveau fichier
Initialize-LoggerFile -Path "$env:TEMP\app.log" -Rotation NewFile

# Size: roll .1, .2, ... quand la taille dépasse MaxSizeMB
Initialize-LoggerService -Reset
Register-LoggerSink -Type File -Path "$env:TEMP\app.log" -Rotation Size -MaxSizeMB 5 -MaxRolls 3

# Daily: suffixe yyyy-MM-dd dans le nom
Initialize-LoggerService -Reset
Register-LoggerSink -Type File -Path "$env:TEMP\app.log" -Rotation Daily
```

### Désactiver le logger ITFabrik.Stepper

```powershell
Disable-Logger   # supprime `$Global:StepManagerLogger` (nom legacy)
```

---

## Contrat de retour

- `Initialize-LoggerService`, `Initialize-LoggerConsole`, `Initialize-LoggerFile`, `Initialize-LoggerSerilog`, `Register-LoggerSink`, `Disable-Logger` n’émettent pas de sortie par défaut.
- Le logger exposé pour ITFabrik.Stepper est un scriptblock global: `$Global:StepManagerLogger` (nom legacy conservé).

## Signature attendue du logger ITFabrik.Stepper

```powershell
$Global:StepManagerLogger = {
    param(
        [string]$Component,
        [string]$Message,
        [ValidateSet('Info','Success','Warning','Error','Debug','Verbose')]
        [string]$Severity,
        [int]$IndentLevel,
        [Nullable[datetime]]$Timestamp = $null
    )
    # ...implémentation...
}
```

Si `Timestamp` est fourni, le logger l'utilise comme horodatage effectif. Sinon, le comportement historique reste inchangé et l'heure courante est utilisée. Le nom `StepManagerLogger` est conservé pour compatibilité avec ITFabrik.Stepper. Vous pouvez la remplacer par votre propre implémentation si besoin.

---

## Documentation détaillée

- Formats: `docs/formats/default.md`, `docs/formats/cmtrace.md`
- Sinks: `docs/sinks/console.md`, `docs/sinks/file.md`
- Sinks: `docs/sinks/console.md`, `docs/sinks/file.md`, `docs/sinks/web.md`, `docs/sinks/serilog.md`
- Configuration: `docs/configuration.md`
- Rotation: `docs/rotation.md`
- Dépannage: `docs/troubleshooting.md`

---

## Licence

Apache-2.0 - voir `LICENSE`.




---

