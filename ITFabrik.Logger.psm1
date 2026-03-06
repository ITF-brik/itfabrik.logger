# Load private classes and functions first
Get-ChildItem -Path "$PSScriptRoot\Private\Classes" -Filter *.ps1 -File -ErrorAction SilentlyContinue |
    ForEach-Object { . $_.FullName }
Get-ChildItem -Path "$PSScriptRoot\Private\Functions" -Filter *.ps1 -File -ErrorAction SilentlyContinue |
    ForEach-Object { . $_.FullName }

# Load public functions if present
Get-ChildItem -Path "$PSScriptRoot\Public" -Filter *.ps1 -File -ErrorAction SilentlyContinue |
    ForEach-Object { . $_.FullName }

# No global logger side effect at import time.
# Consumers must explicitly initialize via Initialize-LoggerConsole,
# Initialize-LoggerFile, Initialize-LoggerSerilog, or Initialize-LoggerService.

Export-ModuleMember -Function Initialize-LoggerService,Register-LoggerSink,Initialize-LoggerConsole,Initialize-LoggerFile,Initialize-LoggerSerilog,Disable-Logger
