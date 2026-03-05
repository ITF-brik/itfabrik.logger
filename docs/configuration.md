# Configuration

Initialisation
- `Initialize-LoggerService -Reset` installe le dispatcher `StepManagerLogger` (nom legacy pour compatibilite ITFabrik.Stepper).

Enregistrement des sinks
- `Register-LoggerSink -Type Console -Format Default`
- `Register-LoggerSink -Type File -Path <chemin> [-FileFormat Default|Cmtrace] [-Rotation Size|Daily|NewFile] [-MaxSizeMB n] [-MaxRolls n] [-Encoding UTF8BOM|...] [-OnError Warn|Continue|Throw]`
- `Register-LoggerSink -Type Web -Url <https://endpoint> [-APIKey ...] [-Headers @{...}] [-OnError Warn|Continue|Throw]`

Raccourcis
- `Initialize-LoggerConsole`
- `Initialize-LoggerFile -Path <chemin> [-Rotation ...] [-MaxSizeMB ...] [-MaxRolls ...] [-Encoding ...] [-OnError Warn|Continue|Throw]`
