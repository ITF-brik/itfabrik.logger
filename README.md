# ITFabrik.Logger

[![CI - Tests](https://img.shields.io/github/actions/workflow/status/ITF-brik/itfabrik.logger/ci.yml?branch=main&label=CI%20-%20Tests)](https://github.com/ITF-brik/itfabrik.logger/actions/workflows/ci.yml)
[![CI - Coverage](https://img.shields.io/github/actions/workflow/status/ITF-brik/itfabrik.logger/pester-coverage.yml?branch=main&label=CI%20-%20Coverage)](https://github.com/ITF-brik/itfabrik.logger/actions/workflows/pester-coverage.yml)
[![PS Gallery Version](https://img.shields.io/powershellgallery/v/ITFabrik.Logger.svg?style=flat)](https://www.powershellgallery.com/packages/ITFabrik.Logger)
[![PS Gallery Downloads](https://img.shields.io/powershellgallery/dt/ITFabrik.Logger.svg?style=flat)](https://www.powershellgallery.com/packages/ITFabrik.Logger)
[![Release](https://img.shields.io/github/v/release/ITF-brik/itfabrik.logger?display_name=tag&sort=semver)](https://github.com/ITF-brik/itfabrik.logger/releases)
[![License](https://img.shields.io/badge/License-Apache--2.0-blue.svg)](LICENSE)

Logger est un module PowerShell de journalisation compatible StepManager via la variable globale `$StepManagerLogger`. Il fournit des sinks Console et Fichier avec formats configurables, rotation et encodage, et s’intègre automatiquement à StepManager pour un affichage cohérent (icônes, couleurs, indentation).

---

## Installation

Note: Pour exécuter les tests en local, voir la section "Executer les tests en local" ci‑dessous.

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

## Fonctionnalités

- Intégration StepManager automatique via `$Global:StepManagerLogger`.
- Sink Console: rendu aligné sur `Write-StepMessage` (icônes PowerShell 7+, couleurs, indentation).
- Sink Fichier: formats `Default` et `Cmtrace` (XML-like compatible cmtrace.exe).
- Rotation de fichiers: `NewFile`, `Size`, `Daily` ou aucune.
- Encodages configurables: `UTF8BOM` (défaut), `UTF8`, `Unicode`, etc.
- Niveaux de sévérité: `Info`, `Success`, `Warning`, `Error`, `Debug`, `Verbose`.
- Multiples sinks actifs en parallèle (console + fichier, etc.).

## Exemples d’utilisation

### Journalisation en console (rapide)

```powershell
Import-Module ITFabrik.Logger -Force
Initialize-LoggerConsole

# Avec StepManager (recommandé)
Import-Module StepManager -Force
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

Import-Module StepManager -Force
Write-Log -Message 'Écriture dans le fichier' -Severity Info
```

Ligne générée en format `Default` (exemple):

```text
[2025-10-24 10:31:57] [      Info] [StepManager]  Écriture dans le fichier
```

### Format CMTrace pour compatibilité cmtrace.exe

```powershell
Import-Module ITFabrik.Logger -Force
Initialize-LoggerService -Reset
Register-LoggerSink -Type File -Path "$env:TEMP\app.cmtrace.log" -FileFormat Cmtrace -Rotation NewFile -Encoding UTF8BOM

Import-Module StepManager -Force
Write-Log -Message 'Message compatible CMTrace' -Severity Warning
```

Extrait (XML-like) attendu:

```text
<![LOG[Message compatible CMTrace]LOG]!><time="12:00:00.123456" date="10-24-2025" component="StepManager" context="User" type="2" thread="42" file="">
```

### Deux sinks en parallèle (console + fichier)

```powershell
Import-Module ITFabrik.Logger -Force
Initialize-LoggerService -Reset
Register-LoggerSink -Type Console -Format Default
Register-LoggerSink -Type File -Path "$env:TEMP\app.log" -Rotation Size -MaxSizeMB 1 -MaxRolls 3

Import-Module StepManager -Force
Write-Log -Message 'Visible console et écrit dans app.log' -Severity Info
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

### Désactiver le logger StepManager

```powershell
Disable-Logger   # supprime $Global:StepManagerLogger
```

---

## Contrat de retour

- `Initialize-LoggerService`, `Initialize-LoggerConsole`, `Initialize-LoggerFile`, `Register-LoggerSink`, `Disable-Logger` n’émettent pas de sortie par défaut.
- Le logger StepManager exposé est un scriptblock global: `$Global:StepManagerLogger`.

## Signature attendue du logger StepManager

```powershell
$Global:StepManagerLogger = {
    param(
        [string]$Component,
        [string]$Message,
        [ValidateSet('Info','Success','Warning','Error','Debug','Verbose')]
        [string]$Severity,
        [int]$IndentLevel
    )
    # ...implémentation...
}
```

Ce module installe et alimente automatiquement cette variable lors de l’initialisation du service. Vous pouvez la remplacer par votre propre implémentation si besoin.

---

## Documentation détaillée

- Formats: `docs/formats/default.md`, `docs/formats/cmtrace.md`
- Sinks: `docs/sinks/console.md`, `docs/sinks/file.md`
- Configuration: `docs/configuration.md`
- Rotation: `docs/rotation.md`
- Dépannage: `docs/troubleshooting.md`

---

## Licence

Apache-2.0 - voir `LICENSE`.




---
