# Configuration

Initialisation
- `Initialize-LoggerService -Reset` installe le dispatcher `StepManagerLogger`.

Enregistrement des sinks
- `Register-LoggerSink -Type Console -Format Default`
- `Register-LoggerSink -Type File -Path <chemin> [-FileFormat Default|Cmtrace] [-Rotation Size|Daily|NewFile] [-MaxSizeMB n] [-MaxRolls n] [-Encoding UTF8BOM|...]`

Raccourcis
- `Initialize-LoggerConsole`
- `Initialize-LoggerFile -Path <chemin> [-Rotation ...] [-MaxSizeMB ...] [-MaxRolls ...] [-Encoding ...]`

